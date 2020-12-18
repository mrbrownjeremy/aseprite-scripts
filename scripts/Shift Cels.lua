---------------------------------------------------------------
-- Shift Cels
--
-- author: quietly-turning
-- github: https://github.com/quietly-turning/
---------------------------------------------------------------

if not app then return end
if not app.isUIAvailable then return end
if not app.range.type == RangeType.CELS then return end

---------------------------------------------------------------

local dlg = Dialog("Shift Cels")


local ShiftCels = function()

	-- iterating over app.range.cels using ipairs() does not guarantee
	-- sequential frameNumbers!
	-- this can result in frames being shifted out-of-sequence
	--
	-- the fix (workaround?) is to copy the contents of app.range.cels
	-- into our own custom table then sort it by frameNumber
	local cels = {}
	for i,cel in ipairs(app.range.cels) do
		local clone_data = {
			image=cel.image:clone(),
			frameNumber=cel.frameNumber,
			position=Point(cel.position),
			color=Color(cel.color)
		}

		table.insert(cels, clone_data)
	end
	table.sort(cels, function(a,b) return a.frameNumber < b.frameNumber end)

	-- "cels" will now have the selected range of cels, correctly sorted by frameNumber

	-- retain the first frameNumber now, before shifting,
	-- so we can set the activeFrame to it afterwards
	local first_frame = cels[1].frameNumber
	local shift_amt = dlg.data.shift_amt % #cels

	-- no need to loop and replace if no shifting is needed
	if shift_amt == 0 then return end

	for i, cel in ipairs(cels) do

		-- create a new cel using cloned image data
		-- see: https://github.com/aseprite/api/blob/master/api/sprite.md#spritenewcel
		app.activeSprite:newCel(
			app.activeLayer,
			app.activeSprite.frames[ ((cel.frameNumber-1+shift_amt) % #cels)+1 ],
			cel.image,
			cel.position
		).color = cel.color

	end

	-- set activeFrame to the new "first frame" that we moved the entire range to
	app.activeFrame = app.activeSprite.frames[first_frame]

	app.refresh()
end

---------------------------------------------------------------

dlg:label({
	id = "activeLayer_name",
	label = "layer: ",
	text = app.activeLayer and app.activeLayer.name or "",
})

dlg:number({
	id = "shift_amt",
	label = "Shift Amt:",
	text = "",
	focus = true,
})

dlg:button({
	id = "ShiftCels_button",
	text = "Shift Cels",
	onclick = function() app.transaction( ShiftCels ) end
})

-- allow the user to continue to interact with Aseprite while this dialog is up
dlg:show({wait=false})
