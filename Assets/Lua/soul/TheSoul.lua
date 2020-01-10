class(...,require("base.EventDispatcher"))


local actionTime = 0.3
local delayTime  = 0.1
function ctor(self)
	self._x = -1
	self._y = -1
	self._way = -1
	self._hp = -1
	self._mp = -1
	self._maxHp = -1
	self._maxMp = -1

	self.action = ACTION.NONE
end

function onEnterScene(self)

end

function onExitScene(self)

end

function onInView(self)

end

function onOutView(self)

end

--property
function get.x(self)
	return self._x
end

function set.x(self,value)
	self._x = value
end

function get.y(self)
	return self._y
end

function set.y(self,value)
	self._y = value
end

function get.hp(self)
	return self._hp
end

function set.hp(self,value)
	self._hp = value
end

function get.maxHp(self)
	return self._maxHp
end

function set.maxHp(self,value)
	self._maxHp = value
end

function get.mp(self)
	return self._mp
end

function set.mp(self,value)
	self._mp = value
end

function get.maxMp(self)
	return self._maxMp
end

function set.maxMp(self,value)
	self._maxMp = value
end

function get.way(self)
	return self._way
end

function set.way(self,way)
	self._way = way
end

function get.speed(self)
	return self._speed
end	

function set.speed(self,value)
	self._speed = value
end

--status
function faceTo(self,vx,vy)
	local deg = math.deg(1)
	local offsetRadian = 90 / deg
	local radian = math.atan2(vy,vx) - offsetRadian
	self._way = math.floor((radian+11.388)/0.7854+4)%8
end

function getForward(self,dis)

end

function stand(self,x,y,way)
	local succ = self:enterAction(ACTION.STAND)
	print("stand =============",succ)
	if succ then
		self:onStand(x,y,way)
	end
end

function onStand(self,x,y,way)
	self._x =  x
	self._y =  y
	self._way = way
end

function run(self,sx,sy,tx,ty,way)
	local succ = self:enterAction(ACTION.RUN)
	if succ then
		self:onRun(sx,sy,tx,ty,way)
	end	
end

function onRun(self,sx,sy,tx,ty,way)
	self._x = tx
	self._y = ty
end

function attack(self)
	local succ = self:enterAction(ACTION.ATTACK)
	if succ then
		self:onAttack()
	end
end

function onAttack(self)

end

function dash(self,sx,sy,tx,ty)

end

function dashBack(self,sx,sy,tx,ty)

end

function hitBack(self,sx,sy,tx,ty)

end

function enterAction(self,action)
	if self.action ~= action then
		self.startTime = TimerLine.now
		self.endTime   =  self.startTime + actionTime + delayTime
	end
	self.action = action
	return true
end

function exitAction(self)
	self:enterAction(ACTION.STAND)
end

function updateAction(self)
	if self.action == ACTION.STAND then

	elseif self.action == ACTION.RUN then

	elseif self.action == ACTION.ATTCK then

	elseif self.action == ACTION.ATTACK_READY then

	elseif self.action == ACTION.CAST_SKILL then

	end
end

function onDataFrameUpdate(self)
	local now = TimerLine.now
	if self.endTime and now < self.endTime then
		self:updateAction()
	else
		self:exitAction()
	end
end

function isSingleShotAction(self,action)
	if action == ACTION.ATTACK then
		return true
	elseif action == ACTION.CAST_SKILL then
		return true
	else
		return false
	end
end

function getType(self)
	return "TheSoul"
end

