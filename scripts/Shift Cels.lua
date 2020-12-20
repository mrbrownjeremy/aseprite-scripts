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

	-- --------------------------------------------
	-- Step 1: get a table of cels that is sorted by frameNumber
	--
	-- iterating over app.range.cels using ipairs() does not guarantee
	-- sequential frameNumbers!
	--
	-- Meaning, you might have frames 4→7 selected in the timeline,
	-- and looping with ipairs(app.range.cels) might give you the frames
	-- in an order like {5,6,7,4}, and other times it will be {4,5,6,7}.
	--
	-- The fix (workaround?) is to copy the contents of app.range.cels
	-- into our own custom table then sort that by frameNumber.
	local cels = {}
	for _,cel in ipairs(app.range.cels) do
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

	-- do similarly with frames
	local frames = {}
	for _,frame in ipairs(app.range.frames) do table.insert(frames, frame.frameNumber) end
	table.sort(frames)
	-- --------------------------------------------

	-- ---------------------------------------------------------------
	-- Step 2: determine how much we're actually shifting

	-- the selected range of cels could have empty frames where there is no cel
	-- for example, frames        1,   2,   3,   4,   5
	-- could have data like     cel, cel, nil, cel, cel
	--
	-- our custom cels table will only have data for the four cels, so we
	-- need to determine the actual range of frames (rather than assuming #cels is correct)

	local num_frames = #frames
	local first_frameNum = frames[1]
	local last_frameNum  = frames[num_frames]

	local shift_amt = dlg.data.shift_amt % num_frames

	-- there's no need to go any further if no shifting is needed
	-- just return early from ShiftCels now
	if shift_amt == 0 then return end

	-- --------------------------------------------
	-- Step 3: loop through the range of frameNumbers, creating new cels in
	--   the timeline where a shift should occur, and deleting existing data
	--   in the event of shifting an empty cel

	local cels_index = 1

	-- loop from startFrame to endFrame in increments of 1
	-- if the range of frameNumbers is {2,3,nil,5,6}
	--    this loop will give us 2,3,4,5,6
	--    we can use frameNumbers to check for nil cels and delete data (as part of the shift) if needed
	for i=first_frameNum, last_frameNum, 1 do

		-- calculate the destination frameNumber
		-- this is a messy but necessary calculation to handle ranges of cels that:
		--    a. likely don't start at frameNumber 1
		--    b. might need to wrap
		--
		-- subtract first_frameNum to accomodate (a.)
		-- add shift_amt because that's what we're trying to do
		-- modulo by num_frames to handle (b.)
		-- add first_frameNum back to undo the subtraction needed in (a.) to not throw off the modulo in (b.)
		local dest_frameNum = (((i-first_frameNum)+shift_amt) % num_frames) + first_frameNum

		-- if we're at a frameNumber in our loop where there is no corresponding cel data...
		if ((cels[cels_index] == nil) or (i ~= cels[cels_index].frameNumber)) then
			-- and if there is cel data at the destination cel...
			local cel = app.activeLayer:cel(dest_frameNum)
			-- ...then delete that cel data
			if cel then app.activeSprite:deleteCel( cel ) end

		else
			local cel = cels[cels_index]

			-- create a new cel using cloned image data
			-- sprite:newCel() takes 4 args:
			--   1. layer to create the new cel in
			--   2. the frame to create the new cel on
			--   3. the image we want to be in this new cel
			--   4. position data (a table of xy values) for this new cel
			app.activeSprite:newCel(
				app.activeLayer,
				app.activeSprite.frames[ dest_frameNum ],
				cel.image,
				cel.position
			).color = cel.color
			-- cel:newCel() will return the newly created cel object,
			-- so chain on one exta operation — set the color of the new cel in the timeline


			-- we've successfully added a new cel to the timeline
			-- increment cels_index so we can attempt to add the next cel in the next pass of the loop
			cels_index = cels_index + 1
		end
	end

	-- ---------------------------------------------------------------
	-- after the loop is done, set activeFrame to the new "first frame"
	-- that we moved the entire range to
	-- (this is commented out for now; uncomment if this behavior is preferred)

	-- app.activeFrame = app.activeSprite.frames[first_frameNum]
	-- ---------------------------------------------------------------

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
