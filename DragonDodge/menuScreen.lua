local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

W, H = display.contentWidth, display.contentHeight
soundOn = true

function scene:createScene(event)
	screenGroup = self.view
	
	bgm =  audio.loadSound("bgm.wav")
	audio.play(bgm, {channel = 4, loops = -1, fadein = 5000, fadeout = 5000, volume = 0.05})
	audio.setVolume(0.05) 
	
	bg = display.newImage(screenGroup, "imgs/bg_sky.png", W/2, H/2)
	grass1 = display.newImage(screenGroup, "imgs/bg_grass.png", W/2, H/2)
	grass1_copy = display.newImage(screenGroup, "imgs/bg_grass.png", (3/2)*W, H/2)
	grass2 = display.newImage(screenGroup, "imgs/bg_grass2.png", W/2, H/2)
	grass2_copy = display.newImage(screenGroup, "imgs/bg_grass2.png", (3/2)*W, H/2)
	
	title = display.newImage(screenGroup , "imgs/title.png", W/2, H/2)
	play = display.newImage(screenGroup , "imgs/start.png", W/2 - 135, H/2 + 65)
	scores = display.newImage(screenGroup , "imgs/score_button.png", W/2 - 10, H/2 + 65)
	sounds = display.newImage(screenGroup , "imgs/settings.png", W/2 + 125, H/2 + 65)
	noSound = display.newImage(screenGroup , "imgs/sound_off.png", W/2 + 125, H/2 + 65)
	
	if soundOn == true then
		noSound.isVisible = false
	end
	
	grass1.speed = 5
	grass2.speed = 6
	grass1_copy.speed = 5
	grass2_copy.speed = 6
end

function sideScroll(self, event)
	if self.x < -W/2 + 10 then
		self.x = (3/2)*W  
	else
		self.x = self.x - self.speed
	end
end

function onPressPlayButton(event)
	if event.phase == "ended" then
		storyboard.purgeScene("mainGame") 
		storyboard.gotoScene("mainGame", "crossFade", 50)
	end
end

function onPressSoundOff(event)
	if event.phase == "ended" then
		if soundOn == true then
			soundOn = false
			audio.pause(bgm)
			noSound.isVisible = true
		elseif soundOn == false then
			soundOn = true
			audio.stop(4)
			audio.play(bgm, {channel = 4, loops = -1, fadein = 5000, fadeout = 500, volume = 0.05})
			noSound.isVisible = false
		end
	end
end


function scene:enterScene( event )
	grass1.enterFrame = sideScroll
	Runtime:addEventListener("enterFrame", grass1)
	grass1_copy.enterFrame = sideScroll
	Runtime:addEventListener("enterFrame", grass1_copy)
	grass2.enterFrame = sideScroll
	Runtime:addEventListener("enterFrame", grass2)
	grass2_copy.enterFrame = sideScroll
	Runtime:addEventListener("enterFrame", grass2_copy)
	
	play:addEventListener('touch', onPressPlayButton)
	sounds:addEventListener('touch', onPressSoundOff)
end

function scene:exitScene( event )
	Runtime:removeEventListener("enterFrame", grass1)
	Runtime:removeEventListener("enterFrame", grass1_copy)
	Runtime:removeEventListener("enterFrame", grass2)
	Runtime:removeEventListener("enterFrame", grass2_copy)
	
	play:removeEventListener('touch', onPressPlayButton)
	if soundOn == true then
		sounds:removeEventListener('touch', onPressSoundOff)
	end
	
end

function scene:destroyScene( event )
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene
