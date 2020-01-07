class(...)

SCENE_INIT 		= "SCENE_INIT"
SCENE_BEGIN_FRAME 	= "SCENE_BEGIN_FRAME"
SCENE_FRAME 	= "SCENE_FRAME"
SCENE_DESTROY	= "SCENE_DESTROY"

HUMAN_ENTER_SCENE = "HUMAN_ENTER_SCENE"
HUMAN_EXIT_SCENE  = "HUMAN_EXIT_SCENE"

COLLECT_ENTER_SCENE = "COLLECT_ENTER_SCENE"
COLLECT_EXIT_SCENE = "COLLECT_EXIT_SCENE"

MONSTER_ENTER_SCENE = "MONSTER_ENTER_SCENE"
MONSTER_EXIT_SCENE  = "MONSTER_EXIT_SCENE"

DROP_ENTER_SCENE = "DROP_ENTER_SCENE"
DROP_EXIT_SCENE = "DROP_EXIT_SCENE"

MAGIC_ENTER_SCENE = "MAGIC_ENTER_SCENE"
MAGIC_EXIT_SCENE  = "MAGIC_EXIT_SCENE"

TOMB_ENTER_SCENE = "TOMB_ENTER_SCENE"
TOMB_EXIT_SCENE  = "TOMB_EXIT_SCENE"

HUMAN_FRAME 	= "HUMAN_FRAME"
MONSTER_FRAME 	= "MONSTER_FRAME"
MAGIC_FRAME 	= "MAGIC_FRAME"
COLLECT_FRAME	= "COLLECT_FRAME"
DROP_FRAME	= "DROP_FRAME"
TOMB_FRAME	= "TOMB_FRAME"

OBJ_DIE = "OBJ_DIE"

ON_JOYSTICK_MOVE     = "ON_JOYSTICK_MOVE"
ON_JOYSTICK_MOVE_END = "ON_JOYSTICK_MOVE_END"
ON_JOYSTICK_BASE_ATK = "ON_JOYSTICK_BASE_ATK"
ON_JOYSTICK_SKILL_1  = "ON_JOYSTICK_SKILL_1"
ON_JOYSTICK_SKILL_2  = "ON_JOYSTICK_SKILL_2"
ON_JOYSTICK_SKILL_3  = "ON_JOYSTICK_SKILL_3"
ON_JOYSTICK_SKILL_4  = "ON_JOYSTICK_SKILL_4"

function ctor(self)
	self.handles = {}
	self.waitRemoveList = {}
	self.notifying = false
end

function AddCallback(self,handle)
	local key = tostring(handle)
	if self.handles[key] == nil then
		self.handles[key] = handle
	end
end

function AddModuleCallback(self,module,callback)
	local key = tostring(module)..tostring(callback)
	if self.handles[key]==nil then
		self.handles[key] = {
			["module"]=module,
			["handle"]=handle
		}
	end
end

function RemoveCallback(self,handle)
	local key = tostring(handle)
	if self.notifying then
		table.insert(self.waitRemoveList,key)
		return
	end
	self:Remove(key)
end

function RemoveModuleCallback(self,module,handle)
	local key = tostring(module)..tostring(handle)
	if self.notifying then
		tabel.insert(self.waitRemoveList,key)
		return
	end
	self:Remove(key)
end

function Remove(self,key)
	if self.handles[key]~=nil then
		self.handles[key] = nil
	end
end

function Notify(self,...)
	self.notifying = true
	for _,h in pairs(self.handles) do
		if type(h) == "table" then
			local callback = h["handle"]
			local mod = h["module"]
			assert(mode,"Module is nil")
			mod[callback](mod,...)
		else
			h(...)
		end
	end
	for i,key in ipairs(self.waitRemoveList) do
		self:Remove(key)
	end
    self.waitRemoveList = {}
    self.notifying = false
end