--local global = {print=print, ipairs=ipairs, pairs=pairs, _G=_G, require=require, tostring=tostring, setmetatable=setmetatable, getmetatable=getmetatable, rawget=rawget, rawset=rawset, type=type}
local function accessor(cls, super, isSet)
	local accessorSuper	
	local t={}
	
	if isSet then
		cls.set = t
		accessorSuper = super and super.set
	else
		cls.get = t
		accessorSuper = super and super.get
	end
  
	if accessorSuper then
		t.__index = function(t,k)
			return rawget(t, k) or accessorSuper[k]
		end
	end	
	setmetatable(t, t)
	return t
end

local function create(cls, super)
	local get = accessor(cls, super)
	local set = accessor(cls, super, true)

	if super then
		for k,v in pairs(super) do
			if type(v)=="function" and k~="__newindex" and k~="__index" and k~="new" and not cls[k] then
				cls[k] = v
			end
		end
		cls.__index = function(t,k)
		  local func = get[k]
		  if func then return func(t) end
		  return rawget(cls, k) or super[k] or _G[k]
		end
	else
		cls.__index = function(t,k)
		  local func = get[k]
		  if func then return func(t) end
		  return rawget(cls, k) or _G[k]  
		end
	end
	
	cls.__newindex = function(t, k, v)
		local func = set[k]
		if func then return func(t,v) end
		rawset(t,k,v)
	end
	
	cls._M = cls
	
	function cls.new(...)
		local instance = {}
		local super = cls
		
		while super do
		
		  for k,v in pairs(super) do
			if type(v)=="function" and k~="__newindex" and k~="__index" and k~="new" and not instance[k] then
				local super = super
				-- instance[k] = function(_,...)
					-- if _~=instance then
						-- return super[k](instance,_,...) 
					-- else
						-- return super[k](instance,...) 
					-- end
				-- end
				
				local method = super[k]
				instance[k] = function(_,...)
					if _~=instance then
						return method(instance,_,...) 
					else
						return method(instance,...) 
					end
				end
			end
		  end
		  super = super.super
		end
   			
		instance.__cname = cls.__cname
		setmetatable(instance, cls)
		if instance.ctor then
			instance:ctor(...)
		end
		return instance
	end
  
	setmetatable(cls, cls)
end

local globalMetatable = {
	__index=function(t,k)
		if k=="_M" then return t end
		return _G[k]
	end
}


function class(className, super, excel)
	if excel then
		local cls = {}
		package.loaded[className] = cls
		setfenv(2, cls)
		
		setmetatable(cls, globalMetatable)
		
		return
	end
	local cls = {super = super, __cname = className}
	package.loaded[className] = cls
	setfenv(2, cls)
	create(cls, super)
end

function isType(obj, className)
	local super = obj
	while super do
		if super.__cname == className then
			return true
		else
			super = super.super
		end	
	end
end