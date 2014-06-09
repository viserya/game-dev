local magicres = require("magicres")
local rtimer = require("rtimer")
local vector2 = require("vector2")
local utils = require("utils")

local _M = {}

local MONSTER = {}
MONSTER.__index = MONSTER
local W, H = display.contentWidth, display.contentHeight

function MONSTER:init(args)
	args = args or {}
	self.group = display.newGroup()
	
	local mons = display.newImage(self.group, "imgs/e_tap/level_1.png")
	local scaleFactor = 5
	mons:scale( mons.contentWidth/W*scaleFactor, mons.contentHeight/H*scaleFactor)
	self.monster = mons
	
	local rand = math.random(1, 5)
	self.monster.speed = rand*0.001
	
	local randomizer = math.random(0,3)
	if randomizer == 1 then
		--Top side
		self.monster.x = math.random( 0, magicres.right)
		self.monster.y = 0
	elseif randomizer == 2 then
		--Left side
		self.monster.x = 0
		self.monster.y = math.random(0, magicres.bottom)
	elseif randomizer == 3 then
		--Right side
		self.monster.x = magicres.right
		self.monster.y = math.random(0, magicres.bottom)
	else
		--Bottom side
		self.monster.x = math.random(0, magicres.right)
		self.monster.y = magicres.bottom
	end
end

function MONSTER:getRotation( deltaAngle)
	self.group.rotate(delatAngle)
end

function _M.createMonster(args)
	args = args or {}
	local ret = {}
	setmetatable(ret, MONSTER)
	ret:init(args)
	return ret
end

return _M