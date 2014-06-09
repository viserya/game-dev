local _M = {}

local RTimer = {}
RTimer.__index = RTimer

function _M.create(maxtime)
	local ret = {}
	setmetatable(ret, RTimer)
	ret.maxtime = maxtime
	ret.curtime = 0
	ret.enabled = true
	return ret
end
function RTimer:setEnabled(bool)
	self.enabled = bool
end
function RTimer:tick(t, allow_overflow)
	if not self.enabled then return end
	self.curtime = self.curtime + t
	if self.curtime > self.maxtime and not allow_overflow then
		self.curtime = self.maxtime
	end
end
function RTimer:setRatio(r)
	self.curtime = self.maxtime*r
end
function RTimer:reset()
	self.curtime = 0
end
function RTimer:tomax()
	self.curtime = self.maxtime
end
function RTimer:getRatio()
	return (1.0*self.curtime)/self.maxtime
end
function RTimer:isFinished()
	return self:getRatio() >= 1.0
end

return _M