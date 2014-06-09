local magicres = require("magicres")
local storyboard = require( "storyboard" )
local highScore = require("saveScore")
local scene = storyboard.newScene()

W, H = display.contentWidth, display.contentHeight

function scene:createScene(event)
	local screenGroup = self.view
	local bg = display.newImage(screenGroup, "imgs/bg.jpg", W/2, H/2)
	local logo = display.newImage(screenGroup, "imgs/mainmenu/logo.png", W/2, H/2 - 100)
	normal = display.newImage(screenGroup, "imgs/mainmenu/play_normal.png", W/2, H/2 + 10)
	scores = display.newImage(screenGroup, "imgs/mainmenu/highscores.png", W/2, H/2 + 120)
	normalText = display.newText('Normal Mode', W/2, H/2 + 80, "",  20)
	screenGroup:insert(normalText)
	logo:scale(.50, .50)
	normal:scale(.40, .40)
	scores:scale(.60, .60)
	bg:scale( magicres.right / bg.contentWidth, magicres.bottom / bg.contentHeight )
end

function onPressStart(event)
	if event.phase == "ended" then
		storyboard.purgeScene("mainGameScreen") 
		storyboard.gotoScene("mainGameScreen", "crossFade", 200)
	end
end

function onPressScore(event)
	if event.phase == "ended" then
		storyboard.purgeScene("highScoreScreen") 
		storyboard.gotoScene("highScoreScreen", "crossFade", 200)
	end
end

function scene:enterScene(event)
	 scores:addEventListener('touch', onPressScore)
	 normal:addEventListener('touch', onPressStart)
	 normalText:addEventListener('touch', onPressStart)
end

function scene:exitScene( event )
	normal:removeEventListener('touch', onPressStart)
	normalText:removeEventListener('touch', onPressStart)
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