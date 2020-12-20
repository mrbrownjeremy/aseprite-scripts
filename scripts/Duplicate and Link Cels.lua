---------------------------------------------------------------
-- Duplicate and Link Cels
--
-- author: quietly-turning
-- github: https://github.com/quietly-turning/
---------------------------------------------------------------

if not app then return end
if not (app.isUIAvailable and app.activeCel) then return end
if not app.range.type == RangeType.CELS then return end

---------------------------------------------------------------

local dlg = Dialog("Duplicate & Link")

---------------------------------------------------------------

local DupAndLink = function()
	local frame_count = dlg.data.frame_count - 1

	for i=1, frame_count do
		app.command.NewFrame({content=(dlg.data.LinkCels_checkbox and "cellinked" or "celcopies")})
	end

	app.activeCel = app.activeLayer:cel( app.activeCel.frameNumber - (dlg.data.ReturnToStart_checkbox and frame_count or 0) )

	app.refresh()
end

---------------------------------------------------------------

dlg:number({
	id = "frame_count",
	label = "   Num Frames:",
	text = "",
	focus = true,
	-- update the range label when frame_count changes
	onchange=function()
		local range_text

		if dlg.data.frame_count > 0 then
			range_text = ("%d – %d"):format(app.activeCel.frameNumber, app.activeCel.frameNumber+(dlg.data.frame_count-1))
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
	label = "          Range:",
	text = "",
})

dlg:separator()

dlg:check({
	id = "LinkCels_checkbox",
	label="       Link Cels:",
	selected=true,
})

dlg:check({
	id = "ReturnToStart_checkbox",
	label="Return to Start:",
	selected=true,
})


dlg:button({
	id = "DuplicateAndLink_button",
	text = "Duplicate",
	onclick = function() app.transaction( DupAndLink ) end
})



-- allow the user to continue to interact with Aseprite while this dialog is up
dlg:show({wait=false})
