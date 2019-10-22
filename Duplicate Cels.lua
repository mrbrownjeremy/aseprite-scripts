--[[-----------------------------------------
--  Duplicate Cels.lua
--[[-----------------------------------------

	Duplicates active cel an amount of times equal
	to user prompt. 

	Options: 
	- Return to Starting Cel
	- Retain Cel Color

----------------------------------------------]]

local spr = app.activeSprite

if not spr then
  app.alert("There is no sprite to move")
  return
end
if not app.isUIAvailable then
    return
end

local startingCel = app.activeCel -- not sure why, but this needs to be global
	
function getCelCoordinates(cel) --TODO
	celFrameNumber = cel.frameNumber
	celLayerNumber = cel.layer
	return celCoordinates
end

function getCelColor(cel)
	if cel.color ~= nil then
		celColor = cel.color
		return celColor
	end
end

function duplicateCels()
	app.transaction(function() -- allows single Undo

		-------------------------------------------
		-- INITIALIZE
		-------------------------------------------

		-- SET current frame and layer objects 
			local currentFrame = app.activeFrame
			local currentLayer = app.activeLayer

		-- SET frame and layer Numbers
			local numOfFramesInSprite = #spr.frames
			local numOfLayersInSprite = #spr.layers

			local currentFrameNumber = currentFrame.frameNumber	
			local nextFrameNumber = currentFrameNumber + 1
			local currentLayerNumber = 1 --don't know how to get this TODO
			local nextLayerNumber = currentLayerNumber + 1
	
		-- SET image and cel objects
			local img = startingCel.image:clone()			
			local nextCel = app.activeCel


		-- SET starting Cel
			if currentLayer:cel(currentFrameNumber) == nil then
				app.alert {title="Duplicate Cels", text="Error: Active cel is empty. This script requires the active cel to contain pixels."}
			else
				startingCel = app.activeCel			
				if not startingCel then
				  return app.alert("There is no active image")
				end
			end
	
		-------------------------------------------
		-- EXECUTE
		-------------------------------------------
			
			startingCel.data = "Duplicated Cel(s)"

			nextCel =  spr:newCel(currentLayer, nextFrameNumber, img, startingCel.position)
			
			-- nextCel.color = getCelColor(startingCel)

	end) --/transaction duplicateCels()
end --/function duplicateCels()

function repeatDuplicateCels(numTimesDuplicate)
	app.transaction(function() -- allows single Undo

		for i = 1, numTimesDuplicate do
			duplicateCels()
			app.command.GotoNextFrame() 
			-- TODO try different method of frame changing
		end
	
		for i = numTimesDuplicate, 1,-1 do
			app.command.GotoPreviousFrame()
		end
	
	end) --/transaction repeatDuplicateCels()
end --/function repeatDuplicateCels()

local dlg = Dialog("Duplicate Cel")

dlg:number{
		id="inputNumTimesDup", 
		label="Amt Dup:", 
		text="1", 
		focus=true 
	} -- Input Times to Duplicate

	:check{
		id="inputReturnToStartingCel",
		text="Return to Starting Cel",
		selected=true
	} -- Checkbox inputReturnToStartingCel
	
	:newrow()
	
	:check{
		id="inputRetainCelColor",
		text="Retain Cel Color",
		selected=false
	} -- Checkbox inputRetainCelColor
	
	:separator()---------------
	
	:button{
		text="&Duplicate",
		focus=true,
		onclick=function() 
			repeatDuplicateCels(math.floor(dlg.data["inputNumTimesDup"]))
			dlg:close()
		end
	} -- Duplicate

	:button{
		text="&Close" 
	} -- Close
	
	:show()