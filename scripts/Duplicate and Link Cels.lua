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
		app.command.NewFrame({content="cellinked"})
	end

	app.refresh()
end

---------------------------------------------------------------

dlg:number({
	id = "frame_count",
	label = "Num Frames:",
	text = "",
	focus = true,
})


dlg:button({
	id = "DuplicateAndLink_button",
	text = "Duplicate",
	onclick = function() app.transaction( DupAndLink ) end
})

-- allow the user to continue to interact with Aseprite while this dialog is up
dlg:show({wait=false})
