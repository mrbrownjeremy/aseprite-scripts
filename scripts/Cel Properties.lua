local spr = app.activeSprite
if not spr then
  app.alert("There is no sprite to move")
  return
end
if not app.isUIAvailable then
    return
end

local isDebugMode = false
local checkNumber = 1

local colorRed =	Color{ r=254, g=91, b=89, a=255 }
local colorOrange =	Color{ r=247, g=165, b=69, a=255 }
local colorYellow =	Color{ r=243, g=206, b=82, a=255 }
local colorGreen =	Color{ r=106, g=205, b=91, a=255 }
local colorBlue =	Color{ r=87, g=185, b=242, a=255 }
local colorPurple =	Color{ r=209, g=134, b=223, a=255 }
local colorGrey =	Color{ r=165, g=165, b=167, a=255 }

function check(variable)
	if isDebugMode then
		print("Check "..checkNumber..": "..variable)
		checkNumber = checkNumber + 1;
	end
end

function setCelColor(inputColor)
	local cel = app.activeCel
	cel.color = inputColor
	app.refresh()
end

function setCelOpacity(opacity)
	local cel = app.activeCel
	cel.opacity = opacity
	app.refresh()
end

function dialogBox1(showHelp)

	check("dialogBox1 start")		
	check("Bounds")
	
	local dlg = Dialog("Cel Color")	
	
	-- local bounds = dlg.bounds
	-- dlg.bounds = Rectangle(bounds.x, bounds.y, 250, 100)
		
	if showHelp == true then
		dlg:label{ id="help", label="No help"}
	end --/if showHelp
	 
	-- dlg:slider{ id="celOpacity",
	--              label="Opacity: ",
	--              min=0,
	--              max=255,
	--              value=255,
	-- 			 focus=true,
	-- 		  }
			  
	dlg:button{text = "Re",	onclick=function() setCelColor(colorRed)	end }
	dlg:button{text = "Or",	onclick=function() setCelColor(colorOrange)	end }
	dlg:button{text = "Ye",	onclick=function() setCelColor(colorYellow)	end }
	dlg:button{text = "Gr",	onclick=function() setCelColor(colorGreen)	end }
	dlg:button{text = "Bl",	onclick=function() setCelColor(colorBlue)	end }
	dlg:button{text = "Pu",	onclick=function() setCelColor(colorPurple)	end }
	dlg:button{text = "Gr",	onclick=function() setCelColor(colorGrey)	end }

	  :show{wait=false}
	 
	 check("End dialogBox1()")
end
do
	app.transaction(function()
		dialogBox1(false)

		-- check("-END-")
	
	end)
end