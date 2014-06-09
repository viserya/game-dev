local magicres = require("magicres")

local _M = {}
local W, H = display.contentWidth, display.contentHeight
_M.group = display.newGroup()	

function _M.createPhoton(args)
	args = args or {}
	photon = initiate()
	_M.kind = "photon"
	_M.photon = photon
	return _M.photon
end

function initiate()
	local photon = display.newImage(_M.group, "imgs/light/photon.png")
	local scaleFactor = .60
	photon:scale(scaleFactor, scaleFactor)	
	photon.kind = "photon"
	photon.speed = 0.30
	photon.kill = false
	setPosition(photon)	
	photon.sourceX = photon.x 
	photon.sourceY = photon.y
	return photon
end

function setPosition(photon)
	local randomizer = math.random(0,3)
	if randomizer == 1 then
		--Top side
		photon.x = math.random( 0, magicres.right)
		photon.y = 0
	elseif randomizer == 2 then
		--Left side
		photon.x = 0
		photon.y = math.random(0, magicres.bottom)
	elseif randomizer == 3 then
		--Right side
		photon.x = magicres.right
		photon.y = math.random(0, magicres.bottom)
	else
		--Bottom side
		photon.x = math.random(0, magicres.right)
		photon.y = magicres.bottom
	end
end
return _M