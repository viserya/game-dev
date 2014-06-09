local magicres = require("magicres")

local _M = {}
local W, H = display.contentWidth, display.contentHeight
_M.group = display.newGroup()	
local PI = 3.141592653

function _M.createTendrils(args)
	args = args or {}
	local level =  args[1]
	local x = args[2]
	local y = args[3]
	
	local tendril, sourceX, sourceY = setTendrilLevel(level, x, y)
	tendril.kind = "tendril"
	tendril.kill = false
	tendril.slashed = 0
	tendril.angle1 = 0.45
	tendril.sourceX = sourceX
	tendril.sourceY = sourceY
	_M.tendril = tendril
	
	return _M.tendril
end

function setPositionTendril()	
		local randomizer = math.random(0,3)
		local x = 0
		local y = 0
		if randomizer == 1 then
			x = math.random( 0, magicres.right)
			y = 0
		elseif randomizer == 2 then
			x = 0
			y = math.random(0, magicres.bottom)
		elseif randomizer == 3 then
			x = magicres.right
			y = math.random(0, magicres.bottom)
		else
			x = math.random(0, magicres.right)
			y = magicres.bottom
		end
		return x, y
	end

function setTendrilLevel(level, x, y)
	local tendrilTable = {}
	local scaleFactor = 0.85
	local lev = 0
	if ( x == -1 and y == -1) then
		x ,y = setPositionTendril()
	end
	
	local sourceX, sourceY = x, y
	
	local moveAngle = 0
	for i = 1, math.max(W/2, H/2) do 
		local tendril
		if i == 1 then
			tendril = display.newImage(_M.group, "imgs/e_slash/tip.png")
			tendril.name = 'tip'
		else
			if (level == 'level1') then
				tendril = display.newImage(_M.group, "imgs/e_slash/lvl_1.png")
				lev = 1
			elseif (level == 'level2') then
				tendril = display.newImage(_M.group, "imgs/e_slash/lvl_2.png")
				lev = 2
			elseif (level == 'level3') then
				tendril = display.newImage(_M.group, "imgs/e_slash/lvl_3.png")
				lev = 3
			else
				tendril = display.newImage(_M.group, "imgs/e_slash/lvl_4b.png")
				lev = 4
			end
			tendril.name = 'tail'
		end
		tendril:scale(scaleFactor + i/50, scaleFactor + i/50)
		local deltaX = math.sqrt((W/2 - x)*(W/2 - x))
		local deltaY = math.sqrt((H/2 - y)*(H/2 - y))
		local angle = math.atan2(deltaY, deltaX) + math.pi
		
		local spacing = 8
		
		if x < W/2 and y < H/2  then--First Quadrant
			tendril.x = x - math.cos(angle - math.pi)*spacing
			tendril.y = y - math.sin(angle - math.pi)*spacing
		end
		if x > W/2 and y > H/2  then--Fourth Quadrant
			tendril.x = x - math.cos(angle)*spacing
			tendril.y = y - math.sin(angle )*spacing
		end
		if x > W/2 and y < H/2  then -- Second Quadrant
			tendril.x = x - math.cos(angle)*spacing
			tendril.y = y + math.sin(angle)*spacing
		end
		if x < W/2 and y > H/2  then --Third Quadrant
			tendril.x = x - math.cos(angle + math.pi)*spacing
			tendril.y = y + math.sin(angle + math.pi)*spacing
		end
	
		if i ~= 1 then 
			_M.rotateTendril(tendril, tendrilTable[i-1].x, tendrilTable[i-1].y)
		else
			_M.rotateTendril(tendril, W/2, H/2)
		end
		
		tendril.speed = 0.6
		tendril.kill = false
		moveAngle = moveAngle + 0.16
		tendril.moveAngle = moveAngle
		tendril.amplitude = 1.5
		
		tendril.sourceX = tendril.x 
		tendril.sourceY = tendril.y
		x = tendril.x
		y = tendril.y
		
		 table.insert(tendrilTable, tendril)
	end
	tendrilTable.level = lev
	
	return tendrilTable, sourceX, sourceY
end

function _M.rotateTendril(tendril, sourceX, sourceY)
	local deltaX = sourceX - tendril.x
	local deltaY = sourceY - tendril.y
	local angle = math.atan2( deltaY, deltaX )*180/PI
	
	if tendril.x < sourceX and tendril.y < sourceY then
		tendril:rotate(90 + angle)
	elseif tendril.x > sourceX and tendril.y < sourceY then
		--Second Quadrant
		tendril:rotate(-((180-angle) + 90))
	elseif tendril.x < sourceX and tendril.y > sourceY then
		--Third Quadrant
		tendril:rotate(90 + angle)
	elseif tendril.x > sourceX and tendril.y > sourceY then
		--Fourth Quadrant
		tendril:rotate(90 + angle)
	end	
end

return _M