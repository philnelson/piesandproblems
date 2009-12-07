screenWidth = 21
screenHeight = 16

gridSize = 48

width = screenWidth * gridSize
height = screenHeight * gridSize

screenMode = love.graphics.setMode( width, height, false, false, 0 )

-- Init
math.randomseed( os.time() )
math.random(); math.random(); math.random()
love.audio.setMode( love.audio_quality_low, 1, 8 )
love.graphics.setLineStyle( love.line_rough )
love.graphics.setLineWidth( 4 )

-- First two rows are covered by the display
map = {
	{190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190},
	{190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190},
	{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
	{3,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,3},
	{3,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,3},
	{3,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,3},
	{3,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,3},
	{3,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,3},
	{3,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,3},
	{3,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,3},
	{3,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,3},
	{3,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,3},
	{3,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,3},
	{3,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,3},
	{3,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,3},
	{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
}

downStairsLocationX = math.random(2,20)
downStairsLocationY = math.random(1,15)

map[downStairsLocationY][downStairsLocationX] = 24

turn = 0
currentFloor = 0

volume = .5

love.audio.setVolume(volume)

topMenuHeight = gridSize*2

elapsed = 0
lastkey = 0
animationsRun = 0
loadingFloorDownWipe = false

loadingFloorDownWipeAnimationH = 0
loadingFloorDownWipeAnimationW = 0

optionsOpen = false
orcIsHit = false

function load()
	positionCharacter()
	positionBaddie()
	
	arrowIsUp = false

	loadSounds()

	headerFont = love.graphics.newFont('04B_03__.TTF', 48)
	font = love.graphics.newFont('04B_03__.TTF', 24)
	love.graphics.setFont(font)
	
	sprites = love.graphics.newImage( 'lofi_char_a_48.png' )
	environment = love.graphics.newImage( 'lofi_environment_a_48.png' )
	objects = love.graphics.newImage( 'lofi_obj_a_48.png' )

	love.audio.play( overWorldTheme, 0 )
end

function draw()
	generateRoom(currentFloor)
	
	love.graphics.setColor( 255, 255, 0 )
	for y=0, screenHeight do
		for x=0, screenWidth do                                                         
			--love.graphics.line( x*gridSize, 0, x*gridSize, (screenHeight)*gridSize )
		end
	--	love.graphics.line( 0, y*gridSize, (screenWidth)*gridSize, y*gridSize )
	end
	
	-- draw UI text
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw("Turns: " .. turn, 5, 32)
	love.graphics.draw("P: " .. math.ceil(charX/48) .. "," .. math.ceil(charY/48) .. " / S: "..downStairsLocationX..","..downStairsLocationY.." "..map[math.ceil(charY/48)][math.ceil(charX/48)], 5, 50)
	love.graphics.draw("Elapsed: "..elapsed, 5, 70)
	
	love.graphics.draws( sprites, charX, charY, charSpriteX, charSpriteY, gridSize, gridSize)
	love.graphics.draws( sprites, orcX, orcY, 480, 384, gridSize, gridSize)
	
	if optionsOpen == true then
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.rectangle( 1, ((width/2)-((width/2)/2)), ((height/2)-((height/2)/2)), (width/2), (height/2) )
		love.graphics.setColor( 0, 0, 0 )
		love.graphics.rectangle( 0, ((width/2)-((width/2)/2))+1, ((height/2)-((height/2)/2))+1, (width/2)-2, (height/2)-2 )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.setFont(headerFont)
		love.graphics.draw("Options", ((width/2)-((width/2)/2))+16, ((height/2)-((height/2)/2))+48)
		love.graphics.setFont(font)
		love.graphics.draw("Volume: " .. (volume*100) .."%", ((width/2)-((width/2)/2))+16, ((height/2)-((height/2)/2))+96)
	end
	
	if arrowIsUp == true then
		if arrowFiredFrom == "up" then
			love.graphics.draws(objects, arrowX,arrowY-40,480, 240,gridSize,gridSize)
		end
		if arrowFiredFrom == "right" then
			love.graphics.draws(objects, arrowX+40,arrowY,575, 240,gridSize,gridSize)
		end
		if arrowFiredFrom == "down" then
			love.graphics.draws(objects, arrowX,arrowY+40,288, 240,gridSize,gridSize)
		end
		if arrowFiredFrom == "left" then
			love.graphics.draws(objects, arrowX-40,arrowY,385, 240,gridSize,gridSize)
		end
	end
	
	if orcIsHit == true then
		love.graphics.draws(objects, orcX, orcY, 192,240,gridSize,gridSize)
	end
	
	if loadingFloorDownWipe == true then
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle(0,0,0,width,loadingFloorDownWipeAnimationH)
		if loadingFloorDownWipeAnimationH >= height then
			love.graphics.setColor( 255, 255, 255 )
			love.graphics.setFont(headerFont)
			love.graphics.draw("Floor 1",width/2,height/2)
			love.graphics.setFont(font)
			love.graphics.draw('"doomhaven"',width/2,(height/2)+48)
		end
	end

end

function update(dt)
	elapsed = math.floor(love.timer.getTime( ))

	if arrowIsUp == true then
		if arrowFiredFrom == "up" then
			arrowY = arrowY-(dt*500)
		end
		if arrowFiredFrom == "right" then
			arrowX = arrowX+(dt*500)
		end
		if arrowFiredFrom == "down" then
			arrowY = arrowY+(dt*500)
		end
		if arrowFiredFrom == "left" then
			arrowX = arrowX-(dt*500)
		end
	end
	
	if loadingFloorDownWipe == true then
		if loadingFloorDownWipeAnimationH >= height then
			
		else
			loadingFloorDownWipeAnimationH = loadingFloorDownWipeAnimationH+2
		end
	end

end

function keypressed(key)
	if key == love.key_right then 
		moveCharacter("right")
	end
	if key == love.key_left then 
		moveCharacter("left")
	end
	if key == love.key_up then 
		moveCharacter("up")
	end
	if key == love.key_down then 
		moveCharacter("down")
	end
	if key == love.key_space then 
		charShoot()
	end
	if key == love.key_r then
		love.system.restart( )
	end
	if key == love.key_o then
		showOptions()
	end
	if key == love.key_q then
		love.system.exit()
	end
	if key == 57 then
		if volume > .1 then
			volume = volume - .1
		end
		if volume > 1 then
			volume = 0
		end
		love.audio.setVolume(volume)
	end
	if key == 48 then
		if volume < .9 then
			volume = volume + .1
		end
		if volume > 1 then
			volume = 1
		end
		love.audio.setVolume(volume)
	end
	if key == love.key_s then
		love.graphics.screenshot(os.time()..'.bmp')
	end
	if key == love.key_f then
		love.graphics.toggleFullscreen( )
	end
	lastkey = key
end

function loadSounds()
	overWorldTheme = love.audio.newSound('Mr Fluff.ogg')

	charSwordSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/attack03.wav')
	charShootSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/rocket01.wav')

	weaponHitSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/impact01.wav')
	weaponHitSound2 = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/impact02.wav')

	uiOpenSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/open01.wav')
end

function positionBaddie()
	goodX = false
	goodY = false

	while goodX == false do
		orcX = (gridSize * math.random(1,screenWidth))+24
		if orcX > gridSize*2-(gridSize/2) then
			if orcX < (screenWidth*gridSize)-(gridSize/2) then
				goodX = true
			end
		end
	end

	while goodY == false do
		orcY = (gridSize * math.random(1,screenHeight))+24
		if orcY > topMenuHeight+gridSize*2-(gridSize/2) then
			if orcY < (screenHeight*gridSize)-(gridSize/2) then
				goodY = true
			end
		end
	end
end

function positionCharacter()
	charSpriteX = 0
	charSpriteY = gridSize*29

	-- Position character

	charX = 0
	charY = 0

	goodX = false
	goodY = false

	while goodX == false do
		charX = (gridSize * math.random(1,screenWidth))+24
		if charX > gridSize*2-(gridSize/2) then
			if charX < (screenWidth*gridSize)-(gridSize/2) then
				goodX = true
			end
		end
	end

	while goodY == false do
		charY = (gridSize * math.random(1,screenHeight))+24
		if charY > topMenuHeight+gridSize*2-(gridSize/2) then
			if charY < (screenHeight*gridSize)-(gridSize/2) then
				goodY = true
			end
		end
	end
	
	arrowX = charX
	arrowY = charY

	charIsFacing = "right"
	arrowFiredFrom = charIsFacing
	
end

function charAttack()
	love.audio.play(charSwordSound)
	orcIsHit = true
	turn = turn+1;
end

function charShoot()
	arrowX = charX;
	arrowY = charY;
	arrowFiredFrom = charIsFacing
	arrowIsUp = true
	love.audio.play(charShootSound)
	turn = turn+1;
end

function moveCharacter(direction)
	if direction == "left" then
		charSpriteX = 96
		if (charX-gridSize) >= (gridSize) then
			if charX-gridSize == orcX then
				if charY == orcY then
					charAttack()
				else
					charX = charX-gridSize
				end
			else
				charX = charX-gridSize
			end
		end
		charIsFacing = "left"
		turn = turn+1;
	end

	if direction == "right" then
		charSpriteX = 0
		if (charX+gridSize) <= (width)-gridSize then
			if charX+gridSize == orcX then
				if charY == orcY then
					charAttack()
				else
					charX = charX+gridSize
				end
			else
				charX = charX+gridSize
			end
		end
		charIsFacing = "right"
		turn = turn+1;
	end

	if direction == "up" then
		charSpriteX = 144
		if (charY-gridSize) > (gridSize*2)+(gridSize/2) then
			if charY-gridSize == orcY then
				if charX == orcX then
					charAttack()
				else
					charY = charY-gridSize
				end
			else
				charY = charY-gridSize
			end
		end
		charIsFacing = "up"
		turn = turn+1;
	end

	if direction == "down" then
		charSpriteX = 48
		if (charY+gridSize) < (height-gridSize) then
			if charY+gridSize == orcY then
				if charX == orcX then
					charAttack()
				else
					charY = charY+gridSize
				end
			else
				charY = charY+gridSize
			end
		end
		charIsFacing = "down"
		turn = turn+1;
	end
	
	if map[math.ceil(charY/48)][math.ceil(charX/48)] == 24 then
		loadFloor(currentFloor-1)
	end
	
end

function loadFloor(floor)
	loadingFloorDownWipe = true
end

function showOptions()
	if optionsOpen == true then
		optionsOpen = false
	else
		optionsOpen = true
	end
	love.audio.play(uiOpenSound)
end

function generateRoom(floor)
	-- draw main background
	love.graphics.setColor( 242, 220, 144 )
	love.graphics.rectangle( 0, 0, topMenuHeight, width, height )
	-- draw secondary background
	love.graphics.setColor( 56, 50, 34 )
	love.graphics.rectangle(0,48,topMenuHeight+48,width-96, (height-96)-(topMenuHeight))

	for y=3, screenHeight do
		for x=1, screenWidth do
			envSpriteY = math.floor((map[y][x]*48)/768)
			envSpriteX = map[y][x]
			while (envSpriteX > 16) do
				envSpriteX = envSpriteX - 16
			end
			if(envSpriteX < 0) then
				envSpriteX = 0
			end
			love.graphics.draws( environment, (x*gridSize)-24, (y*gridSize)-24, (envSpriteX*gridSize), (envSpriteY*gridSize),gridSize, gridSize )
		end
	end
end