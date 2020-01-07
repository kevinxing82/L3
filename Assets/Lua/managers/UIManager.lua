class(...)

local GameObject = UnityEngine.GameObject
local RectTransform = UnityEngine.RectTransform
local Edge = UnityEngine.RectTransform.Edge
local Vector2 = UnityEngine.Vector2

function ctor(self)
	self.canvas = GameObject.Find("Canvas")
	self.sortingOrder = -10
	self.layList = {}

	self.barLayer= self:createLayer("barLayer")
	self.barLayer:addComponent("Canvas")

	self.promptLayer = self:createLayer("promptLayer")
	self.promptLayer:addComponent("Canvas")

	self.effectLayger = self:createLayer("effectLayer")
	self.mainUILayer  = self:createLayer("mainUI")

	self.uiLayer   = self:createLayer("uiLayer")
	self.topLayer  = self:createLayer("topLayer")
	self.autoLayer = self:createLayer("autoLayer")
end

function createLayer(self,name)
	local layer = GameObject.create(name)
	self.canvas:addChild(layer)
	self.layList[layer]=layer

    local rect = layer:addComponent("RectTransform")
	rect:SetInsetAndSizeFromParentEdge(Edge.Top,0,0)
	rect:SetInsetAndSizeFromParentEdge(Edge.Bottom,0,0)
	rect:SetInsetAndSizeFromParentEdge(Edge.Left,0,0)
	rect:SetInsetAndSizeFromParentEdge(Edge.Right,0,0)
	rect.anchorMin = Vector2(0,0)
	rect.anchorMax = Vector2(1,1)
	return layer
end

function instance(self)
	if self._instance == nil then
		self._instance = self.new()
	end
	return self._instance
end