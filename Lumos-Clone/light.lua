local magicres = require("magicres")

local _M = {}
local W, H = display.contentWidth, display.contentHeight

function _M.createLight()
	_M.group = display.newGroup()
	
	local light = display.newImage(_M.group, "imgs/light/light.png", W/2, H/2)
	light.width = 128
	light.height = 128
	
	_M.radius = 64
	_M.light = light
	return _M.light
end

function _M.rotateLight()
	
end

return _M