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
	[10] = 0.2,
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

    self.bodyObj,self.bodyRenderer,self.bodyFrameCnfg,self.bodyAtlas= self:addBody(10002)
    self.weaponObj,self.weaponRenderer,self.weaponFramesCnfg,self.weaponAtlas= self:addWeapon(40011)
    self.wingObj,self.wingRenderer,self.wingFrameCnfg,self.wingAtlas = self:addWing(30003)
    self.hatObj,self.hatRenderer,self.hatFrameCnfg,self.hatAtlas = self:addHat(60001)

	self.lastAction = nil
end

function addBody(self,id)
	local obj = GameObject.create("Body")
	local renderer = obj:addComponent("SpriteRenderer")
	renderer.sortingLayerName="SceneObject"
	obj:setParent(self.gameObject.transform)
	obj:setScale(1,1,1)

	local atlas =  Resources.Load("SpriteAtlas/Model/Hero/"..id,typeof(UnityEngine.U2D.SpriteAtlas))
	renderer.sprite = atlas:GetSprite("1_0_0")
	local cnfg = require("frames.model.hero."..id)
	local frameCnfg = {}

	for k,v in pairs(cnfg) do
		for k1,v1 in pairs(v.frames) do
			frameCnfg[k1] = v1
		end
	end
	return obj,renderer,frameCnfg,atlas
end

function addWeapon(self,id)
	local obj = GameObject.create("Weapon")
	local renderer = obj:addComponent("SpriteRenderer")
	renderer.sortingLayerName="SceneObject"
	obj:setParent(self.gameObject.transform)
	obj:setScale(1,1,1)

    local atlas = Resources.Load("SpriteAtlas/Model/Weapon/"..id,typeof(UnityEngine.U2D.SpriteAtlas))
	renderer.sprite = atlas:GetSprite("1_0_0")
	renderer:setParent(self.gameObject.transform)
	obj:setScale(1,1,1)

	local cnfg = require("frames.model.weapon."..id)
	local frameCnfg = {}

	for k,v in pairs(cnfg) do
		for k1,v1 in pairs(v.frames) do
			frameCnfg[k1] = v1
		end
	end
	return obj,renderer,frameCnfg,atlas
end

function addHat(self,id)
	local obj = GameObject.create("Hat")
	local renderer = obj:addComponent("SpriteRenderer")
	renderer.sortingLayerName="SceneObject"
	obj:setParent(self.gameObject.transform)
	obj:setScale(1,1,1)

    local atlas = Resources.Load("SpriteAtlas/Model/Hat/"..id,typeof(UnityEngine.U2D.SpriteAtlas))
	renderer.sprite = atlas:GetSprite("1_0_0")
	renderer:setParent(self.gameObject.transform)
	obj:setScale(1,1,1)

	local cnfg = require("frames.model.hat."..id)
	local frameCnfg = {}

	for k,v in pairs(cnfg) do
		for k1,v1 in pairs(v.frames) do
			frameCnfg[k1] = v1
		end
	end
	return obj,renderer,frameCnfg,atlas
end

function addWing(self,id)
	local obj = GameObject.create("Wing")
	local renderer = obj:addComponent("SpriteRenderer")
	renderer.sortingLayerName="SceneObject"
	obj:setParent(self.gameObject.transform)
	obj:setScale(1,1,1)

    local atlas = Resources.Load("SpriteAtlas/Model/Wing/"..id,typeof(UnityEngine.U2D.SpriteAtlas))
	renderer.sprite = atlas:GetSprite("1_0_0")
	renderer:setParent(self.gameObject.transform)
	obj:setScale(1,1,1)

	local cnfg = require("frames.model.wing."..id)
	local frameCnfg = {}

	for k,v in pairs(cnfg) do
		for k1,v1 in pairs(v.frames) do
			frameCnfg[k1] = v1
		end
	end
	return obj,renderer,frameCnfg,atlas
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

    local key 
    if action == ACTION.ATTACK_READY then
    	key = string.format("%s_%s_%s",ACTION.ATTACK,WAY_TO_RESWAY[way],0)
    else
    	key = string.format("%s_%s_%s",action,WAY_TO_RESWAY[way],index)
    end

	self:drawBody(key,way)
	self:drawWeapon(key,way)
	self:drawWing(key,way)
	self:drawHat(key,way)

	if way > 2 and way<6 then
		self.wingRenderer.sortingOrder = 1
		self.bodyRenderer.sortingOrder = 2
		self.weaponRenderer.sortingOrder =  4
		self.hatRenderer.sortingOrder = 3
	else
		self.weaponRenderer.sortingOrder = 1
		self.bodyRenderer.sortingOrder = 2
		self.wingRenderer.sortingOrder = 3
		self.hatRenderer.sortingOrder =  4
	end

	self.gameObject:setPos(self.soul.y,self.soul.x)
end

function drawBody(self,key,way)
	local cnfg = self.bodyFrameCnfg[key..".png"]
    local offsetX  = (cnfg.sourceSize.w/2-cnfg.spriteSourceSize.x)
	local offsetY  = (cnfg.sourceSize.h/2-cnfg.spriteSourceSize.y)
	if way>4 then
		self.bodyObj:setScale(-1,1,0)
		self.weaponObj:setScale(-1,1,0)
	else
		self.bodyObj:setScale(1,1,0)
		self.weaponObj:setScale(1,1,0)
		offsetX = -offsetX
	    offsetY = offsetY
	end

	self.bodyRenderer.sprite = self.bodyAtlas:GetSprite(key)
	self.bodyRenderer:setPos(offsetX,offsetY,0)
end

function drawWeapon(self,key,way)
	local cnfg = self.weaponFramesCnfg[key..".png"]
	local offsetX  = (cnfg.sourceSize.w/2-cnfg.spriteSourceSize.x)
	local offsetY  = (cnfg.sourceSize.h/2-cnfg.spriteSourceSize.y)
	if way>4 then
		self.weaponObj:setScale(-1,1,0)
	else
		self.weaponObj:setScale(1,1,0)
		offsetX = -offsetX
		offsetY = offsetY
	end

	self.weaponRenderer.sprite = self.weaponAtlas:GetSprite(key)
	self.weaponRenderer:setPos(offsetX,offsetY,0)
end	

function drawWing(self,key,way)
	local cnfg = self.wingFrameCnfg[key..".png"]
	local offsetX  = (cnfg.sourceSize.w/2-cnfg.spriteSourceSize.x)
	local offsetY  = (cnfg.sourceSize.h/2-cnfg.spriteSourceSize.y)
	if way>4 then
		self.wingObj:setScale(-1,1,0)
	else
		self.wingObj:setScale(1,1,0)
		offsetX = -offsetX
		offsetY = offsetY
	end

	self.wingRenderer.sprite = self.wingAtlas:GetSprite(key)
	self.wingRenderer:setPos(offsetX,offsetY,0)
end

function drawHat(self,key,way)
	local cnfg = self.hatFrameCnfg[key..".png"]
	local offsetX  = (cnfg.sourceSize.w/2-cnfg.spriteSourceSize.x)
	local offsetY  = (cnfg.sourceSize.h/2-cnfg.spriteSourceSize.y)
	if way>4 then
		self.hatObj:setScale(-1,1,0)
	else
		self.hatObj:setScale(1,1,0)
		offsetX = -offsetX
		offsetY = offsetY
	end

	self.hatRenderer.sprite = self.hatAtlas:GetSprite(key)
	self.hatRenderer:setPos(offsetX,offsetY,0)
end

function getType(self)
	return "HumanVessel"
end