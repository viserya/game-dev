local magicres = require("magicres")
local storyboard = require( "storyboard" )
local physics = require("physics")
local monsterTap = require("monster_tap")
local rtimer = require("rtimer")
local vector2 = require("vector2")
local utils = require("utils")

local scene = storyboard.newScene()
local W, H = display.contentWidth, display.contentHeight
local monsterTable = {}
local gameOver = false

function scene:createScene(event)
	local screenGroup = self.view	
	local bg = display.newImage(screenGroup, "imgs/bg.jpg", W/2, H/2)
	local light = display.newImage(screenGroup, "imgs/light.png", W/2, H/2)
	
	bg:scale( W / bg.contentWidth, H / bg.contentHeight )
	light:scale( light.contentWidth / W, light.contentHeight / H )
	
end

function moveMonster(self, event)
	local deltaX = W/2 - self.monster.x
	local deltaY = H/2 - self.monster.y
	self.monster.x = self.monster.x +  deltaX*self.monster.speed
	self.monster.y = self.monster.y + deltaY*self.monster.speed
	self.monster.speed = self.monster.speed + 0.000005
end

function monsterTableFnc()
	local maxMonsters = math.random(5,20)
	for i = 1, maxMonsters do
		monsterTable[#monsterTable + 1] = monsterTap.createMonster()
	end
end

function enterFrameMonsters()
	monsterTableFnc()
	for i = 1, #monsterTable do
		monsterTable[i].enterFrame = moveMonster
		Runtime:addEventListener("enterFrame", monsterTable[i])
	end
end

function onTouchScreen(event)
	local radius = 10
	if event.phase == "began" then
		local circle = display.newCircle(event.x, event.y, radius)
		circle.isVisible = false
		--Collission Detection
		for i = 1, #monsterTable do
			local deltaX = event.x - monsterTable[i].monster.x
			local deltaY = event.y - monsterTable[i].monster.y 
			local distance = math.sqrt(math.pow(deltaX, 2) + math.pow(deltaY, 2))
			local combinedSize = monsterTable[i].monster.contentWidth/2 + radius
			if (distance < combinedSize) then
				monsterTable[i].monster.isVisible = false
				table.remove(monsterTable, i)
				break
			end
		end
	end	
end

function scene:enterScene(event)
	while gameOver == false do
		()
		timer.performWithDelay(5000, enterFrameMonsters) 
	end
	Runtime:addEventListener("touch", onTouchScreen) 
end

function scene:exitScene(event)
end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene