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
		table.insert(_cels, cel)
	end
	table.sort(_cels, function(a,b) return a.frameNumber < b.frameNumber end)

	return _cels
end

local cels = GetAndSortCels()

---------------------------------------------------------------

local MoveCels = function()

	-- "cels" will have the selected range of cels, correctly sorted by frameNumber
	cels = GetAndSortCels()


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
		).color = cels[i].color

		-- delete the old cel
		app.activeSprite:deleteCel(cels[i])
	end

	-- set activeFrame to the new "first frame" that we moved the entire range to
	app.activeFrame = app.activeSprite.frames[dlg.data.to_frame]

	app.refresh()
end

---------------------------------------------------------------

dlg:label({
	id = "activeLayerName_label",
	label = "          Layer: ",
	text = app.activeLayer and app.activeLayer.name or "",
})

dlg:label({
	id = "selectedRange_label",
	label = "Selected Range: ",
	text = ("%d – %d"):format(cels[1].frameNumber, cels[#cels].frameNumber),
}):newrow()
dlg:label({
	id = "moveTo_label",
	label = "     Moving To: ",
	text = ""
}):separator()


dlg:number({
	id = "to_frame",
	label = "       Move To:",
	text = "",
	focus = true,
	onchange=function()
		dlg:modify({
			id="moveTo_label",
			visible=true,
			enabled=true,
			text=("%d – %d"):format(dlg.data.to_frame, tostring(dlg.data.to_frame+#cels-1))
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
