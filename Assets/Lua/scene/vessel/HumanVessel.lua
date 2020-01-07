class(...,require("scene.vessel.TheVessel"))
local GameObject = UnityEngine.GameObject
local Resources = UnityEngine.Resources
local Human = require("soul.Human")
local Time = UnityEngine.Time
local Space = UnityEngine.Space

local ACTION_FRAMES={
	[1] = 4,
	[3] = 8,
	[4] = 5,
	[5] = 5
}
local ACTION_TIME={
	[1]  =0.2,
	[3] = 0.4,
	[4] = 0.3,
	[5] = 0.3,
}
local WAY_TO_RESWAY = {
	[0] = 0,
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 3,
	[6] = 2,
	[7] = 1,
 }

function ctor(self,soul)
	self.soul = soul
	self.gameObject = GameObject.create("Human")
	self.gameObject:setParent(GameObject.Find("GameScene").transform)
	self.gameObject:setRotate(0,0,0)

    self.bodyObj = GameObject.create("Body")
	self.bodyRenderer = self.bodyObj:addComponent("SpriteRenderer")
	self.bodyObj:setParent(self.gameObject.transform)
	self.bodyObj:setScale(1,1,1)

	self.weaponObj = GameObject.create("Weapon")
	self.weaponRenderer = self.weaponObj:addComponent("SpriteRenderer")
	self.weaponObj:setParent(self.gameObject.transform)
	self.weaponObj:setScale(1,1,1)

	self.bodyAtlas =  Resources.Load("SpriteAtlas/Model/Hero/10002",typeof(UnityEngine.U2D.SpriteAtlas))
	self.bodyRenderer.sprite = self.bodyAtlas:GetSprite("1_0_0")
	self.cnfg = require("frames.model.hero.10002")
	self.bodyFrameCnfg = {}

	for k,v in pairs(self.cnfg) do
		for k1,v1 in pairs(v.frames) do
			self.bodyFrameCnfg[k1] = v1
		end
	end

	self.lastAction = nil
end

function onUpdate(self)
	local action  = self.soul.action
	local way     = self.soul.way
	if action == ACTION.NONE then return  end
	local actionTotalFrame = ACTION_FRAMES[action] or 1
	local actionTime = ACTION_TIME[action] or 0.1

	if not self.lastAction or self.lastAction ~= action then
		self.lastAction = action
		self.actionStartTime = TimerLine.now
	end

	local isSingleShot = self.soul:isSingleShotAction(action)
	local index 
	local timeSpan =  TimerLine.now - self.actionStartTime
	if isSingleShot then
		if timeSpan*TimerLine.RenderFrameRate*actionTime / actionTotalFrame > 1 then
			index = actionTotalFrame
		else
			index   =math.floor(timeSpan*TimerLine.RenderFrameRate*actionTime%actionTotalFrame)
		end
	else
		index   =math.floor(timeSpan*TimerLine.RenderFrameRate*actionTime%actionTotalFrame)
	end

	local key = string.format("%s_%s_%s",action,WAY_TO_RESWAY[way],index)
	local cnfg = self.bodyFrameCnfg[key..".png"]
    local offsetX  = (cnfg.sourceSize.w/2-cnfg.spriteSourceSize.x)
	local offsetY  = (cnfg.sourceSize.h/2-cnfg.spriteSourceSize.y)
	if way>4 then
		self.bodyObj:setScale(-1,1,0)
	else
		self.bodyObj:setScale(1,1,0)
		offsetX = -offsetX
	    offsetY = offsetY
	end

	self.bodyRenderer.sprite = self.bodyAtlas:GetSprite(key)
	self.bodyRenderer:setPos(offsetX,offsetY,0)

	self.gameObject:setPos(self.soul.y,self.soul.x)
	
end

function getType(self)
	return "HumanVessel"
end