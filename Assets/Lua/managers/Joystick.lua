class(...,require("base.EventDispatcher"))

local GameObject = UnityEngine.GameObject
local Event = require("base.Event")

function init(self)
	super:init()
	self.joystick = GameObject.Find("Canvas/Joystick/container"):getComponent("ETCJoystick")
	self.joystick.onMoveStart:AddListener(self.onMoveStart)
	self.joystick.onMoveEnd:AddListener(self.onMoveEnd)
	self.joystick.onMove:AddListener(self.onMove)

	self.container = GameObject.Find("Canvas/Joystick/container"):getComponent("Image")
	self.thumb     = GameObject.Find("Canvas/Joystick/container/Thumb"):getComponent("Image")

	self.atkBtn = GameObject.Find("Canvas/MainUI/skill/BaseAttack"):getComponent("Button")
	self.atkBtn.onClick:AddListener(self.onAtkBtnClick)
	self.atkImg = GameObject.Find("Canvas/MainUI/skill/BaseAttack/dsIcon"):getComponent("Image")
	self.atkBtn.targetGraphic = self.atkImg
	self.skill1Btn = GameObject.Find("Canvas/MainUI/skill/icons/skill1"):getComponent("Button")
	self.skill1Btn.onClick:AddListener(self.onSkill1Click)
	self.skill2Btn = GameObject.Find("Canvas/MainUI/skill/icons/skill2"):getComponent("Button")
	self.skill2Btn.onClick:AddListener(self.onSkill2Click)
	self.skill3Btn = GameObject.Find("Canvas/MainUI/skill/icons/skill3"):getComponent("Button") 
	self.skill3Btn.onClick:AddListener(self.onSkill3Click)
	self.skill4Btn = GameObject.Find("Canvas/MainUI/skill/icons/skill4"):getComponent("Button")
	self.skill4Btn.onClick:AddListener(self.onSkill4Click)
end

function onMoveStart(self)

end

function onMoveEnd(self)
	self:Notify(EVENT.ON_JOYSTICK_MOVE_END)
end

function onMove(self,pos)
	self:Notify(EVENT.ON_JOYSTICK_MOVE,pos)
end

function setContainerPos(self,posX,posY)

end

function onAtkBtnClick(self)
	self:Notify(EVENT.ON_JOYSTICK_BASE_ATK)
end

function onSkill1Click(self)
	self:Notify(EVENT.ON_JOYSTICK_SKILL_1)
end

function onSkill2Click(self)
	self:Notify(EVENT.ON_JOYSTICK_SKILL_2)
end

function onSkill3Click(self)
	self:Notify(EVENT.ON_JOYSTICK_SKILL_3)
end

function onSkill4Click(self)
	self:Notify(EVENT.ON_JOYSTICK_SKILL_4)
end