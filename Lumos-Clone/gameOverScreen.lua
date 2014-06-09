local magicres = require("magicres")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

W, H = display.contentWidth, display.contentHeight

function scene:createScene(event)
	screenGroup = self.view
	local newTime = event.params.newScore
	local bg = display.newImage(screenGroup, "imgs/gameover/bg.png", W/2, H/2 )
	seconds = roundDecimal(newTime%60)
	minutes = math.round(newTime/60)%60
	hours = math.round(newTime/3600)
	if hours == 0 then hours = '00' end
	if seconds < 10 then
		seconds = '0'..seconds
	end
	if minutes < 10 then
		minutes = '0'..minutes
	elseif minutes == 0 then 
		minutes = '00'	
	end
	newScore = hours..':'..minutes..':'..seconds
	highScore = display.newText(newScore, W/2, H/2 -50, "",  50)
	restartText = display.newText('Restart', W/2 - 50, H/2 + 60, "",  25)
	menuText = display.newText('Main Menu', W/2 + 120, H/2 + 60, "",  25)
	bg:scale( magicres.right / bg.contentWidth, magicres.bottom / bg.contentHeight )
	restart = display.newImage(screenGroup , "imgs/gameover/restart.png", W/2 - 120, H/2 + 60)
	mainMenu = display.newImage(screenGroup , "imgs/gameover/menu.png", W/2 + 30, H/2 + 60)
	screenGroup:insert(highScore)
	screenGroup:insert(restartText)
	screenGroup:insert(menuText)
end

function roundDecimal(t)
    return math.round(t*10)*0.1
end

function onPressRestart(event)
	if event.phase == "ended" then
		storyboard.purgeScene("mainGameScreen") 
		storyboard.gotoScene("mainGameScreen", "crossFade", 200)
	end
end

function onPressMenu(event)
	if event.phase == "ended" then
		storyboard.purgeScene("mainMenuScreen") 
		storyboard.gotoScene("mainMenuScreen", "crossFade", 200)
	end
end

function scene:enterScene(event)
	restart:addEventListener('touch', onPressRestart)
	restartText:addEventListener('touch', onPressRestart)
	mainMenu:addEventListener('touch', onPressMenu)
	menuText:addEventListener('touch', onPressMenu)
end

function scene:exitScene( event )
	restart:removeEventListener('touch', onPressRestart)
	restartText:removeEventListener('touch', onPressRestart)
	mainMenu:removeEventListener('touch', onPressMenu)
	menuText:removeEventListener('touch', onPressMenu)
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