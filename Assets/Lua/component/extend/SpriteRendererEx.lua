-- 扩展Unity SpriteRenderer class 方法
local base = getmetatable(UnityEngine.SpriteRenderer)
local baseMetatable = getmetatable(base)

setmetatable(base,nil)


setmetatable(base,baseMetatable)