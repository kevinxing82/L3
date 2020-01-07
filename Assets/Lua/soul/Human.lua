class(...,require("soul.TheSoul"))

function ctor(self)
	super.ctor(self)
end

function enterAction(self,action)
	super.enterAction(self,action)
	local curAction = self.action
	if curAction == ACTION.ATTCK or curAction == ACTION.CAST_SKILL then
		if self.endTime > TimerLine.now then
			--action running
			return false
		end
	end

	return true
end

function exitAction(self)
	if self.action == ACTION.ATTACK then
		self:enterAction(ACTION.ATTACK_READY)
	else
		self:enterAction(ACTION.STAND)
	end
end

function updateAction(self)

end

function onDataFrameUpdate(self)
	super.onDataFrameUpdate(self)
end

function getType(self)
	return "Human"
end