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

player = {x=0,y=0,spriteX=0,spriteY=(gridSize*29),vitality='alive',hp=0,str=0,def=1,level=1,status=0,facing='right',angle=0,arrowHave=2}
baddies = {}
arrows = {}

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

function spawnBaddie(type)
	i = #baddies+1
	if type == 'orc' then
		baddies[i] = {x=0,y=0,spriteX=(gridSize*10),spriteY=(gridSize*8),vitality='alive',hp=math.random(5,10),str=math.random(1,2),def=math.random(2,4),level=1,status=0,facing='right',angle=0,sizeH=1,sizeW=1}
		
		baddies[i]['totalHP'] = baddies[i]['hp']
	end
	
	goodX = false
	goodY = false
	thisX = 0
	thisY = 0

	while goodX == false do
		thisX = (gridSize * math.random(1,screenWidth))+((baddies[i]['sizeW']*gridSize)/2)
		if thisX > gridSize*2-(gridSize/2) then
			if thisX < (screenWidth*gridSize)-((baddies[i]['sizeW']*gridSize)/2) then
				if thisX ~= player['x'] then
					goodX = true
				end
			end
		end
	end

	while goodY == false do
		thisY = (gridSize * math.random(1,screenHeight))+24
		if thisY > topMenuHeight+gridSize*2-((baddies[i]['sizeH']*gridSize)/2) then
			if thisY < (screenHeight*gridSize)-((baddies[i]['sizeH']*gridSize)/2) then
				if thisY ~= player['y'] then
					goodY = true
				end
			end
		end
	end
	
	baddies[i]['x'] = thisX
	baddies[i]['y'] = thisY
	
end

function load()
	initPlayer()
	
	spawnBaddie('orc')

	loadSounds()

	headerFont = love.graphics.newFont('04B_03__.TTF', 48)
	font = love.graphics.newFont('04B_03__.TTF', 24)
	love.graphics.setFont(font)
	
	sprites = love.graphics.newImage( 'lofi_char_a_48.png' )
	environment = love.graphics.newImage( 'lofi_environment_a_48.png' )
	objects = love.graphics.newImage( 'lofi_obj_a_48.png' )
	portraits = love.graphics.newImage( 'lofi_portrait_a_48.png' )
	interface = love.graphics.newImage( 'lofi_interface_a_48.png' )

--	love.audio.play( overWorldTheme, 0 )
end

function draw()
	generateRoom(currentFloor)
	
	-- draw UI text
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw("Turns: " .. turn, 5, 32)
	love.graphics.draw("HP "..baddies[1]['hp'].."/"..baddies[1]['totalHP'],5,52)
	love.graphics.draw("Elapsed: "..elapsed, 5, 70)
	
	love.graphics.draw("HP: "..player['hp'].."/"..player['totalHP'],600,32)
	love.graphics.draw("Arrow Have: "..player['arrowHave'],600,52)
	
	for i=1, #arrows do
		if arrows[i]['isOut'] == true then
			if arrows[i]['firedFrom'] == "up" then
				love.graphics.draws(objects, arrows[i]['x'],arrows[i]['y']-40,480, 240,gridSize,gridSize)
			end
			if arrows[i]['firedFrom'] == "right" then
				love.graphics.draws(objects, arrows[i]['x']+40,arrows[i]['y'],575, 240,gridSize,gridSize)
			end
			if arrows[i]['firedFrom'] == "down" then
				love.graphics.draws(objects, arrows[i]['x'],arrows[i]['y']+40,288, 240,gridSize,gridSize)
			end
			if arrows[i]['firedFrom'] == "left" then
				love.graphics.draws(objects, arrows[i]['x']-40,arrows[i]['y'],385, 240,gridSize,gridSize)
			end
		end
	end
	
	love.graphics.draws( sprites, player['x'], player['y'], player['spriteX'], player['spriteY'], gridSize, gridSize,player['angle'])
	
	for i=1,#baddies do
		if #baddies > 0 then
			love.graphics.draws( sprites, baddies[i]['x'], baddies[i]['y'], baddies[i]['spriteX'], baddies[i]['spriteY'], gridSize*baddies[i]['sizeW'], gridSize*baddies[i]['sizeH'],baddies[i]['angle'])
		end
	end
	
	
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
	
	if loadingFloorDownWipe == true then
		if loadingFloorDownWipeAnimationH >= height then
			
		else
			loadingFloorDownWipeAnimationH = loadingFloorDownWipeAnimationH+2
		end
	end
	
	for i=1,#arrows do
		if arrows[i]['isLive'] == true then
			if arrows[i]['firedFrom'] == 'up' then
				arrows[i]['y'] = arrows[i]['y']-(dt*600)
			end
			if arrows[i]['firedFrom'] == 'right' then
				arrows[i]['x'] = arrows[i]['x']+(dt*600)
			end
			if arrows[i]['firedFrom'] == 'down' then
				arrows[i]['y'] = arrows[i]['y']+(dt*600)
			end
			if arrows[i]['firedFrom'] == 'left' then
				arrows[i]['x'] = arrows[i]['x']-(dt*600)
			end
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

	playerSwordSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/attack03.wav')
	playerShootSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/rocket01.wav')

	weaponHitSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/impact01.wav')
	weaponHitSound2 = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/impact02.wav')
	arrowMissSound = love.audio.newSound('shaktool_yowzer_thud_2.wav')

	uiOpenSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/open01.wav')
	
	mysteriousItem = love.audio.newSound('MysteriousItem1.wav')
end

function damageBaddie(damage,baddie)
	damageTaken = damage+player['str']
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

	player['facing'] = "right"
	
	player['arrowHave'] = math.random(1,5)
	
end

function charAttack()
	love.audio.play(playerSwordSound)
	if math.random(0,100) <= swordStats['tohit'] then
		damageBaddie(swordStats['dmg']*(player['str']/2))
	end
	turn = turn+1
end

function charShoot()
	if player['arrowHave'] ~= 0 then
		spawnArrow()
		player['arrowHave'] = player['arrowHave']-1
		turn = turn+1
	end
end

function spawnArrow()
	i = #arrows+1
	arrows[i] = {x=player['x'],y=player['y'],isOut=true,isLive=true,firedFrom=player['facing']}
	love.audio.play(playerShootSound)
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