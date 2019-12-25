class(...)

local GameScene = require("scene.GameScene")
local GameObject = UnityEngine.GameObject
local Time = UnityEngine.Time
local EventManager = require("base.EventManager")

function run()
	print("The world running")

	EventManager.init()

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
	scene = GameScene:createObject()
	scene:init(mapId, mapFile, nil, callback)
	scene:addPlayer()
end

function exitScene()
	if scene then
		scene:destroy()
		scene = nil
	end
end

function initWorld()
	print("Init The World")
	enterScene(1,1,nil)
end

function onFixedUpdate()
	-- print("onFixedUpdate")
	EventManager.Notify("OnFixedUpdate")
	scene:onFixedUpdate()
end

function onUpdate()
	-- print("onUpdate")
	EventManager.Notify("OnUpdate")
	scene:onUpdate()
end
