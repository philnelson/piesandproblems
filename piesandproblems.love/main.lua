screenWidth = 15
screenHeight = 15

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

turn = 0

volume = .5

love.audio.setVolume(volume)

topMenuHeight = 96

elapsed = 0
lastkey = 0

optionsOpen = false
orcIsHit = false

function load()

	charSpriteX = 0
	charSpriteY = gridSize*29
	-- Position character
	
	charX = gridSize * math.random(1,20)
	charY = gridSize * math.random(3,15)
	while charX < 48 do
		charY = gridSize * math.random(1,20)
	end
	while charY < 144 do
		charY = gridSize * math.random(3,15)
	end

	arrowX = charX
	arrowY = charY

	charIsFacing = "right"
	arrowFiredFrom = charIsFacing

	-- position the Orc
	orcX = gridSize * math.random(1,20)
	orcY = 0

	arrowIsUp = false

	while orcY < 144 do
		orcY = gridSize * math.random(2,15)
	end

	overWorldTheme = love.audio.newSound('Mr Fluff.ogg')

	charSwordSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/attack03.wav')
	charShootSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/rocket01.wav')

	weaponHitSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/impact01.wav')
	weaponHitSound2 = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/impact02.wav')

	uiOpenSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/open01.wav')

	headerFont = love.graphics.newFont('04B_03__.TTF', 48)
	font = love.graphics.newFont('04B_03__.TTF', 24)
	love.graphics.setFont(font)
	
	sprites = love.graphics.newImage( 'lofi_char_a_48.png' )
	environment = love.graphics.newImage( 'lofi_environment_a_48.png' )
	objects = love.graphics.newImage( 'lofi_obj_a_48.png' )
	
	love.audio.play( overWorldTheme, 0 )
end

function draw()
	love.graphics.setColor( 242, 220, 144 )
	love.graphics.rectangle( 0, 0, topMenuHeight, width, height-96 )
	love.graphics.setColor( 56, 50, 34 )
	love.graphics.rectangle(0,48,topMenuHeight+48,width-96, (height-144)-(topMenuHeight))
	love.graphics.setColor( 255, 255, 255 )
	
	love.graphics.draw("Turns: " .. turn, 5, 32)
	love.graphics.draw("X: " .. charX .. " Y:" .. charY, 5, 50)
	love.graphics.draw("Arrow: "..arrowX..','..arrowY, 5, 70)
	
	love.graphics.draws( sprites, charX, charY, charSpriteX, charSpriteY, gridSize, gridSize)
	love.graphics.draws( sprites, orcX, orcY, 480, 384, gridSize, gridSize)
	
	love.graphics.draws(environment, 192, 576, 672,525,gridSize,gridSize)
	love.graphics.draws(environment, 576, 192, 480,288,gridSize,gridSize)
	
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
	
end

function update(dt)
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
	
end

function keypressed(key)
	if key == love.key_right then 
		moveRight()
	end
	if key == love.key_left then 
		moveLeft()
	end
	if key == love.key_up then 
		moveUp()
	end
	if key == love.key_down then 
		moveDown()
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

function moveLeft()
	charSpriteX = 96
	if (charX-gridSize) > (gridSize/2) then
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

function moveRight()
	charSpriteX = 0
	if (charX+gridSize) < width then
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

function moveUp()
	charSpriteX = 144
	if (charY-gridSize) > 120 then
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

function moveDown()
	charSpriteX = 48
	if (charY+gridSize) < height then
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

function showOptions()
	if optionsOpen == true then
		optionsOpen = false
	else
		optionsOpen = true
	end
	love.audio.play(uiOpenSound)
end

function generateRoom(floor)
	if floor == 1 then
		
	end
end