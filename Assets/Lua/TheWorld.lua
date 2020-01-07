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
	joystick:AddListener(Event.ON_JOYSTICK_BASE_ATK,onJoystickAtkClick)
	joystick:AddListener(Event.ON_JOYSTICK_MOVE,onJoystickChange)
	joystick:AddListener(Event.ON_JOYSTICK_MOVE_END,onJoyStickEndDrag)

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
