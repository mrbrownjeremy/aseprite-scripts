---------------------------------------------------------------
-- Nudge
---------------------------------------------------------------

local NudgeModule = {}

NudgeModule.dir = nil
NudgeModule.amt = nil

NudgeModule.nudge = function()

	-- a table of functions, indexed by a string indicating direction
	-- calling any of these returns a table of new xy values appropriate for that direction
	local move = {
		left  = function(cel) return {x = cel.position.x - NudgeModule.amt, y=cel.position.y} end,
		right = function(cel) return {x = cel.position.x + NudgeModule.amt, y=cel.position.y} end,
		up    = function(cel) return {y = cel.position.y - NudgeModule.amt, x=cel.position.x} end,
		down  = function(cel) return {y = cel.position.y + NudgeModule.amt, x=cel.position.x} end,
	}


	if app.range then

		-- if a range of Cels is selected, Nudge each Cel
		if app.range.type == RangeType.CELS then
			for _, cel in ipairs(app.range.cels) do
				cel.position = move[NudgeModule.dir](cel)
			end

		-- if a range of Layers is selected, Nudge each Cel in each Layer
		elseif app.range.type == RangeType.LAYERS then
			for _, layer in ipairs(app.range.layers) do
				for _, cel in ipairs(layer.cels) do
					cel.position = move[NudgeModule.dir](cel)
				end
			end
		end
	end
end

return NudgeModule