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

local MoveCels = function()

	-- iterating over app.range.cels using ipairs() does not guarantee
	-- sequential frameNumbers!
	-- this can result in frames being moved out-of-sequence
	--
	-- the fix (workaround?) is to copy the contents of app.range.cels
	-- into our own custom table then sort it by frameNumber
	local cels = {}
	for i,cel in ipairs(app.range.cels) do
		table.insert(cels, cel)
	end
	table.sort(cels, function(a,b) return a.frameNumber < b.frameNumber end)

	-- "cels" will now have the selected range of cels, correctly sorted by frameNumber


	-- start, stop, and step are used to control the order we'll loop through the "cels" table
	-- we can't assume that we always want to increment from first cel to last cel
	--
	-- e.g.  if the range is 10 cels total, and we want to move them all 5 to the right
	--       moving cel#1 to frame#5 would overwrite cel#5 before we had a chance to
	--       properly move it!
	local start, stop, step


	-- if we're moving cels right
	-- set up loop conditions to decrement from last cel to first
	if dlg.data.to_frame > cels[1].frameNumber then
		start = #cels
		stop  = 1
		step  = -1

	-- if moving cels left
	-- set up loop conditions to increment from first cel to last
	else
		 start = 1
		 stop  = #cels
		 step  = 1
	end



	for i=start, stop, step do

		-- create a new cel using data from the cel we want to move
		-- see: https://github.com/aseprite/api/blob/master/api/sprite.md#spritenewcel
		app.activeSprite:newCel(
			app.activeLayer,
			app.activeSprite.frames[dlg.data.to_frame+(i-1)],
			cels[i].image,
			cels[i].position
		)

		-- delete the old cel
		app.activeSprite:deleteCel(cels[i])
	end

	-- set activeFrame to the new "first frame" that we moved the entire range to
	app.activeFrame = app.activeSprite.frames[dlg.data.to_frame]

	app.refresh()
end

---------------------------------------------------------------

dlg:label({
	id = "activeLayer_name",
	label = "layer: ",
	text = app.activeLayer and app.activeLayer.name or "",
})

dlg:number({
	id = "to_frame",
	label = "Move To:",
	text = "",
	focus = true,
})

dlg:button({
	id = "MoveCels_Button",
	text = "Move",
	onclick = function() app.transaction( MoveCels ) end
})

-- allow the user to continue to interact with Aseprite while this dialog is up
dlg:show({wait=false})
