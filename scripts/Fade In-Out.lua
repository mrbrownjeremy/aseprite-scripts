---------------------------------------------------------------
-- Fade In/Out
--
-- Call this script when a single Layer or Cel is selected and you'll be
-- prompted for:
--  • a quantity of frames (number input)
--  • whether you want to fadeIn or fadeOut (button press)
--
-- Note that this only operates on a single Layer at a time.
--
-- author: quietly-turning
-- github: https://github.com/quietly-turning/
---------------------------------------------------------------

if not app then return end
if not (app.isUIAvailable and app.activeCel) then return end

---------------------------------------------------------------
-- helper functions

local Scale = function(val, low1, high1, low2, high2)
	return ((val - low1) * ((high2 - low2) / (high1 - low1)) + low2)
end

local Clamp = function(val, low, high)
	if val < low  then return low  end
	if val > high then return high end
	return val
end

---------------------------------------------------------------

local dlg = Dialog("Fade In/Out")

local start_opacity = nil
local end_opacity   = nil

---------------------------------------------------------------

local Check = function(frame_count)
	local errors = {}

	if dlg.data.frame_count <= 0 then errors[#errors+1] = "Number of frames must be greater than 0." end
	if not app.activeLayer then errors[#errors+1] = "You need to have an activeLayer." end
	if not app.activeCel   then errors[#errors+1] = "You need to have an activeCel." end

	return errors
end

local ApplyFade = function()
	local start_frame = app.activeCel.frameNumber or 1
	local frame_count = dlg.data.frame_count
	frame_count = Clamp(start_frame+(frame_count-1), start_frame, #app.activeSprite.frames)

	local errors = Check(frame_count)
	-- if there were errors
	if #errors > 0 then
		-- print them
		for _,msg in ipairs(errors) do print(msg) end
		-- and return early from ApplyFade()
	 	return
	end



	for i=0, frame_count-1 do
		local cel = app.activeLayer:cel( start_frame + i - 1 )
		if cel then
			cel.opacity = Scale(i, 1, frame_count-1, start_opacity, end_opacity)
		end
	end

	app.refresh()
end

---------------------------------------------------------------

dlg:label({
	id = "activeLayer_name",
	label = "Active Layer: ",
	text = app.activeLayer and app.activeLayer.name or "",
})

dlg:number({
	id = "frame_count",
	label = "   Frames:",
	text = "",
	focus = true,
	-- update the range label when frame_count changes
	onchange=function()
		local range_text

		if dlg.data.frame_count > 0 then
			local s = app.activeCel.frameNumber
			local e = Clamp(s+(dlg.data.frame_count-1), s, #app.activeSprite.frames)
			range_text = ("%d – %d"):format(s, e)
		else
			range_text = ""
		end

		dlg:modify({
			id="range_label",
			text=range_text
		})
	end
})

dlg:label({
	id = "range_label",
	label = "   Range:",
	text = "",
})

dlg:button({
	id = "FadeOut_button",
	text = "Fade Out",
	onclick = function()
		start_opacity = 255
		end_opacity   = 0
		app.transaction( ApplyFade )
	end
})

dlg:button({
	id = "FadeOut_button",
	text = "Fade In",
	onclick = function()
		start_opacity = 0
		end_opacity = 255
		app.transaction( ApplyFade )
	end
})

-- allow the user to continue to interact with Aseprite while this dialog is up
dlg:show({wait=false})
