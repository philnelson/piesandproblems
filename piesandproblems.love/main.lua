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

player = {x=0,y=0,spriteX=0,spriteY=(gridSize*29),vitality='alive',hp=0,str=0,def=1,level=1,status=0,facing='right',angle=0}

orcStats = {vitality='alive',hp=math.random(5,10),str=math.random(1,2),def=2,level=1,status='fine'}
orcStats['totalHP'] = orcStats['hp']
orcAngle = 0

swordStats = {tohit=80, dmg=2}
arrowStats = {tohit=70, dmg=1,isOut=false,isUp=false}

downStairsLocationX = math.random(2,screenWidth-1)
downStairsLocationY = math.random(4,screenHeight-1)

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
attackMissed = false

function load()
	initPlayer()
	positionBaddie()
	
	arrowStats['isUp'] = false

	loadSounds()

	headerFont = love.graphics.newFont('04B_03__.TTF', 48)
	font = love.graphics.newFont('04B_03__.TTF', 24)
	love.graphics.setFont(font)
	
	sprites = love.graphics.newImage( 'lofi_char_a_48.png' )
	environment = love.graphics.newImage( 'lofi_environment_a_48.png' )
	objects = love.graphics.newImage( 'lofi_obj_a_48.png' )

--	love.audio.play( overWorldTheme, 0 )
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
	love.graphics.draw("Orc HP: "..orcStats['hp'].."/"..orcStats['totalHP'], 5, 50)
	love.graphics.draw("Elapsed: "..elapsed, 5, 70)
	
	if arrowStats['isOut'] == true then
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
	
	love.graphics.draws( sprites, player['x'], player['y'], player['spriteX'], player['spriteY'], gridSize, gridSize,player['angle'])
	love.graphics.draws( sprites, orcX, orcY, 480, 384, gridSize, gridSize,orcAngle)
	
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
	
	if orcIsHit == true then
		--love.graphics.draws(objects, orcX, orcY, 192,240,gridSize,gridSize)
	end
	
	if attackMissed == true then
		if elapsed < attackMissedTime+2 then
			love.graphics.setColor( 0, 0, 0 )
			love.graphics.draw('miss',player['x']+3, player['y']+3)
			love.graphics.setColor( 255, 255, 255 )
			love.graphics.draw('miss',player['x'], player['y'])
		else
			attackMissed = false
		end
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
	
	if orcStats['hp'] == 0 then
		if orcAngle > -90 then
			orcAngle = orcAngle-10
		end
	end

	if arrowStats['isUp'] == true then
		if arrowFiredFrom == "up" then
			arrowY = arrowY-(dt*600)
			if arrowY-48 <= orcY then
				if arrowX == orcX then
					orcHitByArrow()
				end
			end
		end
		if arrowFiredFrom == "right" then
			arrowX = arrowX+(dt*600)
			if arrowX+48 >= orcX then
				if arrowY == orcY then
					orcHitByArrow()
				end
			end
			if arrowX+108 >= width then
				arrowStats['isUp'] = false
			end
		end
		if arrowFiredFrom == "down" then
			arrowY = arrowY+(dt*600)
			if arrowY+48 >= orcY then
				if arrowX == orcX then
					orcHitByArrow()
				end
			end
		end
		if arrowFiredFrom == "left" then
			arrowX = arrowX-(dt*600)
			if arrowX-48 <= orcX then
				if arrowY == orcY then
					orcHitByArrow()
				end
			end
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

function damageBaddie(damage)
	damageTaken = damage+player['str']
	orcStats['hp'] = orcStats['hp']-damageTaken
end

function initPlayer()
	player['spriteX'] = 0
	player['spriteY'] = gridSize*29
	
	player['hp'] = math.random(5,10)
	player['totalHP'] = player['hp']
	player['str'] = math.random(1,2)
	player['def'] = math.random(1,2)
	
	-- Position character

	goodX = false
	goodY = false

	while goodX == false do
		player['x'] = (gridSize * math.random(1,screenWidth))+24
		if player['x'] > gridSize*2-(gridSize/2) then
			if player['x'] < (screenWidth*gridSize)-(gridSize/2) then
				goodX = true
			end
		end
	end

	while goodY == false do
		player['y'] = (gridSize * math.random(1,screenHeight))+24
		if player['y'] > topMenuHeight+gridSize*2-(gridSize/2) then
			if player['y'] < (screenHeight*gridSize)-(gridSize/2) then
				goodY = true
			end
		end
	end
	
	arrowX = player['x']
	arrowY = player['y']

	player['facing'] = "right"
	arrowFiredFrom = player['facing']
	
end

function charAttack()
	love.audio.play(charSwordSound)
	if math.random(0,100) <= swordStats['tohit'] then
		orcIsHit = true
		damageBaddie(swordStats['dmg']*(player['str']/2))
	else
		attackMissedTime = elapsed
		attackMissed = true
	end
	turn = turn+1
end

function charShoot()
	if arrowStats['isOut'] == false then
		arrowX = player['x'];
		arrowY = player['y'];
		arrowFiredFrom = player['facing']
		arrowStats['isUp'] = true
		love.audio.play(charShootSound)
		turn = turn+1
		arrowStats['isOut'] = true
	end
end

function orcHitByArrow()
	orcIsHit = true
	arrowStats['isUp'] = false
	if math.random(0,100) <= arrowStats['tohit'] then
		damageBaddie(arrowStats['dmg'])
		love.audio.play(weaponHitSound)
	end
end

function moveCharacter(direction)
	if direction == "left" then
		player['spriteX'] = 96
		if (player['x']-gridSize) >= (gridSize) then
			if player['x']-gridSize == orcX then
				if player['y'] == orcY then
					charAttack()
				else
					player['x'] = player['x']-gridSize
				end
			else
				player['x'] = player['x']-gridSize
			end
		end
		player['facing'] = "left"
		turn = turn+1;
	end

	if direction == "right" then
		player['spriteX'] = 0
		if (player['x']+gridSize) <= (width)-gridSize then
			if player['x']+gridSize == orcX then
				if player['y'] == orcY then
					charAttack()
				else
					player['x'] = player['x']+gridSize
				end
			else
				player['x'] = player['x']+gridSize
			end
		end
		player['facing'] = "right"
		turn = turn+1;
	end

	if direction == "up" then
		player['spriteX'] = 144
		if (player['y']-gridSize) > (gridSize*2)+(gridSize/2) then
			if player['y']-gridSize == orcY then
				if player['x'] == orcX then
					charAttack()
				else
					player['y'] = player['y']-gridSize
				end
			else
				player['y'] = player['y']-gridSize
			end
		end
		player['facing'] = "up"
		turn = turn+1;
	end

	if direction == "down" then
		player['spriteX'] = 48
		if (player['y']+gridSize) < (height-gridSize) then
			if player['y']+gridSize == orcY then
				if player['x'] == orcX then
					charAttack()
				else
					player['y'] = player['y']+gridSize
				end
			else
				player['y'] = player['y']+gridSize
			end
		end
		player['facing'] = "down"
		turn = turn+1;
	end
	
	if map[math.ceil(player['y']/48)][math.ceil(player['x']/48)] == 24 then
		loadFloor(currentFloor-1)
	end
	
	if arrowStats['isOut'] == true then
		if arrowX == player['x'] then
			if arrowY == player['y'] then
				arrowStats['isOut'] = false
			end
		end
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