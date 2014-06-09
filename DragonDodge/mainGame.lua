local highScore = require("saveScore")
local physics = require("physics")
physics.start()
physics.setGravity( 0, 9.8 )

W, H = display.contentWidth, display.contentHeight

--Storyboard (Multiple Screen Handling)
local storyboard = require("storyboard")
local scene = storyboard.newScene()
local scoreText = highScore.init({ filename = "score.txt" })
local myHighScore = 0
local achievement = false

function scene:createScene(event)
	screenGroup = self.view
	pauseGame = false
	touch = false
	
	--Background Side Scroller
	bg = display.newImage(screenGroup, "imgs/bg_sky.png", W/2, H/2)
	grass1 = display.newImage(screenGroup, "imgs/bg_grass.png", W/2, H/2)
	grass1_copy = display.newImage(screenGroup, "imgs/bg_grass.png", (3/2)*W, H/2)
	grass2 = display.newImage(screenGroup, "imgs/bg_grass2.png", W/2, H/2)
	grass2_copy = display.newImage(screenGroup, "imgs/bg_grass2.png", (3/2)*W, H/2)
	
	grass1.speed = 4
	grass2.speed = 6
	grass1_copy.speed = 4
	grass2_copy.speed = 6
	
	--Flying Dragon
	dragonSheetData = require("imgs.dragon_sheet")
	dragonSheet = graphics.newImageSheet( "imgs/dragon_fly.png", dragonSheetData:getSheet() )
	dragonSequenceData = {
		frames = {1, 2, 3, 4 },
		time = 450,
	}
	
	touchInst = display.newImage(screenGroup, "imgs/touch.png", W/2 , H - 25)
	dragon = display.newSprite(dragonSheet, dragonSequenceData)
	dragon.name= "dragon"
	screenGroup:insert(dragon)
	physics.addBody(dragon, "dyanamic")
	dragon.collide = false
	dragon.x = 120
	dragon.y = 100 
	dragon:play()
	
	--Display Score via Timer
	myScore = 0
	scoreBoard = display.newImage(screenGroup, "imgs/score.png", W/2 + 10, 25)
	score = display.newText(myScore, W/2 + 50, 26, "Super Mario 256", 22)
	score:setFillColor(250, 250, 250)
	screenGroup:insert(score)
	myTimer = timer.performWithDelay(1000, scoreTracker, myScore)
	physics.addBody(scoreBoard, "static")
	physics.addBody(score, "static")

	--Flying Bombs
	bombSheetData = require("imgs.bomb_sheet")
	bombSheet = graphics.newImageSheet( "imgs/bomb_sheet.png", bombSheetData:getSheet() )

	bombSequenceData = {
		frames = {1, 2, 3},
		time = 500,
	}
	
	loseGame = false
	no_bombs = {}

	bomb1 = display.newSprite(bombSheet, bombSequenceData)
	bomb1.name = "bomb1"
	physics.addBody(bomb1, "static")
	screenGroup:insert(bomb1)
	bomb1.x = 500
	bomb1.y = 100
	bomb1.sourceY = bomb1.y 
	bomb1.speed = math.random(7,12)
	bomb1:play()

	bomb2 = display.newSprite(bombSheet, bombSequenceData)
	bomb2.name = "bomb2"
	physics.addBody(bomb2, "static")
	screenGroup:insert(bomb2)
	bomb2.x = 500
	bomb2.y = 500
	bomb2.sourceY = bomb2.y 
	bomb2.speed = math.random(7,12)
	bomb2:play()

	--Collission Detection and Explosion
	explosionSheetData = require("imgs.explode_sheet")
	explosionImageSheet = graphics.newImageSheet( "imgs/explode_sheet.png", explosionSheetData:getSheet() )
	explosionSequenceData = {
		frames = {1, 2, 3, 4, 5},
		time = 400,
		loopCount = 1
	}

	explosion = display.newSprite(explosionImageSheet, explosionSequenceData)
	explosion.isVisible = false
	
	--Top and Bottom Screen Collision
	invBarTop = display.newImage(screenGroup, "imgs/invisible_bar.png", 0, -30)
	invBarBottom = display.newImage(screenGroup, "imgs/invisible_bar.png", 0, H + 28)
	invBarTop.name = "invTop"
	invBarBottom.name = "invBottom"
	physics.addBody(invBarTop, "static")
	physics.addBody(invBarBottom, "static")
	
	--Pause and Play Buttons Button
	pause = display.newImage(screenGroup, "imgs/pause_button.png", 27, H - 27)
	pauseBg = display.newImage(screenGroup, "imgs/pause_game_bg.png", W/2, H/2)
	play = display.newImage(screenGroup, "imgs/start.png", W/2, H/2 + 20)
	pauseRestart = display.newImage(screenGroup , "imgs/pause_restart.png", W/2 - 100, H/2 + 30)
	pauseMenu = display.newImage(screenGroup , "imgs/pause_menu.png", W/2 + 100, H/2 + 30)
	play.isVisible = false
	pauseBg.isVisible = false
	pauseRestart.isVisible = false
	pauseMenu.isVisible = false
end


function scoreTracker()
	myScore = myScore + 1
	score.text = myScore	
end

function touchScreen(event)
	if event.phase == "began" then
		if pauseGame == false then 
			if touch == false then
				touchInst.isVisible = false
			end
			if dragon.collide == false then
				flySound =  audio.loadSound("fly.wav")
				audio.play(flySound)
				audio.setVolume(1) 
				dragon:applyLinearImpulse(0, -0.25, dragon.x, dragon.y)
			end
		end
	end
end

function sideScroll(self, event)
	if pauseGame == false then
		if self.x < -W/2 + 10 then
			self.x = (3/2)*W  
		else
			self.x = self.x - self.speed
		end
	end
end

function moveBomb(self, event)
	if pauseGame == false then
		rand = math.random(1, 12)
		if self.x < -W/rand then
			self.x = W 
			self.y = math.random(0, H-5)
		else
			self.x = self.x - self.speed
		end
	end
end

function setHighScore()
	myHighScore = highScore.getHighScore()
	if (myScore > myHighScore) then
		achievement = true
		highScore.setHighScore(myScore)
		highScore.saveScore()
	end
end

function showGameOverScreen(event)
	touchInst.isVisible = false
	pause.isVisible = false
	scoreBoard.isVisible = false
	score.isVisible = false
	setHighScore()
	options = { effect = "crossFade", time = 200, params = { newScore = myScore, achieve = achievement } }
	storyboard.showOverlay("gameOverScreen", options)
	scoreBoard.isVisible = true
	score.isVisible = true
	achievement = false
end

function onPressPause(event)
	if dragon.collide == false then
		if event.phase == "ended" then
			pauseGame = true
			dragon:pause()
			bomb1:pause()
			bomb2:pause()
			timer.pause(myTimer)
			pause.isVisible = false
			physics.pause()
			pauseBg.isVisible = true
			play.isVisible = true
			Runtime:removeEventListener("touch", touchScreen) 
			play:addEventListener('touch', onPressPlay)
		end
	end
end

function onPressPlay(event)
	if event.phase == "ended" then
		pauseGame = false
		grass1.enterFrame = sideScroll
		dragon:play()
		bomb1:play()
		bomb2:play()
		timer.resume(myTimer)
		physics.start()
		pauseBg.isVisible = false
		pauseRestart.isVisible = false
		pauseMenu.isVisible = false
		play.isVisible = false
		pause.isVisible = true
		Runtime:addEventListener("touch", touchScreen)
	end
end

function onCollision(event)
	if event.phase == "began" then
		if dragon.collide == false then
			dragon.collide = true
			dragon.bodyType = "static"
			dragon.isVisible = false
			if event.object2.name == "bomb1" then
				bomb1.collide = true
				bomb1.bodyType = "static"
				bomb1.isVisible = false
				explosion.x = (bomb1.x + dragon.x)/2
				explosion.y = (bomb1.y + dragon.y)/2
			elseif event.object2.name == "bomb2" then
				bomb2.collide = true
				bomb2.bodyType = "static"
				bomb2.isVisible = false
				explosion.x = (bomb2.x + dragon.x)/2
				explosion.y = (bomb2.y + dragon.y)/2
			else
				explosion.x = dragon.x
				explosion.y = dragon.y
			end
			explodeSound =  audio.loadSound("explode.wav")
			audio.play(explodeSound)
			audio.setVolume(1) 
			explosion.isVisible = true
			explosion:play()
			timer.cancel(myTimer)
			timer.performWithDelay(1100, showGameOverScreen)
		end		
	end
end

function scene:enterScene(event)
	grass1.enterFrame = sideScroll
	Runtime:addEventListener("enterFrame", grass1)
	grass1_copy.enterFrame = sideScroll
	Runtime:addEventListener("enterFrame", grass1_copy)
	grass2.enterFrame = sideScroll
	Runtime:addEventListener("enterFrame", grass2)
	grass2_copy.enterFrame = sideScroll
	Runtime:addEventListener("enterFrame", grass2_copy)
	bomb1.enterFrame = moveBomb
	Runtime:addEventListener("enterFrame", bomb1)
	bomb2.enterFrame = moveBomb
	Runtime:addEventListener("enterFrame", bomb2)
	Runtime:addEventListener( "collision", onCollision )
	Runtime:addEventListener("touch", touchScreen) 
	pause:addEventListener('touch', onPressPause)
end

function scene:exitScene(event)
	Runtime:removeEventListener("enterFrame", grass1)
	Runtime:removeEventListener("enterFrame", grass1_copy)
	Runtime:removeEventListener("enterFrame", grass2)
	Runtime:removeEventListener("enterFrame", grass2_copy)
	Runtime:removeEventListener("enterFrame", bomb1)
	Runtime:removeEventListener("enterFrame", bomb2)
	Runtime:removeEventListener("touch", touchScreen) 
	Runtime:removeEventListener("collision", onCollision )
	pause:removeEventListener('touch', onPressPause)
end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene
