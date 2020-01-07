class(...)
local  Event = require("base.Event")
function init(self)
	self.eventTable = {}
end

function AddListener(self,evtName,handle)
	if self.eventTable[evtName] == nil then
		self.eventTable[evtName] = Event.new()
	end
	self.eventTable[evtName]:AddCallback(handle)
end

function RemoveListener(self,evtName,handle)
	if self.eventTable[evtName] ~= nil then
		self.eventTable[evtName]:RemoveCallback(handle)
	end
end

function AddModuleListener(self,evtName,module,handle)
	if self.eventTable[evtName] == nil then
		self.eventTable[evtName] = Event.new()
	end
	self.eventTable[evtName]:AddModuleCallback(module,handle)
end

function RemoveModuleListener(self,evtName,module,handle)
	if self.eventTable[evtName] ~= nil then
		self.eventTable[evtName]:RemoveModuleCallback(module,handle)
	end
end

function RemoveAllListener(self,evtName)
	if self.eventTable[evtName]~=nil then
		self.eventTable[evtName] = nil
	end
end

function Notify(self,evtName,...)
	if self.eventTable[evtName] ~= nil then
		self.eventTable[evtName]:Notify(...)
	end
end

