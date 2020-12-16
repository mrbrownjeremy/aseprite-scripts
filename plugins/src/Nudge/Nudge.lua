---------------------------------------------------------------
-- Nudge
---------------------------------------------------------------

init = function(plugin)

	local dx, dy = 0, 0

	local Nudge = function()
		if app.range then

			-- if a range of Cels is selected, Nudge each Cel
			if app.range.type == RangeType.CELS then
				for _, cel in ipairs(app.range.cels) do
					cel.position = { x=cel.position.x+dx, y=cel.position.y+dy }
				end

			-- if a range of Layers is selected, Nudge each Cel in each Layer
			elseif app.range.type == RangeType.LAYERS then
				for _, layer in ipairs(app.range.layers) do
					for _, cel in ipairs(layer.cels) do
						cel.position = { x=cel.position.x+dx, y=cel.position.y+dy }
					end
				end
			end
		end

		app.refresh()
	end

	plugin:newCommand({
		id="NudgeLeft1",
		title="Nudge Left 1px",
		group="",
		onclick=function() dx=-1; dy=0; app.transaction( Nudge ) end
	})

	plugin:newCommand({
		id="NudgeDown1",
		title="Nudge Down 1px",
		group="",
		onclick=function() dx=0; dy=1; app.transaction( Nudge ) end
	})

	plugin:newCommand({
		id="NudgeUp1",
		title="Nudge Up 1px",
		group="",
		onclick=function() dx=0; dy=-1; app.transaction( Nudge ) end
	})

	plugin:newCommand({
		id="NudgeRight1",
		title="Nudge Right 1px",
		group="",
		onclick=function() dx=1; dy=0; app.transaction( Nudge ) end
	})

	plugin:newCommand({
		id="NudgeLeft10",
		title="Nudge Left 10px",
		group="",
		onclick=function() dx=-10; dy=0; app.transaction( Nudge ) end
	})

	plugin:newCommand({
		id="NudgeDown10",
		title="Nudge Down 10px",
		group="",
		onclick=function() dx=0; dy=10; app.transaction( Nudge ) end
	})

	plugin:newCommand({
		id="NudgeUp10",
		title="Nudge Up 10px",
		group="",
		onclick=function() dx=0; dy=-10; app.transaction( Nudge ) end
	})

	plugin:newCommand({
		id="NudgeRight10",
		title="Nudge Right 10px",
		group="",
		onclick=function() dx=10; dy=0; app.transaction( Nudge ) end
	})

end
