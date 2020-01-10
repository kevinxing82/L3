class(...)

local GameScene = require("scene.GameScene")
local GameObject = UnityEngine.GameObject
local Time = UnityEngine.Time
local Timer = require("base.Timer")
local HumanVessel =  require("scene.vessel.HumanVessel")
local GameInput = require("base.GameInput")
-- local EventManager = require("base.EventManager")
local UIManager  = require("managers.UIManager")
local Joystick = require("managers.Joystick")
local Event = require("base.Event")
local Human = require("soul.Human")

local soulList = {}
local isReady = false

function run()
	initWorld()
	local entry = GameObject.Find("Entry")
	local mainManager = entry:getComponent("MainManager")
	mainManager:OnFixedUpdateCallback(onFixedUpdate)
	mainManager:OnUpdateCallback(onUpdate)
end

function enterScene(mapId, mapFile, callback)
	if scene then
		scene:destroy()
	end	
	scene = GameScene.new()
	scene:init(mapId, mapFile, nil, callback)
end

function exitScene()
	if scene then
		scene:destroy()
		scene = nil
	end
end

function initWorld()
	_G.TimerLine = Timer:instance()

	UIManager:instance()
	enterScene(1,1,nil)
	createHero()
	input = GameInput.new()
	joystick = Joystick.new()
	joystick:init()
	joystick:AddListener(EVENT.ON_JOYSTICK_BASE_ATK,onJoystickAtkClick)
	joystick:AddListener(EVENT.ON_JOYSTICK_MOVE,onJoystickChange)
	joystick:AddListener(EVENT.ON_JOYSTICK_MOVE_END,onJoyStickEndDrag)
	joystick:AddListener(EVENT.ON_JOYSTICK_SKILL_1,onJoyStickSkill1)
	joystick:AddListener(EVENT.ON_JOYSTICK_SKILL_2,onJoyStickSkill2)
	joystick:AddListener(EVENT.ON_JOYSTICK_SKILL_3,onJoyStickSkill3)
	joystick:AddListener(EVENT.ON_JOYSTICK_SKILL_4,onJoyStickSkill4)

	isReady = true
end

function onJoystickAtkClick()
	input.onKey1()
end

function onJoystickChange(pos)
	input.joystick(pos.y,pos.x)
end

function onJoyStickEndDrag()
	input.joystickStop()
end

function onJoyStickSkill1()
	print("Use Skill1")
end

function onJoyStickSkill2()
	print("Use Skill2")
end

function onJoyStickSkill3()
	print("Use Skill3")
end

function onJoyStickSkill4()
	print("Use Skill4")
end

function addObj(soul)
	if soulList then
		table.insert(soulList,soul)
	end
	soul:stand(0,0,4)
	local vessel = createVessel(soul)
	scene:add(vessel)
	return vessel
end

function removeObj(obj)

end

function getHero()
	if scene then
		return heroicSoul
	end
end

function createVessel(soul)
	if soul:getType() == "Human" then
		return HumanVessel.new(soul)
	end
end

function onMsgFrameData(frame,frameData,hasData)
	--frame sync from sever
end

function onFixedUpdate()
	if not isReady then
		return
	end

    TimerLine:onFixedUpdate()
    updateSoul()
end

function createHero()
    heroicSoul   = Human.new()
    heroicSoul:stand(0,0,4)
    heroicVessel = addObj(heroicSoul)
	local camera = GameObject.Find("Camera")
	camera:setParent(heroicVessel.gameObject.transform)
end

function updateSoul()
	for i,v in ipairs(soulList) do
		v:onDataFrameUpdate()
	end
end

function onUpdate()
	if not isReady then
		return
	end

	if scene then
		input:onUpdate()
		TimerLine:onUpdate()
		scene:onRenderFrameUpdate()
	end
end
