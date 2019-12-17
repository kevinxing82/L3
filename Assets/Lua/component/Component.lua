class(...)

function _G.bind(behaviour,instance)
	if not instance then
		local component = behaviour.component
		if(component and instance == component) or behaviour.luaPath = nil  then
			return 
		end

		if not component or component.behaviour~=behaviour then
			local cls = require(behaviour.luaPath)
			instance = cls.new()
			instance.behaviour = behaviour
		else
			return
		end
	else
		instance.behaviour = behaviour
		instance.luaPath = instance.__cname
	end

	instance.gameObject = behaviour.gameObject
	instance.transform  = behaviour.transform

	behaviour.component = instance
end