local magicres = require("magicres")

local _M = {}
local W, H = display.contentWidth, display.contentHeight
_M.group = display.newGroup()	
local PI = 3.141592653

function _M.createSpectre(args)
	args = args or {}
	local scaleFactor = .50
	
	local level =  args[1]
	local x = args[2]
	local y = args[3]
	
	local spectre = setSpectreLevel(level, x, y)
	spectre:scale(scaleFactor, scaleFactor)	
	spectre.speed = 0.35
	
	if ( x == -1 and y == -1) then
		setPosition(spectre)
	else
		spectre.x = x
		spectre.y = y
	end
	
	spectre.angle = 90
	_M.rotateSpectre(spectre, W/2, H/2)
	spectre.kind = "spectre"
	spectre.kill = false
	spectre.sourceX = spectre.x 
	spectre.sourceY = spectre.y
	spectre.flicked = 0
	_M.Spectre = spectre
	
	return _M.Spectre
end


function setSpectreLevel(level, x , y)
	local spectre = {}
	if (level == 'level1') then
		spectre = display.newImage(_M.group, "imgs/e_flick/level_1.png")
		spectre.level = 1
	elseif (level == 'level2') then 
		spectre = display.newImage(_M.group, "imgs/e_flick/level_2.png")
		spectre.level = 2
	elseif (level == 'level3') then 
		spectre = display.newImage(_M.group, "imgs/e_flick/level_3.png")
		spectre.level = 3
	else
		spectre = display.newImage(_M.group, "imgs/e_flick/level_4.png")
		spectre.level = 4
	end
	return spectre
end

function setPosition(spectre)	
	local randomizer = math.random(0,3)
	if randomizer == 1 then
		--Top side
		spectre.x = math.random( 0, magicres.right)
		spectre.y = 0
	elseif randomizer == 2 then
		--Left side
		spectre.x = 0
		spectre.y = math.random(0, magicres.bottom)
	elseif randomizer == 3 then
		--Right side
		spectre.x = magicres.right
		spectre.y = math.random(0, magicres.bottom)
	else
		--Bottom side
		spectre.x = math.random(0, magicres.right)
		spectre.y = magicres.bottom
	end
end

function _M.rotateSpectre(spectre, sourceX, sourceY)
	local deltaX = sourceX - spectre.x
	local deltaY = sourceY - spectre.y
	local angle = math.atan2( deltaY, deltaX )*180/PI
	
	if spectre.x < sourceX and spectre.y < sourceY then
		--First Quadrant
		spectre.angle = spectre.angle + angle 
	elseif spectre.x > sourceX and spectre.y < sourceY then
		--Second Quadrant
		spectre.angle =-((270-angle))
	elseif spectre.x < sourceX and spectre.y > sourceY then
		--Third Quadrant
		spectre.angle = spectre.angle + angle
	elseif spectre.x > sourceX and spectre.y > sourceY then
		--Fourth Quadrant
		spectre.angle = spectre.angle + angle
	end
	
	spectre:rotate(spectre.angle )
	spectre.angle = angle	
end

return _M