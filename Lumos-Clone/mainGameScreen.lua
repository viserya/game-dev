local magicres = require("magicres")
local storyboard = require( "storyboard" )
local physics = require("physics")
local darkMites = require("darkMites")
local light = require("light")
local photon = require("photons")
local spectre = require("spectres")
local highScore = require("saveScore")
local tendril = require("tendrils")

local scene = storyboard.newScene()
local scoreText = highScore.init({ filename = "score.txt" })
local W, H = display.contentWidth, display.contentHeight
local timeTable = {}
local darkMiteTable = {}
local photonTable = {}
local spectreTable = {}
local tendrilTable = {}

local gameOver = false
local pauseGame = false
local setScore = false
local gameTimeMs = 0
local gameTime = 0
local counterDm = 0
local counterSp = 0
local counterTn = 0
local radius = 15
local tick = 1000 

local flicked = false
local flickSpectre = {}
local flickAngle = 0
local startTime = 0
local endTime = 0

local bx, by = 0, 0
local lines = {}

function scene:createScene(event)
	local screenGroup = self.view	
	newGroup = display.newGroup()
	local bg = display.newImage(screenGroup, "imgs/bg.jpg", W/2, H/2)
	pause = display.newImage(screenGroup, "imgs/etc/btn_realm_back.png", magicres.right - 25, 20)
	light.createLight()
	pause_bg = display.newImage(screenGroup, "imgs/pause/pause.png", W/2, H/2)
	bg:scale( magicres.right / bg.contentWidth, magicres.bottom / bg.contentHeight )
	pause_bg:scale(.50, .50)
	pause_bg.isVisible = false
	pause:scale(.60, .60)
end

function spawnPhotons()
	if (gameOver == false) then
		local maxPhotons = math.min(6, 2 + math.floor(gameTimeMs/75000))
		local X = maxPhotons - #photonTable
		for i = 1, math.max(0, X) do
			newPhoton = photon.createPhoton()
			newPhoton.enterFrame = moveCreatures
			Runtime:addEventListener("enterFrame", newPhoton)
			table.insert(photonTable, newPhoton)
		end
	end
end

function gameTimerFnc()
	if (gameOver == false) and (pauseGame == false) then
		gameTime = gameTime + 1
		spawnCreatures()
		spawnPhotons()
		return gameTime
	end
end

function killAllCreatures()
	local creatureTable = {darkMiteTable, photonTable, spectreTable, tendrilTable}
	for t = 1, #creatureTable do
		for i = #creatureTable[t], 1, -1 do
			creatureTable[t][i].kill = true
		end
	end
	for t = #tendrilTable, 1, -1 do
		for i = #tendrilTable[t], 1, -1 do
			tendrilTable[t][i].isVisible = false
			tendrilTable[t][i] = nil
			table.remove(tendrilTable[t], i)
		end
		table.remove(tendrilTable, t)
	end
	removeCreatures()
end

function removeCreatures()
	local creatureTable = {darkMiteTable, photonTable, spectreTable}
	for t = 1, #creatureTable do
		for i = #creatureTable[t], 1, -1 do
			if creatureTable[t][i].kill == true then
				killMon = table.remove(creatureTable[t], i)
				killMon.isVisible = false
				killMon = nil
			end
		end
	end
end

function updateLight(event)
	if (pauseGame == false) then
		if light.radius <= 8 then
			gameOver = true
		elseif event == "reduce" then
			transition.to( light.light , { time = 500, width = light.light.width/2, height = light.light.width/2} )
			light.radius = light.light.width/4
		elseif event == "increase" then
			transition.to( light.light , { time = 100, width = light.light.width + 1, height = light.light.height + 1} )
			light.radius = (light.light.width + 1)/2
		end
	end
end

function moveCreatures(self,event)
	if (gameOver == false) and (pauseGame == false) then
		PI = 3.14159265358
		local deltaX = math.sqrt((W/2 - self.sourceX)*(W/2 - self.sourceX))
		local deltaY = math.sqrt((H/2 - self.sourceY)*(H/2 - self.sourceY))
		local angle = math.atan2(deltaY, deltaX)
			
		if self.sourceX <= W/2 and self.sourceY <= H/2 then
			angle = PI/2 - (math.atan2(deltaX, deltaY))
		elseif self.sourceX >= W/2 and self.sourceY <= H/2 then
			angle = (PI - math.atan2(deltaY, deltaX))
		elseif self.sourceX <= W/2 and self.sourceY >= H/2 then
			angle = -math.atan2(deltaY, deltaX)
		elseif self.sourceX >= W/2 and self.sourceY >= H/2 then
			angle = PI + math.atan2(deltaY, deltaX)
		end	
		
		self.x = self.x +  self.speed*math.cos(angle)
		self.y = self.y + self.speed*math.sin(angle)
	
		--Detect Collisiion with Light
		local dX = W/2 - self.x
		local dY = H/2- self.y 
		local distance = math.sqrt(dX*dX + dY*dY)
		local combinedSize = self.contentWidth/2 + light.radius 
		
		if self.kill == false then
			if self.kind == "darkMite" or self.kind == "spectre" then
				if (distance < combinedSize) then
					updateLight("reduce") 
					self.isVisible = false
					self.kill = true
				end
			elseif self.kind == "photon" then
				if (distance < combinedSize) then
					updateLight("increase") 
					self.isVisible = false
					self.kill = true
				end
			end
			
		end
	end
end

function spawnCreatures()
	local function moveTendril(self,event)
		local PI = 3.14159265358
		killTendril = false
		if (gameOver == false) and (pauseGame == false) then
			local deltaX = math.sqrt((W/2 - self.sourceX)*(W/2 - self.sourceX))
			local deltaY = math.sqrt((H/2 - self.sourceY)*(H/2 - self.sourceY))
			local angle = math.atan2(deltaY, deltaX)
			
			if self.sourceX <= W/2 and self.sourceY <= H/2 then
				angle = PI/2 - (math.atan2(deltaX, deltaY))
			elseif self.sourceX >= W/2 and self.sourceY <= H/2 then
				angle = (PI - math.atan2(deltaY, deltaX))
			elseif self.sourceX <= W/2 and self.sourceY >= H/2 then
				angle = -math.atan2(deltaY, deltaX)
			elseif self.sourceX >= W/2 and self.sourceY >= H/2 then
				angle = PI + math.atan2(deltaY, deltaX)
			end	
			
			for i = 1, #self do	
				if self.sourceX == 0 or self.sourceX == magicres.right then
					self[i].x = self[i].x +  self[i].speed*math.cos(angle) 
					self[i].moveAngle = self[i].moveAngle + 0.1
					self[i].y = self[i].y + math.sin(self[i].moveAngle)*self[i].amplitude + math.sin(angle)*self[i].speed
				elseif self.sourceY == 0 or self.sourceY == magicres.bottom then
					self[i].y = self[i].y +  self[i].speed*math.sin(angle)
					self[i].moveAngle = self[i].moveAngle + 0.1
					self[i].x = self[i].x + math.cos(self[i].moveAngle)*self[i].amplitude + math.cos(angle)*self[i].speed
				end
				
				if self[i].name == "tip" then
					local dX = W/2 - self[i].x
					local dY = H/2- self[i].y 
					local distance = math.sqrt(dX*dX + dY*dY)
					local combinedSize = self[i].contentWidth/2 + light.radius 
					if (distance < combinedSize) then
						updateLight("reduce") 
						killTendril = true
						self[i].isVisible = false
						killMon = table.remove(self, i)
						killMon = nil
						break
					end
				end
			end
			if killTendril == true then
				for i = #self, 1, -1 do
					self[i].isVisible = false
					self[i] = nil
					killMon = table.remove(self, i)
				end
				self.kill = true
			end
		end
	end

	local function spawnSpectres(level, maxNo)
		if (gameOver == false and pauseGame == false) then
			for i = 1, maxNo do
				newSpectre = spectre.createSpectre({level,  -1,  -1})
				newSpectre.enterFrame = moveCreatures
				Runtime:addEventListener("enterFrame", newSpectre)
				table.insert(spectreTable, newSpectre)
			end
		end
	end

	local function spawnTendrils(level)
		if (gameOver == false and pauseGame == false) then
			for i = 1, 1 do
				newTendril = tendril.createTendrils({level,  -1, -1})
				newTendril.index = #tendrilTable + 1
				newTendril.enterFrame = moveTendril
				Runtime:addEventListener("enterFrame", newTendril)
				table.insert(tendrilTable, newTendril)
			end
		end
	end
	
	local function spawnDarkMites(level, maxNo)
		if (gameOver == false) and (pauseGame == false) then
			removeCreatures()
			for i = 1, maxNo do
				newMite = darkMites.createDarkMite({level,  -1,  -1})
				newMite.enterFrame = moveCreatures
				Runtime:addEventListener("enterFrame", newMite)
				table.insert(darkMiteTable, newMite)
			end
		end
	end
	
	--Enemy Level and Enemy Spawning
	if(gameTime <= 80) then	
		if( gameTime <= 8) then
			spawnDarkMites("level1", 2)
		elseif( gameTime <= 16 ) then
			if (gameTime % 3 == 0) then
				spawnSpectres('level1', 1) 
			end
		elseif( gameTime <= 24 ) then
			if (gameTime % 3 == 0) then 
				spawnTendrils('level1')
			end
		elseif( gameTime <= 80 ) then 
			spawnDarkMites("level1", 2)
			if (gameTime % 10 == 0) then
				spawnDarkMites("level1", 1)
			end
			if(gameTime % 4 == 0) then
				spawnSpectres('level1', 1)
			end
			if (gameTime % 2 == 0) then 
				spawnTendrils('level1')
			end
		end
		
	elseif( gameTime <= 160) then
		if (counterDm <= 3 )then
			spawnDarkMites("level2", 1)
			counterDm = counterDm + 1
		else
			spawnDarkMites("level1", 1)
			counterDm = 0
		end
		if (gameTime % 2 == 0)then
			spawnDarkMites("level2", 1)
			counterDm = counterDm + 1
		end
		
		if( gameTime <= 120 ) then
			if(gameTime % 4 == 0) then
				if counterSp <= 3 then
					spawnSpectres('level2', 1)
					counterSp = counterSp + 1
				else
					spawnSpectres('level1', 1)
					counterSp = 0
				end
			end
			
			if(gameTime % 5 == 0) then
				if counterSp <= 3 then
					spawnTendrils('level2')
					counterTn = counterTn + 1
				else
					spawnTendrils('level1')
					counterTn = 0
				end
			end
			
		end
		if (gameTime <= 160) then
			if(gameTime % 25 == 0) then
				if counterSp <= 3 then
					spawnSpectres('level2', 1)
					counterSp = counterSp + 1
				else
					spawnSpectres('level1', 1)
					counterSp = 0
				end
			end
			
			if(gameTime % 13 == 0) then
				if counterSp <= 3 then
					spawnTendrils('level2')
					counterTn = counterTn + 1
				else
					spawnTendrils('level1')
					counterTn = 0
				end
			end
		end
		
	elseif (gameTime < 240) then
	
		if( gameTime <= 190 ) then 
			if (counterDm <= 3 )then
				spawnDarkMites("level2", 1)
				counterDm = counterDm + 1
			elseif (counterDm <= 6) then
				spawnDarkMites("level3", 1)
				counterDm = counterDm + 1
			else
				spawnDarkMites("level1", 1)
				counterDm = 0
			end
			if (gameTime % 2 == 0) then 
				spawnDarkMites("level3", 1)
				counterDm = counterDm + 1
			end
			
			if(gameTime % 9 == 0) then
				if (counterSp <= 3 ) then
					spawnSpectres("level2", 1)
					counterSp = counterSp + 1
				elseif (counterSp <= 6) then
					spawnSpectres("level3", 1)
					counterSp = counterSp + 1
				else
					spawnSpectres("level1", 1)
					counterSp = 0
				end
			end
			
			if(gameTime % 5 == 0) then
				if (counterDm <= 3 )then
					spawnTendrils("level2")
					counterDm = counterDm + 1
				elseif (counterSp <= 6) then
					spawnTendrils("level3")
					counterDm = counterDm + 1
				else
					spawnTendrils("level1")
					counterDm = 0
				end
			end			
		end
		
	elseif (gameTime <= 300) then
		if (counterDm <= 7 )then
			spawnDarkMites("level3", 2)
			counterDm = counterDm + 2
		elseif (counterDm <= 9) then
			spawnDarkMites("level4", 2)
			counterDm = counterDm + 2
		else
			spawnDarkMites("level2", 2)
			counterDm = 0
			end
		if (gameTime % 10 == 0) then 
			spawnDarkMites("level3", 1)
			counterDm = counterDm + 1
		end
		if( gameTime <= 240 ) then 			
			if(gameTime % 5 == 0) then
				if (counterSp <= 7 ) then
					spawnSpectres("level3", 1)
					counterSp = counterSp + 1
				elseif (counterSp <= 9) then
					spawnSpectres("level4", 1)
					counterSp = counterSp + 1
				else
					spawnSpectres("level2", 1)
					counterSp = 0
				end
			end
			
			if(gameTime % 4 == 0) then
				if (counterDm <= 7 )then
					spawnTendrils("level3")
					counterDm = counterDm + 1
				elseif (counterSp <= 9) then
					spawnTendrils("level4")
					counterDm = counterDm + 1
				else
					spawnTendrils("level2")
					counterDm = 0
				end
			end			
		elseif (gameTime <= 260) then
			if(gameTime % 9 == 0) then
				if (counterSp <= 7 ) then
					spawnSpectres("level3", 1)
					counterSp = counterSp + 1
				elseif (counterSp <= 9) then
					spawnSpectres("level4", 1)
					counterSp = counterSp + 1
				else
					spawnSpectres("level2", 1)
					counterSp = 0
				end
			end
			
			if(gameTime % 5 == 0) then
				if (counterDm <= 7 )then
					spawnTendrils("level3")
					counterDm = counterDm + 1
				elseif (counterSp <= 9) then
					spawnTendrils("level4")
					counterDm = counterDm + 1
				else
					spawnTendrils("level2")
					counterDm = 0
				end
			end	
		end
	else
		
	end
	
end

function killTendrilFnc(line)
	for i = 1, #tendrilTable do
		newTendril = tendrilTable[i]
		if newTendril.kill == false and newTendril ~= nil and line ~= nil then
			if (newTendril.sourceX == 0 and (line.x1 >= newTendril.sourceX and line.x2 <= newTendril[1].x)) or (newTendril.sourceX == magicres.right and (line.x1 <= newTendril.sourceX and line.x2 >= newTendril[1].x)) then
				if(line.y1 <= newTendril.sourceY and line.y2 >= newTendril.sourceY ) or (line.y1 >= newTendril.sourceY and line.y2 <= newTendril.sourceY) or (line.y1 >= newTendril[1].y and line.y2 <= newTendril[1].y) or (line.y1 <= newTendril[1].y and line.y2 >= newTendril[1].y)then
					if(newTendril.level > 1) then
						if (newTendril.level > newTendril.slashed ) then
							newTendril.slashed = newTendril.slashed + 1
							return true
						end
					end
					for j = #newTendril, 1, -1 do
						newTendril[j].isVisible = false
						newTendril[j] = nil
						table.remove(newTendril, j)
					end
					newTendril.kill = true
				end
			elseif (newTendril.sourceY == 0 and (line.y1 >= newTendril.sourceY and line.y2 <= newTendril[1].y)) or (newTendril.sourceY == magicres.bottom and (line.y1 <= newTendril.sourceY and line.y2 >= newTendril[1].y)) then
				if(line.x1 <= newTendril.sourceX and line.x2 >= newTendril.sourceX) or (line.x1 >= newTendril.sourceX and line.x2 <= newTendril.sourceX) or (line.x1 >= newTendril[1].x and line.x2 <= newTendril[1].x) or (line.x1 <= newTendril[1].x and line.x2 >= newTendril[1].x)then
					if(newTendril.level > 1) then
						if (newTendril.level > newTendril.slashed ) then
							newTendril.slashed = newTendril.slashed + 1
							return true
						end
					end
					for j = #newTendril, 1, -1 do
						newTendril[j].isVisible = false
						newTendril[j] = nil
						table.remove(newTendril, j)
					end
					newTendril.kill = true
				end
			end
		end
	end
end

function flickSpectreFnc(self,event)
	local flicks, lev
	local width = self.width
	local height = self.height
	
	if self.x < -width  or self.x > (magicres.right + width) or self.y < -height  or self.y > (magicres.bottom + height) then
		self:removeEventListener("enterFrame", self)
		self.flicked = self.flicked + 1
		flicks = self.flicked
		if self.level > 1 and self.level > self.flicked then
			if self.level == 1 then lev = 'level1' end
			if self.level == 2 then lev = 'level2' end
			if self.level == 3 then lev = 'level3' end
			if self.level == 4 then lev = 'level4' end
			newSpectre = spectre.createSpectre({lev,  self.x,  self.y})
			newSpectre.flicked = self.flicked
			newSpectre.enterFrame = moveCreatures
			Runtime:addEventListener("enterFrame", newSpectre)
			table.insert(spectreTable, newSpectre)
		end
		self.isVisible = false
		self.kill = true
	end
	
	self.x = self.x +  self.speed*math.cos(self.angle)
	self.y = self.y + self.speed*math.sin(self.angle)
end



function onTouchScreen(event)
	
	local function spawnDarkMitesByLevel(i)
		transition.to( darkMiteTable[i] , {time = 100, width = 0, height = 0})
		local x = darkMiteTable[i].x 
		local y = darkMiteTable[i].y	
		darkMiteTable[i].kill = true
		--Level 2 Darkmites spawn a single Level 1 Darkmite when they die
		if darkMiteTable[i].level == "level2" then
			newMite = darkMites.createDarkMite({'level1',  x ,  y })
			newMite.enterFrame = moveCreatures
			Runtime:addEventListener("enterFrame", newMite)
			table.insert(darkMiteTable, newMite)
		end
		--Level 3 Darkmites spawn 3 Level 2 Darkmites when they die
		if darkMiteTable[i].level == "level3" then
			newMite = darkMites.createDarkMite({'level2',  x - 10,  y - 10})
			newMite.enterFrame = moveCreatures
			Runtime:addEventListener("enterFrame", newMite)
			table.insert(darkMiteTable, newMite)
						
			newMite2 = darkMites.createDarkMite({'level2',  x + 10,  y + 10})
			newMite2.enterFrame = moveCreatures
			Runtime:addEventListener("enterFrame", newMite2)
			table.insert(darkMiteTable, newMite2)
			end
		--Level 4 Darkmites spawn 4 Level 3 Darkmites when they die.
		if darkMiteTable[i].level == "level4" then
			newMite = darkMites.createDarkMite({'level3',  x - 20,  y + 20})
			newMite.enterFrame = moveCreatures
			Runtime:addEventListener("enterFrame", newMite)
			table.insert(darkMiteTable, newMite)
				
			newMite2 = darkMites.createDarkMite({'level3',  x + 20,  y + 20})
			newMite2.enterFrame = moveCreatures
			Runtime:addEventListener("enterFrame", newMite2)
			table.insert(darkMiteTable, newMite2)
				
			newMite2 = darkMites.createDarkMite({'level3',  x + 20,  y - 20})
			newMite2.enterFrame = moveCreatures
			Runtime:addEventListener("enterFrame", newMite2)
			table.insert(darkMiteTable, newMite2)
				
			newMite2 = darkMites.createDarkMite({'level3',  x - 20,  y - 20})
			newMite2.enterFrame = moveCreatures
			Runtime:addEventListener("enterFrame", newMite2)
			table.insert(darkMiteTable, newMite2)
		end
		killMon = table.remove(darkMiteTable, i)
		killMon = nil
	end

	if event.phase == 'began' then
		bx, by = event.x, event.y
	end
	if event.phase == 'moved' then
		for i = #lines +1, #lines + 1 do
			lines[i] = display.newLine(bx, by, event.x, event.y)
            lines[i]:setColor(100, 100, 255)
            lines[i].strokeWidth = 5
            local newLine = lines[i]
            lines[i].transition = transition.to(newLine, {strokeWidth = 1, time = 200 })
			
			timer.performWithDelay(200, function() newLine:removeSelf() newLine = nil end) 
			newLine.x1, newLine.x2, newLine.y1, newLine.y2 = bx, event.x, by, event.y
			--print(newLine.x1, newLine.x2, newLine.y1, newLine.y2)
			killTendrilFnc(newLine)	
			bx, by = event.x, event.y
		end
	
		startTime = gameTimeMs
		for i = #spectreTable, 1, -1 do
			local deltaX = event.x - spectreTable[i].x
			local deltaY = event.y - spectreTable[i].y 
			local distance = math.sqrt(deltaX*deltaX + deltaY*deltaY)
			local combinedSize = spectreTable[i].contentWidth/2 + radius
			
			--If Spectre is dragged into the light
			local dX = W/2 - spectreTable[i].x
			local dY = H/2- spectreTable[i].y 
			local lightDistance = math.sqrt(dX*dX + dY*dY)
			if (lightDistance < spectreTable[i].contentWidth/2 + light.radius ) then
					updateLight("reduce") 
					spectreTable[i].isVisible = false
					spectreTable[i].kill = true
					break
			end
			
			if (distance < combinedSize) then
				local deltaX = math.sqrt((event.x - event.xStart)*(event.x - event.xStart))
				local deltaY = math.sqrt((event.y - event.yStart)*(event.y - event.yStart))
				local angle 
				
				if event.x <= event.xStart and event.y <= event.yStart then
					angle = (math.atan2(deltaY, deltaX))
				elseif event.x >= event.xStart and event.y <= event.yStart then
					angle = (math.pi - math.atan2(deltaY, deltaX))
				elseif event.x <= event.xStart and event.y >= event.yStart then
					angle = - math.atan2(deltaY, deltaX)
				elseif event.x >= event.xStart and event.y >= event.yStart then
					angle = (-math.pi + math.atan2(deltaY, deltaX))
				end
				flickSpectre = spectreTable[i]
				flickSpectre.speed = distance
				flickSpectre.x, flickSpectre.y = event.x, event.y
				flickSpectre.angle = angle
				flicked = true
				break
			end
		end
	end

	if event.phase == "ended" and pauseGame == false then
		endTime = gameTimeMs
		local circle = display.newCircle(event.x, event.y, radius)
		circle.isVisible = false
		
		--Collission Detection
		for i = #darkMiteTable, 1, -1 do
			local deltaX = event.x - darkMiteTable[i].x
			local deltaY = event.y - darkMiteTable[i].y 
			local distance = math.sqrt(deltaX*deltaX + deltaY*deltaY)
			local combinedSize = darkMiteTable[i].contentWidth/2 + radius
			if (distance < combinedSize) then
				spawnDarkMitesByLevel(i)
			end
		end
		for i = #photonTable, 1, -1 do
			local deltaX = event.x - photonTable[i].x
			local deltaY = event.y - photonTable[i].y 
			local distance = math.sqrt(deltaX*deltaX + deltaY*deltaY)
			local combinedSize = photonTable[i].contentWidth/2 + radius
			if (distance < combinedSize) then
				photonTable[i].speed = 15
			end
		end
	end
	
	if(flicked == true) then
		local deltaTime = endTime - startTime
		flickSpectre.speed = flickSpectre.speed/deltaTime
		flickSpectre:removeEventListener("enterFrame", moveCreatures)
		flickSpectre.enterFrame = flickSpectreFnc
		Runtime:addEventListener("enterFrame", flickSpectre)
		flickSpectre = {}
		flickSpectre.angle = 0
		flicked = false
	end
end

function checkGameOver()
	if(gameOver == true) then		
		killAllCreatures()
		pause.isVisible = false
		light.light.isVisible = false
		timer.cancel(myTimer)
		timer.cancel(timerLight)
		Runtime:removeEventListener("enterFrame", newTendril)
		if setScore == false then
			myHighScore = highScore.getHighScore()
			if (gameTime > myHighScore) then
				highScore.setHighScore(gameTime)
				highScore.saveScore()
			end
			setScore = true
		end
		options = { effect = "crossFade", time = 200, params = { newScore = gameTime} }
		storyboard.showOverlay("gameOverScreen", options)
		counterDm = 0
		counterSp = 0
		counterTn = 0
		gameOver = false
		gameTime = 0
	else
		gameTimeMs = gameTimeMs + 1
	end
end

function onPressPause()
	pauseText= display.newText("Pause", W/2, H/3, "",  30)
	resumeText = display.newText("resume", W/2, H/2, "",  26)
	menuText = display.newText("main menu", W/2, H/2 + 30, "",  26)
	light.light.isVisible = false
	pause_bg.isVisible = true
	newGroup:insert(pause_bg)
	newGroup:insert(pauseText)
	newGroup:insert(resumeText)
	newGroup:insert(menuText)
	timer.pause(myTimer)
	pauseGame = true
	pause.isVisible = false
	resumeText:addEventListener('touch', onPressResume)
	menuText:addEventListener('touch', onPressMenu)
end

function onPressResume()
	menuText.isVisible = false
	resumeText.isVisible = false
	pauseText.isVisible = false
	light.light.isVisible = true
	pause_bg.isVisible = false
	pauseGame = false
	pause.isVisible = true
	timer.resume(myTimer)
end

function onPressMenu(event)
	if event.phase == "began" then
		killAllCreatures()
		light.light.isVisible = false
		timer.cancel(myTimer)
		timer.cancel(timerLight)
		menuText.isVisible = false
		resumeText.isVisible = false
		pauseText.isVisible = false
		pause_bg.isVisible = false
		pauseGame = false
		pause.isVisible = false
		pause:removeEventListener('tap', onPressPause)
		Runtime:removeEventListener("enterFrame", newTendril)
		Runtime:removeEventListener("touch", onTouchScreen)
		Runtime:removeEventListener("touch", onFlickScreen)
		storyboard.purgeScene("mainMenuScreen") 
		storyboard.gotoScene("mainMenuScreen", "crossFade", 200)
	end
end

function scene:enterScene(event)
	myTimer = timer.performWithDelay(tick, gameTimerFnc, -1)
	timer.performWithDelay(1, checkGameOver, -1)
	
	local tempupdateLight = function() return updateLight( "increase" ) end
	timerLight = timer.performWithDelay(1000, tempupdateLight, -1)
	
	pause:addEventListener('tap', onPressPause)
	Runtime:addEventListener("touch", onTouchScreen)
end

function scene:exitScene(event)
	killAllCreatures()
	pause.isVisible = false
	light.light.isVisible = false
	timer.cancel(myTimer)
	timer.cancel(timerLight)
	gameOver = false
	gameTime = 0
	pause:removeEventListener('tap', onPressPause)
	Runtime:removeEventListener("enterFrame", newTendril)
	Runtime:removeEventListener("touch", onTouchScreen)
	Runtime:removeEventListener("touch", onFlickScreen)
end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene