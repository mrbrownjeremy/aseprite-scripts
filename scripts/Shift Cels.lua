---------------------------------------------------------------
-- Shift Cels
--
-- author: quietly-turning
-- github: https://github.com/quietly-turning/
---------------------------------------------------------------

if not (app and app.isUIAvailable) then return end
if not app.range.type == RangeType.CELS then return end

---------------------------------------------------------------

local dlg = Dialog("Shift Cels")


local ShiftCels = function()

	-- ---------------------------------------------------------------
	-- Step 1: determine how much we're actually shifting using modulo
	local shift_amt = dlg.data.shift_amt % #app.range.cels

	-- there's no need to go any further if no shifting is needed
	-- just return early from ShiftCels now
	if shift_amt == 0 then return end

	-- --------------------------------------------
	-- Step 2: get a table of cels that is sorted by frameNumber
	--
	-- iterating over app.range.cels using ipairs() does not guarantee
	-- sequential frameNumbers!
	--
	-- Meaning, you might have frames 4→8 selected in the timeline,
	-- and looping with ipairs(app.range.cels) might give you the frames
	-- in an order like {5,6,7,8,4}, and other times, it will be {4,5,6,7,8}.
	--
	-- The fix (workaround?) is to copy the contents of app.range.cels
	-- into our own custom table then sort that by frameNumber.
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
	-- --------------------------------------------


	-- --------------------------------------------
	-- Step 3: loop through our table of cels, creating new cels in the timeline
	--   for each, overwriting old cel data as we go.

	for i, cel in ipairs(cels) do

		-- create a new cel using cloned image data
		-- sprite:newCel() takes 4 args:
		--   1. layer to create the new cel in
		--   2. the frame to create the new cel on
		--   3. the image we want to be in this new cel
		--   4. position data (a table of xy values) for this new cel
		app.activeSprite:newCel(
			app.activeLayer,
			app.activeSprite.frames[ ((cel.frameNumber-1+shift_amt) % #cels)+1 ],
			cel.image,
			cel.position
		).color = cel.color
		-- cel:newCel() will return the newly created cel object,
		-- so chain on one exta operation — set the color of the new cel in the timeline
	end

	-- after the loop is done, set activeFrame to the new "first frame"
	-- that we moved the entire range to
	app.activeFrame = app.activeSprite.frames[cels[1].frameNumber]

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
