---------------------------------------------------------------
-- Move to Canvas Center
--
-- author: quietly-turning
-- github: https://github.com/quietly-turning/
---------------------------------------------------------------

local MoveToCenter = function()

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
	-- initialization
	---------------------------------------------------------------

	local canvas_center_point
	local spr = app.activeSprite

	if spr then
		canvas_center_point = Point({
			x = spr.spec.width  // 2,
			y = spr.spec.height // 2,
		})
	end

	-- fallback values just in case
	if canvas_center_point == nil then
		print("The canvas center could not be detected.\nMoving to {0,0} instead.")
		canvas_center_point = Point({x=0, y=0})
	end

	local layers = {}

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
	-- moving a collection of layers to canvas center involves three steps:
	--
	-- 1. get an array of layers to process
	--      ideally, this is all selected layers, but the user may have a single
	--      "group" layer selected, and expects all children layers to be moved
	--
	-- 2. find the largest single cel
	--      we want to maintain each layer's cels' relative positioning to
	--      one another when moving
	--
	--      to do that, we need to find the largest single cel in the set of layers
	--      from step 1, calculate its distance from canvas center, and then move
	--      every cel to canvas center relative to it.
	--
	--      so, step 2 is to find the largest cel
	--
	-- 3. loop through each cel in each layer and move it


	-- ---------------
	-- step 1: get array of layers

	TraverseLayers(app.range.layers, function(layer) table.insert(layers, layer) end)


	-- ---------------
	-- step 2: find the largest single cel

	local largestcel_rectangle = nil

	local CompareCels = function(layer)
		for i, cel in ipairs(layer.cels) do
			if largestcel_rectangle == nil then
				largestcel_rectangle = Rectangle(cel.bounds)

			elseif (cel.bounds.width*cel.bounds.height) > (largestcel_rectangle.width*largestcel_rectangle.height) then
				largestcel_rectangle = Rectangle({
					x = cel.bounds.x,
					y = cel.bounds.y,
					width  = cel.image.width,
					height = cel.image.height,
				})
			end
		end
	end

	-- loop through layers comparing all Cels in each to find the largest Cel
	for _, layer in ipairs(layers) do CompareCels(layer) end


	-- ---------------
	-- step 3. loop through each cel in each layer and move it

	-- function used to loop through all cels in a layer and move them
	-- relative to the largestcel_rectangle's centerpoint (which is itself centered relative to the canvas center)
	local MoveCelsInLayer = function(layer)
		-- loop through all Cels in this layer
		for _, cel in ipairs(layer.cels) do
			-- modify this cel's xy position
			cel.position = {
				x = (cel.bounds.x - largestcel_rectangle.x - (largestcel_rectangle.width  // 2)) + canvas_center_point.x,
				y = (cel.bounds.y - largestcel_rectangle.y - (largestcel_rectangle.height // 2)) + canvas_center_point.y,
			}
		end
	end

	-- loop through layers and move each cel
	for _, layer in ipairs(layers) do MoveCelsInLayer(layer) end
end


---------------------------------------------------------------

-- transactions in asesprite are a way to group multiple actions
-- into a single Undo.
--
-- In this script, we loop through all cels in the activeLayer
-- and set the position of each as we go.  There would normally be
-- 1 undo action for each position update.  If a layer had 100 frames,
-- the user would need to tap control-Z (or command-Z) 100 times to
-- to undo the effect of this script.
--
-- If we wrap everything the script does in a Lua function, and pass
-- a reference to that function to app.transaction()
-- all the effects of that function will be grouped together as a single Undo.
--
-- Note that for app.transaction to work properly, you must pass a reference
-- to a function and not *call* a function.
--
-- So, this works because we're passing a reference to the MoveToCenter function itself,
-- rather than the results of calling MoveToCenter()
app.transaction( MoveToCenter )
