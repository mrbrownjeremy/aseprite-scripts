---------------------------------------------------------------
-- Duplicate Layers (without appending "Copy" to new layer)
---------------------------------------------------------------

if not (app and app.range) then return end
if not app.range.type == RangeType.LAYERS then return end

---------------------------------------------------------------

local Duplicate = function()
	-- duplicate whatever layers are currently selected
	app.command.DuplicateLayer()

	-- remove " Copy" from activeLayer name
	app.activeLayer.name = app.activeLayer.name:gsub(" Copy", "")
end

-- call our custom Duplicate function as a transaction so that both the
-- layer duplication and renaming can be undone together if needed
app.transaction( Duplicate )