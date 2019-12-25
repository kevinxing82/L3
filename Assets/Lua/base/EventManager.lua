class(...)
local  Event = require("base.Event")
function init()
	eventTable = {}
end

function AddListener(evtName,handle)
	if eventTable[evtName] == nil then
		eventTable[evtName] = Event.new()
	end
	eventTable[evtName]:AddCallback(callback)
end

function RemoveListener(evtName,handle)
	if eventTable[evtName] ~= nil then
		eventTable[evtName]:RemoveCallback(handle)
	end
end

function AddModuleListener(evtName,module,handle)
	if eventTable[evtName] == nil then
		eventTable[evtName] = Event.new()
	end
	eventTable[evtName]:AddModuleCallback(module,handle)
end

function RemoveModuleListener(evtName,module,handle)
	if eventTable[evtName] ~= nil then
		eventTable[evtName]:RemoveModuleCallback(module,handle)
	end
end

function RemoveAllListener(evtName)
	if eventTable[evtName]~=nil then
		eventTable[evtName] = nil
	end
end

function Notify(evtName,...)
	if eventTable[evtName] ~= nil then
		eventTable[evtName]:Notify(...)
	end
end

