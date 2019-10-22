--[[-----------------------------------------
--  Scrolling.lua
--[[-----------------------------------------

	Create scrolling effects within a sprite file

	Example use cases: 
		- scroll scenery, 
		- make characters move across screen

	Shift pixels by "Amt Shift" every "Fraction" cels 
	in "Shift Direction", starting at the selected cel and going 
	until "Frame Count".

	Conceived of as fractional movement per cel 
	(e.g. move 1/4 of a pixel per cel, which translates 
	to move 1 pixel every 4 cels)

	Movement begins from (but does not include) the SELECTED FRAME.

	"Fraction" can be thought of as the denominator 
	for fractional movement.

-- TODO Include Radio option to use same image for each cel
-- invokes DuplicateCels()

----------------------------------------------]]

local spr = app.activeSprite  
if not spr then
  app.alert("There is no sprite to move")
  return
end

if not app.isUIAvailable then
    return
end

function activeCelisNil()
	
	local celisNil = true
	
	if app.activeCel ~= nil then
		celisNil = false
	end
	
	return celisNil
	
end

function moveCelContents(xMove, yMove)
	
	if not activeCelisNil() then
		
		local curCel = app.activeCel
		curCel.position = {
			x = curCel.position.x + xMove,
			y = curCel.position.y + yMove
		}
		
	end
	
end

--TODO
function determineScrollingMath()
	-- for easing in / out
	-- may be needed to break apart createScrollingEffect() at some point
		-- can def make "prevAmtScroll + amtScroll" into function
		-- can use Easing In / Out radio boxes to change maths
end

function createScrollingEffect(amtScroll, frames, everyXframes, direction)
	
	app.transaction(function() -- transactions = single Undo
		
		local prevAmtScroll = 0 		
		local scrollMultiplier = 1
		local startingFrame = app.activeFrame
		
		app.command.GotoNextFrame() -- starts scroll on next frame

		for i=1,frames do
			
			
			app.command.UnlinkCel()	
				
				
			if direction == "right" then
				moveCelContents(prevAmtScroll + amtScroll,0)
			elseif direction == "left" then
				moveCelContents((prevAmtScroll + amtScroll)*-1,0)
			elseif direction == "up" then
				moveCelContents(0, (prevAmtScroll + amtScroll)*-1)
			elseif direction == "down" then
				moveCelContents(0, prevAmtScroll + amtScroll)
			else
				app.alert{title="Error", text={"Invalid direction set:", direction}, buttons="OK"}
			end --/if direction
				
			
			if (i % everyXframes) == 0 then 
				-- everyXframes = scroll only every Xth frame
				-- good for slow scrolling objects (e.g. clouds)
				-- when it equals 1, this code doesn't impact anything
				prevAmtScroll = amtScroll * scrollMultiplier
				scrollMultiplier = scrollMultiplier + 1
			end --/if everyXframes
			
			
			app.command.GotoNextFrame() -- hack


			if i == frames then
				
				-- TODO make going back an optional
				while i > 0 do -- returns to starting frame
				-- TODO use exact cel ref at some point

					app.command.GotoPreviousFrame() 
					i = i - 1
					
				end --/while i>1
				
				app.command.GotoPreviousFrame() -- back to starting frame

			end --/if i==frames
			
		end --/for frames
		
	end) --/transaction
	
end -- /createScrollingEffect()

do -- main
	local dlg = Dialog("Create Scrolling Effect")

	dlg:number{
			id="inputAmtScroll", 
			label="Pixels to Scroll (per frame):", 
			text="1", 
			focus=true 
		} -- Amount to Scroll
			
		:number{
			id="inputNumFrames", 
			label="No. frames to apply scroll:", 
			text="4"
		} -- Number Frames
			
		:separator()---------------
		
		:number{
			id="everyXframes",
			label="Scroll every _ frame(s):",
			text="1"
		} -- Every X frames
		
		:separator()---------------
		
		:button{
			label="Click direction to execute",
			id="shiftLeft", 
			text="&Left",
			onclick=function()
				createScrollingEffect(
					math.floor(dlg.data["inputAmtScroll"]),
					math.floor(dlg.data["inputNumFrames"]),
					math.floor(dlg.data["everyXframes"]),
					"left"
				)
			end
		} -- Shift Left 
		
		:button{
			id="shiftDown", 
			text="&Down",
			onclick=function()
				createScrollingEffect(
					math.floor(dlg.data["inputAmtScroll"]),
					math.floor(dlg.data["inputNumFrames"]),
					math.floor(dlg.data["everyXframes"]),
					"down"
			)
			end
		} -- Shift Down
		
		:button{
			id="shiftUp", 
			text="&Up",
			onclick=function()
				createScrollingEffect(
					math.floor(dlg.data["inputAmtScroll"]), math.floor(dlg.data["inputNumFrames"]),
					math.floor(dlg.data["everyXframes"]), 
					"up"
				)
			end
		} -- Shift Up
		  
		:button{
			id="shiftRight", 
			text="&Right",
			onclick=function()
				createScrollingEffect(
					math.floor(dlg.data["inputAmtScroll"]),
 					math.floor(dlg.data["inputNumFrames"]),
					math.floor(dlg.data["everyXframes"]),
					"right")
			end
		} -- Shift Right
		  
		
		:check{
			id="returnToStartingCel",
			text="Return to Starting Cel",
			selected=true
		} -- Check returnToStartingCel
		
		:separator()---------------
		

		:button{
			text="&Undo",
			onclick=function() 
				app.command.Undo() 
			end
		} -- Undo

		:button{
			text="&Close" 
		} -- Close


		-------------------------------------------
		-- Control Aseprite or Dialog
		-------------------------------------------
		
		-- TODO toggle for show() and show{wait=false}; prob using app.refresh
		
		-- :show() -- Can Tab through dialog, Cannot interact with Ase interface

		:show{wait=false} -- Can interact w/ Ase, but can't Tab dialog
		
		
		
	-- end dlg
	
	
end --/do main