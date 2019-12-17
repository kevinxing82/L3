--主入口函数。从这里开始lua逻辑
require("base.class")
require("component.extend.init")

function Main()					
	print("This is where the world begin!")
	World  = require("TheWorld")
	World.run()		
end

--场景切换通知
function OnLevelWasLoaded(level)
	collectgarbage("collect")
	Time.timeSinceLevelLoad = 0
end

function OnApplicationQuit()

end