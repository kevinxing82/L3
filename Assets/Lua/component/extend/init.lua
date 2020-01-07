CLASS_NAMES = {}

local namespace = {_G,UnityEngine,UnityEngine.UI,UnityEngine.EventSystems}
local internalTime = os.time()
for _,list in ipairs(namespace) do
	for k,v in pairs(list) do
		if type(v)== "table" then
			local metatable = getmetatable(v)
			if metatable then
				local ref = rawget(metatable,".ref")
				if ref and ref > 0 then
					local className = rawget(metatable,".name")
					tmp = string.split(className,".")
					className  = tmp[#tmp]
					CLASS_NAMES[className] = _G.typeof(v)
					-- if not _G[className] then
					-- 	_G[className] = v
					-- end
				end
			end
		end
	end
end


require("component.extend.ComponentEx")
require("component.extend.GameObjectEx")