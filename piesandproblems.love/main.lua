debug = true

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

levels = {}
levels[1] = {name="Kiss The Sky"}

revealedTiles = {
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},	
}

unseenTile = love.graphics.newColor( 24, 24, 24, 255 )
seenTile = love.graphics.newColor( 24, 24, 24, 100 )
currentlySeenTile = love.graphics.newColor( 24, 24, 24, 0 )

baddies = {}

downStairsLocationX = math.random(2,screenWidth-1)
downStairsLocationY = math.random(4,screenHeight-1)

turn = 0
currentFloor = 0

volume = .5

love.audio.setVolume(volume)

topMenuHeight = gridSize*2

lastkey = 0
animationsRun = 0

optionsOpen = false

function load()
	spawnPlayer()
	
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

	--love.audio.play( overWorldTheme, 0 )
end

function draw()
	generateRoom(currentFloor)
	
	-- draw UI text
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw("Orc: "..baddies[1]['x']..", "..baddies[1]['y'], 5, 24)
	love.graphics.draw("HP "..baddies[1]['hp'].."/"..baddies[1]['totalHP'],5,48)
	love.graphics.setColor(255,0,0)
	love.graphics.draw("ATK: "..baddies[1]['atk'],115,48)
	love.graphics.setColor(0,0,255)
	love.graphics.draw("DEF: "..baddies[1]['def'],205,48)
	love.graphics.setColor( 255, 255, 255 )
	
	love.graphics.draw("You: "..player['x']..", "..player['y'].." = "..map[player['y']][player['x']], 600, 24)
	love.graphics.draw("HP: "..player['hp'].."/"..player['totalHP'],600,48)
	love.graphics.setColor(255,0,0)
	love.graphics.draw("ATK: "..player['atk'],715,48)
	love.graphics.setColor(0,0,255)
	love.graphics.draw("DEF: "..player['def'],800,48)
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw("Arrow Have: "..player['arrowHave'],600,72)
	
	for i=1, #arrows do
		if arrows[i]['isOut'] == true then
			if arrows[i]['firedFrom'] == "up" then
				love.graphics.draws(objects, arrows[i]['x']*gridSize-24,arrows[i]['y']*gridSize-24,480, 240,gridSize,gridSize)
			end
			if arrows[i]['firedFrom'] == "right" then
				love.graphics.draws(objects, arrows[i]['x']*gridSize-24,arrows[i]['y']*gridSize-24,575, 240,gridSize,gridSize)
			end
			if arrows[i]['firedFrom'] == "down" then
				love.graphics.draws(objects, arrows[i]['x']*gridSize-24,arrows[i]['y']*gridSize-24,288, 240,gridSize,gridSize)
			end
			if arrows[i]['firedFrom'] == "left" then
				love.graphics.draws(objects, arrows[i]['x']*gridSize-24,arrows[i]['y']*gridSize-24,385, 240,gridSize,gridSize)
			end
		end
		love.graphics.draw(math.ceil(arrows[i]['x'])..", "..math.ceil(arrows[i]['y']),arrows[i]['x']*gridSize-24,arrows[i]['y']*gridSize-24)
	end
	
	for i=1,#baddies do
		if #baddies > 0 then
			love.graphics.draws( sprites, baddies[i]['x']*gridSize-24, baddies[i]['y']*gridSize-24, baddies[i]['spriteX'], baddies[i]['spriteY'], gridSize*baddies[i]['sizeW'], gridSize*baddies[i]['sizeH'],baddies[i]['angle'])
		end
	end
	
	love.graphics.draws( sprites, player['x']*gridSize-24, player['y']*gridSize-24, player['spriteX'], player['spriteY'], gridSize, gridSize,player['angle'])
	
--	revealTiles(currentFloor)
	bakeLights(currentFloor)

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
	
end

function bakeLights(floor)
	
end

function revealTiles(floor)
	-- Show tiles directly around the player

	for i=1, player['sight'] do
		revealedTiles[player['y']][player['x']] = 1
		revealedTiles[player['y']-i][player['x']] = 1
		revealedTiles[player['y']+i][player['x']] = 1
		revealedTiles[player['y']][player['x']-i] = 1
		revealedTiles[player['y']][player['x']+i] = 1
		revealedTiles[player['y']+i][player['x']+i] = 1
		revealedTiles[player['y']-i][player['x']-i] = 1
		revealedTiles[player['y']+i][player['x']-i] = 1
		revealedTiles[player['y']+i][player['x']+i] = 1
		revealedTiles[player['y']-i][player['x']+i] = 1
		revealedTiles[player['y']-i][player['x']-(i/2)] = 1
		revealedTiles[player['y']+i][player['x']-(i/2)] = 1
	end
	
	for y=3, screenHeight do
		for x=1, screenWidth do
			if revealedTiles[y][x] == 0 then
				love.graphics.setColor(unseenTile)
				love.graphics.rectangle( 0, (x*gridSize)-gridSize, (y*gridSize)-gridSize,gridSize, gridSize )
			end
			if revealedTiles[y][x] == 1 then
				love.graphics.setColor(currentlySeenTile)
				love.graphics.rectangle( 0, (x*gridSize)-gridSize, (y*gridSize)-gridSize,gridSize, gridSize )
			end
			if revealedTiles[y][x] == 2 then
				love.graphics.setColor(seenTile)
				love.graphics.rectangle( 0, (x*gridSize)-gridSize, (y*gridSize)-gridSize,gridSize, gridSize )
			end
		end
	end
	love.graphics.setColor(255,255, 255)

end

function moveTowardPlayer(thisX, thisY)
	
end

function update(dt)
	checkArrows(dt)
end

function checkArrows(dt)
	for i=1,#arrows do
		collision = false
		if arrows[i]['isLive'] == true then
			if arrows[i]['firedFrom'] == 'up' then
				if tileProperties[map[math.ceil(arrows[i]['y'])-1][math.ceil(arrows[i]['x'])]] == 'solid' then
					arrows[i]['isLive'] = false
					arrows[i]['y'] = math.ceil(arrows[i]['y'])
				else
					for j=1, #baddies do
						if math.ceil(arrows[i]['y'])-1 == baddies[j]['y'] then
							if arrows[i]['x'] == baddies[j]['x'] then
								arrows[i]['x'] = baddies[j]['x']
								arrows[i]['y'] = baddies[j]['y']
								if damageBaddie(j) == true then
									arrows[i]['isLive'] = false
									collision = true
								end
							end
						end
					end
				end

				if arrows[i]['isLive'] == true then
					arrows[i]['y'] = arrows[i]['y']-.1
				end
			end
			
			if arrows[i]['firedFrom'] == 'right' then
				if tileProperties[map[math.ceil(arrows[i]['y'])][math.ceil(arrows[i]['x'])+1]] == 'solid' then
					arrows[i]['isLive'] = false
					arrows[i]['x'] = math.ceil(arrows[i]['x'])
				else
					for j=1, #baddies do
						if math.ceil(arrows[i]['x'])+1 == baddies[j]['x'] then
							if arrows[i]['y'] == baddies[j]['y'] then
								arrows[i]['x'] = baddies[j]['x']
								arrows[i]['y'] = baddies[j]['y']
								if damageBaddie(j) == true then
									arrows[i]['isLive'] = false
									collision = true
								end
							end
						end
					end
				end

				if arrows[i]['isLive'] == true then
					arrows[i]['x'] = arrows[i]['x']+.1
				end
			end
			
			if arrows[i]['firedFrom'] == 'down' then
				if tileProperties[map[math.ceil(arrows[i]['y'])+1][math.ceil(arrows[i]['x'])]] == 'solid' then
					arrows[i]['isLive'] = false
					arrows[i]['y'] = math.ceil(arrows[i]['y'])
				else
					for j=1, #baddies do
						if math.ceil(arrows[i]['y']+1) == baddies[j]['y'] then
							if arrows[i]['x'] == baddies[j]['x'] then
								arrows[i]['x'] = baddies[j]['x']
								arrows[i]['y'] = baddies[j]['y']
								if damageBaddie(j) == true then
									arrows[i]['isLive'] = false
									collision = true
								end
							end
						end
					end
				end

				if arrows[i]['isLive'] == true then
					arrows[i]['y'] = arrows[i]['y']+.1
				end
			end
			
			if arrows[i]['firedFrom'] == 'left' then
				if tileProperties[map[math.ceil(arrows[i]['y'])][math.ceil(arrows[i]['x'])-1]] == 'solid' then
					arrows[i]['isLive'] = false
					arrows[i]['x'] = math.ceil(arrows[i]['x'])
				else
					for j=1, #baddies do
						if math.ceil(arrows[i]['x']-1) == baddies[j]['x'] then
							if arrows[i]['y'] == baddies[j]['y'] then
								arrows[i]['x'] = baddies[j]['x']
								arrows[i]['y'] = baddies[j]['y']
								if damageBaddie(j) == true then
									arrows[i]['isLive'] = false
									collision = true
								end
							end
						end
					end
				end

				if arrows[i]['isLive'] == true then
					arrows[i]['x'] = arrows[i]['x']-.1
				end
			end
		end
	end
end

function keypressed(key)
	if key == love.key_right then 
		movePlayer("right")
	end
	if key == love.key_left then 
		movePlayer("left")
	end
	if key == love.key_up then 
		movePlayer("up")
	end
	if key == love.key_down then 
		movePlayer("down")
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

function damageBaddie(baddie)
	attackRoll = math.random(0,player['atk'])
	defRoll = math.random(0,baddies[baddie]['def'])
	if attackRoll > defRoll then
		damageTaken = attackRoll - defRoll
		baddies[baddie]['hp'] = baddies[baddie]['hp']-damageTaken
		love.audio.play(weaponHitSound2)
		return true
	else
		playerMissed = true
		return false
	end
end

function diceRoll(n)
	total = 0
	for i=1, n do
		total = total+math.random(1,6)
	end
	
	return total
end

function levelUp(char)
	if char == 'player' then
		player['level'] = player['level']+1
		bump = math.random(player['level'],(player['level']*2))
		player['totalHP'] = player['totalHP'] + bump
		player['hp'] = player['totalHP']
	else
		baddies[char]['level'] = baddies[char]['level']+1
		bump = math.random(baddies[char]['level'],(baddies[char]['level']*2))
		baddies[char]['totalHP'] = baddies[char]['totalHP'] + bump
		baddies[char]['hp'] = baddies[char]['totalHP']
	end
end

function spawnPlayer()
	player = {x=0,y=0,spriteX=0,spriteY=(gridSize*29),vitality='alive',hp=0,atk=diceRoll(1),def=diceRoll(1),level=1,status=0,facing='right',angle=0,arrowHave=2,sight=2}
	arrows = {}
	playerMissed = false

	player['hp'] = diceRoll(2)
	player['totalHP'] = player['hp']
	
	-- Position character
	player['x'] = getGoodX(1)
	player['y'] = getGoodY(1)

	player['facing'] = "right"
	
	player['arrowHave'] = 5
end

function spawnBaddie(type)
	i = #baddies+1
	if type == 'orc' then
		baddies[i] = {x=0,y=0,spriteX=(gridSize*10),spriteY=(gridSize*8),vitality='alive',hp=diceRoll(2),atk=diceRoll(1),def=diceRoll(1),level=1,status=0,facing='right',angle=0,sizeH=1,sizeW=1,sawPlayer=false}
		
		baddies[i]['totalHP'] = baddies[i]['hp']
	end

	goodPos = false
	
	while goodPos == false do
		baddies[i]['x'] = getGoodX(baddies[i]['sizeW'])
		baddies[i]['y'] = getGoodY(baddies[i]['sizeH'])
		goodPos = checkSpaceEmpty(baddies[i]['x'],baddies[i]['y'],i)
	end
end

function charAttack()
	love.audio.play(playerSwordSound)
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

function movePlayer(direction)
	collision = false
	if direction == "left" then
		player['spriteX'] = 96
		if tileProperties[map[player['y']][(player['x'])-1]] ~= 'solid' then
			
			for i=1, #baddies do
				if player['x']-1 == baddies[1]['x'] then
					if player['y'] == baddies[1]['y'] then
						collision = true
					end
				end
			end
			
			if collision == false then
				player['x'] = player['x']-1 
			end
		end
		player['facing'] = "left"
		turn = turn+1;
	end

	if direction == "right" then
		player['spriteX'] = 0
		if tileProperties[map[player['y']][(player['x'])+1]] ~= 'solid' then
			for i=1, #baddies do
				if player['x']+1 == baddies[1]['x'] then
					if player['y'] == baddies[1]['y'] then
						collision = true
					end
				end
			end
			
			if collision == false then
				player['x'] = player['x']+1 
			end
		end
		player['facing'] = "right"
		turn = turn+1;
	end

	if direction == "up" then
		player['spriteX'] = 144
		if tileProperties[map[player['y']-1][(player['x'])]] ~= 'solid' then
			for i=1, #baddies do
				if player['x'] == baddies[1]['x'] then
					if player['y']-1 == baddies[1]['y'] then
						collision = true
					end
				end
			end
			
			if collision == false then
				player['y'] = player['y']-1 
			end
		end
		player['facing'] = "up"
		turn = turn+1;
	end

	if direction == "down" then
		player['spriteX'] = 48
		if tileProperties[map[player['y']+1][(player['x'])]] ~= 'solid' then
			for i=1, #baddies do
				if player['x'] == baddies[1]['x'] then
					if player['y']+1 == baddies[1]['y'] then
						collision = true
					end
				end
			end
			
			if collision == false then
				player['y'] = player['y']+1
			end
		end
		player['facing'] = "down"
		turn = turn+1;
	end
end

function moveBaddie(baddie)
	
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
	require('levels/'..floor..'.lua')

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

function getGoodX(spriteWidth)
	goodX = false
	while goodX == false do
		thisX = math.random(2,screenWidth-1)
		goodX = true
	end
	return thisX
end

function getGoodY(spriteHeight)
	goodY = false
	while goodY == false do
		thisY = math.random(4,screenHeight-1)
		goodY = true
	end
	return thisY
end

function checkSpaceEmpty(x,y,id)
	occupied = 0
	for i=1, #baddies do
		if i ~= id then
			if baddies[i]['x'] == x then
				if baddies[i]['y'] == y then
					occupied = occupied+1
				end
			end
		end
	end
	if occupied > 0 then
		return false
	else
		return true
	end
end