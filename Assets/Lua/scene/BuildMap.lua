class(...)

local GameObject = UnityEngine.GameObject
local SpriteRenderer = UnityEngine.SpriteRenderer
local Resources = UnityEngine.Resources

function init(scene,mapName,callback)
	local config = require("map."..mapName)

	sortingOrder = -32768

	if config.backgroundFolder ~= "" then
		mapFileId = config.backgroundFolder
	else
		mapFileId = mapName
	end

	local parent = scene

	local spriteRenderer = parent.gameObject:addComponent("SpriteRenderer")
	spriteRenderer.sprite = Resources.Load("MapMini/" .. mapFileId,typeof(UnityEngine.Sprite))
	local spriteRect = spriteRenderer.sprite.rect

	spriteRenderer:setScale(config.cellWidth*32/spriteRect.width,config.cellHeight*32/spriteRect.height,1)
	spriteRenderer:setPos(0,-990,0)
	spriteRenderer:setRotate(90,0,0)

	spriteRenderer.sortingOrder = sortingOrder
	spriteRenderer.sortingLayerName = "MapLayer"

	if config.backgrounds then
		for k,v in pairs(config.backgrounds) do
			local path = v.assetPath.."/"..k
			local index = string.find(k,"_")

			local go = GameObject.create("Tile")
            local backgroundRender = go:addComponent("SpriteRenderer")

            backgroundRender.sortingOrder = sortingOrder + 1
            backgroundRender.sortingLayerName = "MapLayer"

            backgroundRender.sprite = Resources.Load(path,typeof(UnityEngine.Sprite))
            backgroundRender:setPos(v.x,-990,v.y)
            backgroundRender:setRotate(90,0,0)
            go.transform:SetParent(scene.gameObject.transform)
		end
	end
end