local magicres = require("magicres")

local _M = {}
local W, H = display.contentWidth, display.contentHeight
_M.group = display.newGroup()	

function _M.createDarkMite(args)
	args = args or {}	
	x = args[2]
	y = args [3]
	
	darkMite = _M.setDarkMiteLevel(args[1])
	darkMite.kind = "darkMite"
	darkMite.kill = false
	darkMite.speed = .20
	
	if (x == -1 and y == -1) then
		_M.setPosition(darkMite)
	else
		darkMite.x = x
		darkMite.y = y
	end
	
	darkMite.sourceX = darkMite.x 
	darkMite.sourceY = darkMite.y
	_M.darkMite = darkMite
	
	return _M.darkMite
end

function _M.setDarkMiteLevel(level)
	local darkMite = {}
	local scaleFactor = .60
	if (level == 'level1') then
		darkMite = display.newImage(_M.group, "imgs/e_tap/level_1.png")
	elseif (level == 'level2') then 
		darkMite = display.newImage(_M.group, "imgs/e_tap/level_2.png")
	elseif (level == 'level3') then 
		darkMite = display.newImage(_M.group, "imgs/e_tap/level_3.png")
	else
		darkMite = display.newImage(_M.group, "imgs/e_tap/level_4.png")
	end
	darkMite:scale(scaleFactor, scaleFactor)	
	darkMite.level = level
	return darkMite
end

function _M.setPosition(darkMite)	
	local randomizer = math.random(0,3)
	if randomizer == 1 then
		--Top side
		darkMite.x = math.random( 0, magicres.right)
		darkMite.y = 0
	elseif randomizer == 2 then
		--Left side
		darkMite.x = 0
		darkMite.y = math.random(0, magicres.bottom)
	elseif randomizer == 3 then
		--Right side
		darkMite.x = magicres.right
		darkMite.y = math.random(0, magicres.bottom)
	else
		--Bottom side
		darkMite.x = math.random(0, magicres.right)
		darkMite.y = magicres.bottom
	end
end

return _M