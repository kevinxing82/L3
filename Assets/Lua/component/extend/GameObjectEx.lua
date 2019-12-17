local super = getmetatable(UnityEngine.Component)
local base = getmetatable(UnityEngine.GameObject)
local baseMetatable = getmetatable(base)

setmetatable(base,nil)

function base.create(name)
	return UnityEngine.GameObject.New(name)
end

base.addComponent  = super.addComponent
base.getComponent  = super.getComponent

base.setPos        = super.setPos
base.getPos        = super.getPos

base.setSize       = super.setSize
base.getSize       = super.getSize

base.setRotate     = super.setRotate
base.getRotate     = super.getRotate

base.setScale      = super.setScale
base.getScale      = super.getScale

base.setParent     = super.setParent

base.addChild      = super.addChild
base.addChildAt    = super.addChildAt
base.removeChild   = super.removeChild
base.getChild      = super.getChild
base.getChildIndex = super.getChildIndex

setmetatable(base, baseMetatable)