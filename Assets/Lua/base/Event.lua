class(...)

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