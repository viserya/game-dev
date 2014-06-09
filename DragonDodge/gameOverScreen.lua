local storyboard = require( "storyboard" )
local highScore = require("saveScore")
local scene = storyboard.newScene()

W, H = display.contentWidth, display.contentHeight

function scene:createScene(event)
	screenGroup = self.view
	local newScore = event.params.newScore
	local achieveHighScore = event.params.achieve
	
	bg = display.newImage(screenGroup , "imgs/game_over_bg.png", W/2, H/2  )
	restart = display.newImage(screenGroup , "imgs/restart.png", W/2 - 70, H/2 + 60)
	mainMenu = display.newImage(screenGroup , "imgs/menu.png", W/2 + 70, H/2 + 60)
	
	scoreBoard = display.newImage(screenGroup, "imgs/score.png", W/2 + 10, H/2 - 65)
	score = display.newText(newScore, W/2 + 50, H/2 - 65, "Super Mario 256", 22)
	screenGroup:insert(score)
	
	highScoreBoard = display.newImage(screenGroup, "imgs/highscore.png", W/2 + 10, H/2 - 18)
	highScore = display.newText(highScore.getHighScore() , W/2 + 90, H/2 - 17, "Super Mario 256", 23)
	screenGroup:insert(highScore)
	score:setFillColor(250, 250, 250)
	
	if achieveHighScore == true then
		achievement = display.newImage(screenGroup , "imgs/achievement.png", W/2 - 97, H/2 - 57 )
	end
	achieveHighScore = false
end

function onPressRestart(event)
	if event.phase == "ended" then
		storyboard.purgeScene("mainGame") 
		storyboard.gotoScene("mainGame", "crossFade", 200)
	end
end

function onPressMenu(event)
	if event.phase == "ended" then
		storyboard.purgeScene("menuScreen") 
		storyboard.gotoScene("menuScreen", "crossFade", 200)
	end
end

function scene:enterScene(event)
	restart:addEventListener('touch', onPressRestart)
	mainMenu:addEventListener('touch', onPressMenu)
end

function scene:exitScene( event )
	restart:removeEventListener('touch', onPressRestart)
	mainMenu:removeEventListener('touch', onPressMenu)
end

function scene:destroyScene( event )

end

function catchBackgroundOverlay(event)
	return true
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene