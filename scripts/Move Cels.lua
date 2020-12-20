---------------------------------------------------------------
-- Move Cels
--
-- author: quietly-turning
-- github: https://github.com/quietly-turning/
---------------------------------------------------------------

if not app then return end
if not (app.isUIAvailable and app.activeCel) then return end
if not app.range.type == RangeType.CELS then return end

---------------------------------------------------------------

local dlg = Dialog("Move Cels")

---------------------------------------------------------------

local GetAndSortCels = function()
	-- iterating over app.range.cels using ipairs() does not guarantee
	-- sequential frameNumbers!
	-- this can result in frames being moved out-of-sequence
	--
	-- the fix (workaround?) is to copy the contents of app.range.cels
	-- into our own custom table then sort it by frameNumber
	local _cels = {}

	for i,cel in ipairs(app.range.cels) do
		local clone_data = {
			image=cel.image:clone(),
			frameNumber=cel.frameNumber,
			position=Point(cel.position),
			color=Color(cel.color)
		}

		table.insert(_cels, clone_data)
	end
	table.sort(_cels, function(a,b) return a.frameNumber < b.frameNumber end)

	return _cels
end

local num_frames
local old_frames = { first=nil, last=nil }
local new_frames = { first=nil, last=nil }

local GetAndSortFrames = function()
	local _frames = {}
	for _,frame in ipairs(app.range.frames) do table.insert(_frames, frame.frameNumber) end
	table.sort(_frames)

	num_frames = #_frames
	old_frames.first = _frames[1]
	old_frames.last  = _frames[num_frames]

	if dlg.data and type(dlg.data.to_frame)=="number" and dlg.data.to_frame > 0 then
		local diff = dlg.data.to_frame - old_frames.first
		new_frames.first = old_frames.first + diff
		new_frames.last  = old_frames.last  + diff
	else
		new_frames.first = nil
		new_frames.last  = nil
	end

	return _frames
end

local cels = GetAndSortCels()
local frames = GetAndSortFrames()


---------------------------------------------------------------

local MoveCels = function()

	-- "cels" will have the selected range of cels, correctly sorted by frameNumber
	cels = GetAndSortCels()
	frames = GetAndSortFrames()

	local cels_index
	local start, stop, step

	if dlg.data.to_frame > frames[1] then
		-- moving cels right
		start = old_frames.last
		stop  = old_frames.first
		step  = -1
		cels_index = #cels
	else
		-- moving cels left
		start = old_frames.first
		stop  = old_frames.last
		step  = 1
		cels_index = 1
	end

	for i=start, stop, step do

		local dest_frame = i+(dlg.data.to_frame - old_frames.first)

		-- if we're at a frameNumber in our loop where there is no corresponding cel data...
		if ((cels[cels_index] == nil) or (i ~= cels[cels_index].frameNumber)) then

			-- and if there is cel data at the destination cel...
			local cel = app.activeLayer:cel(dest_frame)
			-- ...then delete that cel data
			if cel then app.activeSprite:deleteCel( cel ) end

		else

			local cel_data = cels[cels_index]

			-- create a new cel using data from the cel we want to move
			-- see: https://github.com/aseprite/api/blob/master/api/sprite.md#spritenewcel
			app.activeSprite:newCel(
				app.activeLayer,
				app.activeSprite.frames[ dest_frame ],
				cel_data.image,
				cel_data.position
			).color = cel_data.color
			-- cel:newCel() will return the newly created cel object,
			-- so chain on one exta operation — set the color of the new cel in the timeline

			-- delete the old cel
			app.activeSprite:deleteCel( app.activeLayer:cel( i ) )

			-- we've successfully added a new cel to the timeline
			-- increment cels_index if moving cels left, or decrement if moving cels right
			-- so we can attempt to add the next cel in the next pass of the loop
			cels_index = cels_index + step
		end
	end

	-- set activeFrame to the new "first frame" that we moved the entire range to
	app.activeFrame = app.activeSprite.frames[new_frames.first]

	app.refresh()
end

---------------------------------------------------------------

dlg:label({
	id = "activeLayerName_label",
	label = "          Layer: ",
	text = app.activeLayer and app.activeLayer.name or "",
})

dlg:label({
	id = "selected_range",
	label = "Selected Range: ",
	text = ("%d – %d"):format(old_frames.first, old_frames.last),
})

dlg:label({
	id = "moveTo_label",
	label = "     Moving To: ",
	text = ""
})

------------------------------
dlg:separator()


dlg:number({
	id = "to_frame",
	label = "       Move To:",
	text = "",
	focus = true,
	onchange=function()
		cels = GetAndSortCels()
		frames = GetAndSortFrames()

		local sel_range = ("%d – %d"):format(old_frames.first, old_frames.last)
		local moving_to = ("%d – %d"):format(new_frames.first or 0, new_frames.last or 0)

		dlg:modify({
			id="selected_range",
			visible=true,
			enabled=true,
			text=#cels > 0 and sel_range or ""
		})

		dlg:modify({
			id="moveTo_label",
			visible=true,
			enabled=true,
			text=dlg.data.to_frame > 0 and moving_to or ""
		})
	end
})

dlg:button({
	id = "MoveCels_Button",
	text = "Move",
	onclick = function() app.transaction( MoveCels ) end
})

-- allow the user to continue to interact with Aseprite while this dialog is up
dlg:show({wait=false})
