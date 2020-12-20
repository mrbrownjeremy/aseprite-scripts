---------------------------------------------------------------
-- Change Selection Color Property
--
-- Use this script to quickly change the color of a range of
-- Layers or Cels within Aseprite's timeline.
--
-- This has buttons for six predefined colors.  Use the "-"
-- button to reset the selected range to the default color
-- for the current Aseprite theme.
--
-- author: quietly-turning
-- github: https://github.com/quietly-turning/
---------------------------------------------------------------

if not (app and app.isUIAvailable) then return end

---------------------------------------------------------------

local choices = {
	{ text="R", color=Color({ r=254, g=91,  b=89,  a=255 }) },
	{ text="O", color=Color({ r=247, g=165, b=69,  a=255 }) },
	{ text="Y", color=Color({ r=243, g=206, b=82,  a=255 }) },
	{ text="G", color=Color({ r=106, g=205, b=91,  a=255 }) },
	{ text="B", color=Color({ r=87,  g=185, b=242, a=255 }) },
	{ text="V", color=Color({ r=209, g=134, b=223, a=255 }) },
	{ text="-", color=Color({ r=0,   g=0,   b=0,   a=0   }) },
}

local dlg = Dialog("Change Color")

local active_choice = nil

---------------------------------------------------------------

local SetColor = function()
	local list = nil

	if     app.range.type == RangeType.CELS   then list = app.range.cels
	elseif app.range.type == RangeType.LAYERS then list = app.range.layers
	elseif app.range.type == RangeType.EMPTY  then list = { app.activeCel }
	end

	if list == nil then return end

	for i, item in ipairs(list) do
		item.color = active_choice
	end

	-- this variable has scope across the entire file
	-- (meaning, if we set it inside this function and access it elsewhere, the value sticks)
	-- reset it to nil now
	active_choice = nil

	app.refresh()
end

-- loop through choices array, adding one button for each
for _, choice in ipairs(choices) do
	dlg:button({ text=choice.text, onclick=function() active_choice=choice.color; app.transaction( SetColor ) end })
end

-- custom color picker
dlg:color({
	onchange=function(params)
		-- the "onchange" function for dialog's color picker
		-- is sent one parameter, a table indexed by a single
		-- key, "color", corresponding to the color the user chose
		--
		-- refer to the Dialog_color() definition in ./src/app/script/dialog_class.cpp
		active_choice=params.color
		app.transaction( SetColor )
	end
})

-- allow the user to continue to interact with Aseprite while this dialog is up
dlg:show({wait=false})
