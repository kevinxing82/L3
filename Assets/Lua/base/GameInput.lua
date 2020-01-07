class(...,require("base.EventDispatcher"))

local Input = UnityEngine.Input
local EventSystem = UnityEngine.EventSystems.EventSystem
local TouchPhase = UnityEngine.TouchPhase
local KeyCode = UnityEngine.KeyCode

KEY1 = 1
KEY2 = 2
KEY3 = 3
KEY4 = 4
KEY5 = 5

function ctor(self)
	self.isWin = os.getenv("OS")=="Windows_NT"
	self.enableSteering = true
	self.lastHardwardInput = false
end

function onUpdate(self)
	--UI process

	-- clicked = false
 --    mousePosition = false

	-- local isClickUI
	-- if self.isWin then
	-- 	if Input.GetMouseButtonDown(0) then
	-- 		self.isMouseDown = not EventSystem.current:IsPointerOverGameObject()
	-- 	elseif Input.GetMouseButtonUp(0) then
	-- 		if not EventSystem.current:IsPointerOverGameObject() then
	-- 			isClickUI = true
	-- 		end
	-- 		self.isMouseDown = false
	-- 	end
	-- else
	-- 	if Input.touchCount > 9 then
	-- 		local touch = Input.GetTouch(0)
	-- 		if touch.phase == TouchPhase.Begin  then
	-- 			isClickUI = not EventSystem.current:IsPointerOverGameObject(touch.fingerId)
	-- 			if isClickUI then
	-- 				self.isMouseDown = true
	-- 			end
	-- 		end
	-- 	else
	-- 		self.isMouseDown = false
	-- 	end
	-- end

	-- if isClickUI then
	-- 	local mousePos = Input.mousePosition
	-- end

	-- if sef.isMouseDown then

	-- end
	local dx = Input.GetAxis("Vertical")
	local dy = Input.GetAxis("Horizontal")
	local hasHardwareInput

	if dx == 0 and dy == 0 then
		hasHardwareInput = false
	else
		hasHardwareInput = true
	end

	if self.lastHardwardInput and not hasHardwareInput then
		self:joystickStop()
	end

	if hasHardwareInput then
		self.joystick(dx,dy)
	end

	self.lastHardwardInput = hasHardwareInput
end

 function joystick(self,dx,dy)
 	if not self.enableSteering then return end
 	-- if not hero then return end
 	self.dx = dx
 	self.dy = dy
 	if not TimerLine:has(self.onJoystick) then
 		TimerLine:add(self.onJoystick,0.05,true)
 	end
 end

function joystickStop(self)
	local hero = World.getHero()
	if not self.dx then
		self.dx = 0
	end
	if not self.dy then
		self.dy = 0 
	end
	hero:faceTo(self.dx,self.dy)
	hero:stand(hero.x,hero.y,hero.way)
	 if TimerLine.has(self.onJoystick) then
	 	TimerLine.remove(self.onJoystick)
	 end
end

function clearJoystickState(self)

end

function onJoystick(self)
	-- print(self.dx,self.dy)
	local hero = World.getHero()
	hero:faceTo(self.dx,self.dy)
	local speed = 16
	local sx = hero.x
	local sy = hero.y
	local tx = hero.x + self.dx*speed
	local ty = hero.y + self.dy*speed
	hero:run(sx,sy,tx,ty,hero.way)

	self.lastDx = self.dx
	self.lastDy = self.dy
end

--main skill
function onKey1(self)
	local hero = World.getHero()
	hero:attack()
end
--skill2
function onKey2(self)

end

function onKey3(self)

end

function onKey4(self)

end

function onKey5(self)

end