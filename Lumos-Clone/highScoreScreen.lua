local magicres = require("magicres")
local storyboard = require( "storyboard" )
local highScore = require("saveScore")
local scene = storyboard.newScene()

W, H = display.contentWidth, display.contentHeight


function scene:createScene(event)
	local screenGroup = self.view
	local bg = display.newImage(screenGroup, "imgs/bg.jpg", W/2, H/2)
	
	highScore.loadScore()
	hScore = highScore.getHighScore()
	
	normal = display.newImage(screenGroup, "imgs/mainmenu/play_normal.png", W/2 - 90, H/2)
	normalText = display.newText('Best Time in Normal Mode', W/2 + 80, H/2 + 10 , "",  20)
	back = display.newImage(screenGroup, "imgs/etc/btn_realm_back.png", magicres.left + 25, 20)
	
	seconds = roundDecimal(hScore%60)
	minutes = math.round(hScore/60)%60
	hours = math.round(hScore/3600)
	
	if hours == 0 then hours = '00' end
	if minutes == 0 then minutes = '00'	end
	
	newScore = '00:'..hours..':'..minutes..':'..seconds
	highScoreText = display.newText(newScore, W/2 + 30, H/2 - 20, "",  30)
	
	screenGroup:insert(normalText)
	screenGroup:insert(highScoreText)
	normal:scale(.30, .30)
	bg:scale( magicres.right / bg.contentWidth, magicres.bottom / bg.contentHeight )
end

function roundDecimal(t)
    return math.round(t*10)*0.1
end

function onPressBack(event)
	if event.phase == "ended" then
		storyboard.purgeScene("mainMenuScreen") 
		storyboard.gotoScene("mainMenuScreen", "crossFade", 200)
	end
end

function scene:enterScene(event)
	back:addEventListener('touch', onPressBack)
end

function scene:exitScene( event )
	back:removeEventListener('touch', onPressBack)
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