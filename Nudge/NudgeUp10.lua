NudgeModule = (NudgeModule and type(NudgeModule)=="table" and NudgeModule.dir) and NudgeModule or dofile("Nudge.lua")
NudgeModule.dir = "up"
NudgeModule.amt = 10
app.transaction( NudgeModule.nudge )