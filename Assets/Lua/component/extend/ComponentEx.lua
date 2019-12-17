local base = getmetatable(UnityEngine.Component)
local baseMetatable = getmetatable(base)

setmetatable(base,nil)

local tempVer3 = {}
local transformCache ={}

local function getTransform(self)
	local transform = transformCache[self]
	if not transform then
		transform = self.transform
		transformCache[self] = transform
	end
	return transform
end

-- 设置位置
function base.setPos(self, x, y, z)
	tempVer3.x = x
	tempVer3.y = y
	tempVer3.z = z
	getTransform(self).localPosition = tempVer3
end

function base.getPos()
	local pos = getTransform(self).localPosition
	return pos.x,pos.y,pos.z
end

function base.setSize(self,x,y)
	tempVer3.x = x
	tempVer3.y = y
	local rectTransform = self:getComponent("RectTransform")
	if not rectTransform then
		rectTransform = self:addComponent("RectTransform")
	end
	rectTransform.sizeDelta = tempVer3
end

function base.getSize(self)
	local size = self:getComponent("RectTransform").sizeDelta
	return sizeDelta.x,sizeDelta.y
end

function base.setScale(self,x,y,z)
	tempVer3.x = x
	tempVer3.y = y
	tempVer3.z = z
	getTransform(self).localScale = tempVer3
end

function base.getScale(self)
	local scale = getTransform(self).localScale
	return scale.x,scale.y,scale.z
end

function base.setRotate(self,x,y,z)
	tempVer3.x = x
	tempVer3.y = y
	tempVer3.z = z
	getTransform(self).localEulerAngles = tempVer3
end

function base.getRotate(self)
	local rotate  = getTransform(self).localEulerAngles
	return rotate.x,rotate.y,rotate.z
end

function base.setParent(self,parent,worldPositionStays)
	getTransform(self):SetParent(parent,worldPositionStays==true)
end

function base.addComponent(self,comName)
	return self.gameObject:AddComponent(CLASS_NAMES[comName])
end

function base.getComponent(self,comName)
	self:GetComponent(CLASS_NAMES[comName])
end

function base.addChild(self,child)
	self:addChildAt(getComponent(child),self.transform.childCount)
end

function base.addChildAt(self,child,index)
	local tf = getTransform(child)
	tf:SetParent(getTransform(self),worldPositionStays==true)
	tf:SetSiblingIndex(index)
end

function base.getChild(self,index)
	return getTransform(self):GetChild(index)
end

function base.getChildIndex(self,child)
	return getTransform(child):GetSiblingIndex()
end

function base.removeChild(self,child)
	getTransform(child):SetParent(nil,worldPositionStays==true)
end

setmetatable(base, baseMetatable)