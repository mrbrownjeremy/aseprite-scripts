---------------------------------------------------------------
-- Align Layers
--
-- Call this script when one or more Layers is selected and the
-- pixel contents of each layer will be aligned to canvas center.
--
-- From there, you can use the Dialog to change the horizontal and
-- vertical alignment of both:
--   • the layers you are aligning
--   • what part of the canvas you are aligning them to
--
-- author: quietly-turning
-- github: https://github.com/quietly-turning/
---------------------------------------------------------------


---------------------------------------------------------------
-- helper function

local Clamp = function(val, low, high)
	if val < low  then return low  end
	if val > high then return high end
	return val
end


---------------------------------------------------------------
-- variables that need scope over the entire file

-- alignA, used for the thing we are aligning
-- alignB, used for the thing we are aligning alignA to
-- both tables are { horizontal, vertical } where
--   horizontal is a value from 0 (left) to 1 (right)
--   vertical   is a value from 0 (top)  to 1 (bottom)
--                h    v
local alignA = { 0.5, 0.5 }
local alignB = { 0.5, 0.5 }


local Align = function()

	---------------------------------------------------------------
	-- basic validation; exit early if conditions aren't right
	---------------------------------------------------------------

	-- ensure that at least 1 layer is active
	if #app.range.layers <= 0 then
		-- return early; there's nothing more we can do
		print("No layers are currently selected.")
		return
	end

	---------------------------------------------------------------
	-- variables that need to be declared prior to helper functions
	---------------------------------------------------------------

	local layers = {}

	local alignpoint
	local spr = app.activeSprite

	---------------------------------------------------------------
	-- helper functions
	---------------------------------------------------------------

	local FindInTable = function(needle, haystack)
		for i,v in ipairs(haystack) do
			if needle == v then return i end
		end
		return false
	end

	-- declare variable to be used as a function called recursively
	-- it needs to be declared separately from assignment for recursion to work
	local TraverseLayers

	TraverseLayers = function(_layers, BaseCaseFunc)
		for _, layer in ipairs(_layers) do
			if not FindInTable(layer, layers) then
				-- if this layer has sub-layers, it's a group
				-- recurse; continue traversing those sub-layers
				if layer.layers then
					TraverseLayers(layer.layers, BaseCaseFunc)

				-- if not, it has Cels
				-- base case; no futher children to recurse through
				else
					BaseCaseFunc(layer)
				end
			end
		end
	end

	---------------------------------------------------------------
	-- main logic
	---------------------------------------------------------------

	-- ---------------
	-- step 1: get array of layers

	TraverseLayers(app.range.layers, function(layer) table.insert(layers, layer) end)


	-- ---------------
	-- step 2: align

	local CalculateAlignPoint = function()
		if spr then
			alignpoint = {
				x = math.floor(spr.spec.width  * Clamp(alignB[2], 0, 1)),
				y = math.floor(spr.spec.height * Clamp(alignB[1], 0, 1))
			}
		end

		-- fallback values just in case
		if alignpoint == nil then
			print("No alignment point could be detected.\nFalling back on {0,0}")
			alignpoint = { x=0, y=0 }
		end
	end


	local AlignCelsInLayer = function(layer)

		-- update alignpoint now in case the user has changed it
		CalculateAlignPoint()

		-- loop through all Cels in this layer
		-- the "cel" variable will be a reference to the Aseprite Cel at index "i"
		--     "cel" will have its own properties that we can do things with
		for i, cel in ipairs(layer.cels) do
			-- modify this cel's x and y position
			cel.position = {
				x = alignpoint.x - (cel.bounds.width  * Clamp(alignA[2], 0, 1)),
				y = alignpoint.y - (cel.bounds.height * Clamp(alignA[1], 0, 1))
			}
		end
	end


	-- loop through layers comparing all Cels in each to find the largest Cel
	for _, layer in ipairs(layers) do AlignCelsInLayer(layer) end

	app.refresh()
end


---------------------------------------------------------------
-- code for the Dialog the user will see and interact with

local dlg = Dialog("Align")


dlg:label({text="selection alignment"})
:newrow()

-- alignA, the thing we are aligning
-- the alignA variable
:radio({
	id="alignA_topleft",
	selected=false,
	onclick=function() alignA = { 0, 0 }; app.transaction( Align ) end
})
:radio({
	id="alignA_topcenter",
	selected=false,
	onclick=function() alignA = { 0, 0.5 }; app.transaction( Align ) end
})
:radio({
	id="alignA_topright",
	selected=false,
	onclick=function() alignA = { 0, 1 }; app.transaction( Align ) end
})
:newrow()
:radio({
	id="alignA_middleleft",
	selected=false,
	onclick=function() alignA = { 0.5, 0 }; app.transaction( Align ) end
})
:radio({
	id="alignA_middlecenter",
	selected=true,
	onclick=function() alignA = { 0.5, 0.5 }; app.transaction( Align ) end
})
:radio({
	id="alignA_middleright",
	selected=false,
	onclick=function() alignA = { 0.5, 1 }; app.transaction( Align ) end
})
:newrow()
:radio({
	id="alignA_bottomleft",
	selected=false,
	onclick=function() alignA = { 1, 0 }; app.transaction( Align ) end
})
:radio({
	id="alignA_bottomcenter",
	selected=false,
	onclick=function() alignA = { 1, 0.5 }; app.transaction( Align ) end
})
:radio({
	id="alignA_bottomright",
	selected=false,
	onclick=function() alignA = { 1, 1 }; app.transaction( Align ) end
})

:separator()

-- alignB, the thing we are aligning alignA to
:label({text="align to"})
:newrow()


:radio({
	-- it's not documented anywhere I found
	-- but Aesprite's API for dialogs/widgets
	-- will only(?) start a new group of radio
	-- buttons when a label is encountered
	label="",

	id="alignB_topleft",
	selected=false,
	onclick=function() alignB = { 0, 0 } ; app.transaction( Align )end,
})
:radio({
	id="alignB_topcenter",
	selected=false,
	onclick=function() alignB = { 0, 0.5 }; app.transaction( Align ) end
})
:radio({
	id="alignB_topright",
	selected=false,
	onclick=function() alignB = { 0, 1 }; app.transaction( Align ) end
})
:newrow()
:radio({
	id="alignB_middleleft",
	selected=false,
	onclick=function() alignB = { 0.5, 0 }; app.transaction( Align ) end
})
:radio({
	id="alignB_middlecenter",
	selected=true,
	onclick=function() alignB = { 0.5, 0.5 }; app.transaction( Align ) end
})
:radio({
	id="alignB_middleright",
	selected=false,
	onclick=function() alignB = { 0.5, 1 }; app.transaction( Align ) end
})
:newrow()
:radio({
	id="alignB_bottomleft",
	selected=false,
	onclick=function() alignB = { 1, 0 }; app.transaction( Align ) end
})
:radio({
	id="alignB_bottomcenter",
	selected=false,
	onclick=function() alignB = { 1, 0.5 }; app.transaction( Align ) end
})
:radio({
	id="alignB_bottomright",
	selected=false,
	onclick=function() alignB = { 1, 1 }; app.transaction( Align ) end
})


-- allow the user to continue to interact with Aseprite while this dialog is up
dlg:show({wait=false})

---------------------------------------------------------------
-- perform an align now, immediately when the dialog is first seen by the user
-- all layers will be centered to canvas center
app.transaction( Align )