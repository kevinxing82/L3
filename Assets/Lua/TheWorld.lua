class(...)

local GameScene = require("scene.GameScene")

function run()
	print("The world running")
	initWorld()
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
