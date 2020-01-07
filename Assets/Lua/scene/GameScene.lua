class(...)

local BuildMap = require("scene.BuildMap")
local GameObject = UnityEngine.GameObject
local HumanVessel = require("scene.vessel.HumanVessel")
local Human  = require("soul.Human")
local Time = UnityEngine.Time

function ctor(self)
	self:createObject()
	self.accumilatedTime = 0 
	self.frame = 0
	self.vesselList = {}
end

function createObject(self)
	local go  = GameObject.create("GameScene")
	self.gameObject = go
	go.transform.parent = nil
end

function init(self,mapId,mapFile,event,callback)
	print("GameScene Init")
	self.isInited = true
	coroutine.start(BuildMap.init,self,mapFile,function() print("BuildMap End")end)
	print("GameScene Init End")
end

function add(self,vessel)
	table.insert(self.vesselList,vessel)
end

function del(self,vessel)

end

function onRenderFrameUpdate(self)
	if not self.isInited then
		return
	end
	
	for k,v in pairs(self.vesselList) do
		v:onUpdate()
	end
end
