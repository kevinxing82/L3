class(...)

local BuildMap = require("scene.BuildMap")
local GameObject = UnityEngine.GameObject
local HumanObject = require("scene.obj.HumanObject")

function ctor(self)

end

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
	-- self.player  = GameObject.create("Player")
	-- self.player:setParent(self.gameObject.transform)
	self.player = HumanObject.new()
	local camera = GameObject.Find("Camera")
	camera:setParent(self.player.gameObject.transform)
end

function add(self,sceneObj)

end

function del(self,sceneObj)

end

function onFixedUpdate(self)

end

function onUpdate(self)
	self.player:onUpdate()
end

