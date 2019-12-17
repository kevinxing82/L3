class(...)

local BuildMap = require("scene.BuildMap")
local GameObject = UnityEngine.GameObject

function createObject(self)
	local go  = GameObject.create("GameScene")
	self.gameObject = go
	go.transform.parent = nil
	return self
end

function init(self,mapId,mapFile,event,callback)
	print("GameScene Init")
	coroutine.start(BuildMap.init,self,mapFile,function() print("BuildMap End")end)
	print("GameScene Init End")
end

function addPlayer(self)
	local player  = GameObject.create("Player")
	player:setParent(self.gameObject.transform)
	local camera = GameObject.Find("Camera")
	camera:setParent(player.transform)
	player:setRotate(0,0,0)
end