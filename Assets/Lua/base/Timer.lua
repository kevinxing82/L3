class(...)

local Time = UnityEngine.Time

function ctor(self)
	self.DataFrameRate = 20
    self.RenderFrameRate = 30
	self.timerList = {}
	self.lastUpdateTime=0
	self._now = 0
	self._totalTime  = 0
	-- self._totalFrame = 0
end

function get.now(self)
	return self._now
end

function get.totalTime(self)
	return self._totalTime
end

-- function get.totalFrame(self)
-- 	return self._totalFrame
-- end

function add(self,callback,time,isOneShot,data)
	local info = self.timerList[callback]
	if not info then
		info = {}
		self.timerList[callback] = info
	end

	info.time = time
	info.beginTime = self.now
	info.data = data
	info.isOneShot = isOneShot
	info.callback = callback
end

function remove(self,callback)
	local info = self.timerList[callback]
	if info then
		self.timerList[callback]=nil
	end
end

function has(self,callback)
	return self.timerList[callback]
end

function onFixedUpdate(self)
	self._now = Time.time
	local delay = self._now-self.lastUpdateTime
	-- self._totalFrame = math.ceil(self._now*RenderFrameRate)
	self.lastUpdateTime = self._now
end

function onUpdate(self)
	local workList = {}

	for _,info in pairs(self.timerList) do
		table.insert(workList,info)
	end

	local len = #workList
	for i = 1,len do
		local info = workList[i]
		local callback = info.callback
		if self.timerList[callback] then
			if self.now>info.beginTime + info.time then
				if info.isOneShot then
					self:remove(callback)
					callback(info.data)
				else
					info.beginTime = self.now
					callback(info.data)
				end
			end
		end
	end
end

function instance(self)
	if self._instance == nil then
		self._instance = self.new()
	end
	return self._instance
end