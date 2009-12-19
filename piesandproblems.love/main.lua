love.filesystem.require("ai.lua")
timePassed = 0
playerMoved = 0

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
messages = {}

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

turn = 0
currentFloor = 0

volume = .5

love.audio.setVolume(volume)

topMenuHeight = gridSize*2

lastkey = 0
animationsRun = 0

optionsOpen = false

baddiesAlive = 0
baddiesKilled = 0

doorOpened = false
mapGenerated = false

-- A* algotithm
moves = {}
moves.path = {{2,11},{3,10},{5,10},{6,11},{6,13},{5,14},{3,14},{2,13}}
moves.xsize=table.getn(moves.path[1]) -- horizontal map size
moves.ysize=table.getn(moves.path)	   -- vertical map size

testo =  "status"

function load()
	spawnPlayer()
	loadSounds()

	headerFont = love.graphics.newFont('04B_03__.TTF', 48)
	font = love.graphics.newFont('04B_03__.TTF', 24)
	love.graphics.setFont(font)
	
	loadGraphics()

	--love.audio.play( overWorldTheme, 0 )
end

function loadGraphics()
	spriteRowOffsets = {sprites=0,environment=31,interface=47,objects=63,portraits=79}

	sprites = love.graphics.newImage( 'lofi_char_a_48.png' )
	environment = love.graphics.newImage( 'lofi_environment_a_48.png' )
	interface = love.graphics.newImage( 'lofi_interface_a_48.png' )
	objects = love.graphics.newImage( 'lofi_obj_a_48.png' )
	portraits = love.graphics.newImage( 'lofi_portrait_a_48.png' )
end

function draw()
	generateRoom(currentFloor)
	
	if #baddies < numberOfBaddies then
		spawnBaddie('orc')
	end
	
	-- draw UI text
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw("Orc: "..baddies[1]['x']..", "..baddies[1]['y'].." ("..getSpaceFromXY(baddies[1]['x'],baddies[1]['y'])..")", 5, 24)
	love.graphics.draw("HP "..baddies[1]['hp'].."/"..baddies[1]['totalHP'],5,48)
	love.graphics.setColor(255,0,0)
	love.graphics.draw("ATK: "..baddies[1]['atk'],115,48)
	love.graphics.setColor(0,0,255)
	love.graphics.draw("DEF: "..baddies[1]['def'],205,48)
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw(love.timer.getTime(),5,68)
	love.graphics.draw(baddies[1]['lastMove'],5,88)
	
	playerSpace = getSpaceFromXY(player['x'],player['y'])
	playerXY = getXYFromSpace(playerSpace)
	
	love.graphics.draw("You: "..player['x']..", "..player['y'].." ("..playerSpace..") "..tileProperties[map[player['y']][player['x']]], 600, 24)
	love.graphics.draw("HP: "..player['hp'].."/"..player['totalHP'],600,48)
	love.graphics.setColor(255,0,0)
	love.graphics.draw("ATK: "..player['atk'],715,48)
	love.graphics.setColor(0,0,255)
	love.graphics.draw("DEF: "..player['def'],800,48)
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw("Arrow Have: "..player['arrowHave'],600,72)
	
	-- animate arrows
	animateArrows()
	
	for i=1,#baddies do
		if #baddies > 0 then
			if baddies[i]['vitality'] == 'dead' then
				baddies[i]['angle'] = -90
			end
			if baddies[i]['deathAnimation'] == 3 then
				baddies[i]['angle'] = 0
				love.graphics.draws( sprites, baddies[i]['x']*gridSize-24, baddies[i]['y']*gridSize-24, baddies[i]['deathSpriteX'], baddies[i]['deathSpriteY'], gridSize*baddies[i]['sizeW'], gridSize*baddies[i]['sizeH'],baddies[i]['angle'],baddies[i]['scale'])
			else
				love.graphics.draws( sprites, baddies[i]['x']*gridSize-24, baddies[i]['y']*gridSize-24, baddies[i]['spriteX'], baddies[i]['spriteY'], gridSize*baddies[i]['sizeW'], gridSize*baddies[i]['sizeH'],baddies[i]['angle'],baddies[i]['scale'])
			end
		end
	end
	
	love.graphics.draws( sprites, player['x']*gridSize-24, player['y']*gridSize-24, player['spriteX'], player['spriteY'], gridSize, gridSize,player['angle'])
	
--	revealTiles(currentFloor)
	bakeLights(currentFloor)
	
	if #messages > 0 then
		for i=1, #messages do
			if messages[i]['alpha'] > 0 then
				love.graphics.setColor( 0, 0, 0, messages[i]['alpha'] )
				if messages[i]['type'] == 'get' then
					love.graphics.draw(messages[i]['message'],(messages[i]['x']*gridSize)-(gridSize*2)+2,(messages[i]['y']*gridSize)+2)
					love.graphics.setColor( 255, 255, 255, messages[i]['alpha'] )
					love.graphics.draw(messages[i]['message'],(messages[i]['x']*gridSize)-(gridSize*2),(messages[i]['y']*gridSize))
				end
				if messages[i]['type'] == 'damage' then
					love.graphics.draw(messages[i]['message'],(messages[i]['x']*gridSize)-(gridSize)+2,(messages[i]['y']*gridSize)+2)
					love.graphics.setColor( 255, 0, 0, messages[i]['alpha'] )
					love.graphics.draw(messages[i]['message'],(messages[i]['x']*gridSize)-(gridSize),(messages[i]['y']*gridSize))
				end
				
			end
		end
	end
	love.graphics.setColor(255,255,255)
	love.graphics.draw(love.timer.getFPS(),900,700)
	
	if optionsOpen == true then
		love.graphics.setColor( 0, 0, 0, 125 )
		love.graphics.rectangle( 0, 0, 0, width, height )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.rectangle( 1, ((width/2)-((width/2)/2)), ((height/2)-((height/2)/2)), (width/2), (height/2) )
		love.graphics.setColor( 0, 0, 0 )
		love.graphics.rectangle( 0, ((width/2)-((width/2)/2))+1, ((height/2)-((height/2)/2))+1, (width/2)-2, (height/2)-2 )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.setFont(headerFont)
		love.graphics.draw("Options", ((width/2)-((width/2)/2))+16, ((height/2)-((height/2)/2))+48)
		love.graphics.setFont(font)
		volumeShow = volume*100
		if volumeShow > 100 then
			volumeShow = 0
		end
		if volumeShow < 10 then
			volumeShow = 0
		end
		love.graphics.draw("Volume: " .. (volumeShow) .."%", ((width/2)-((width/2)/2))+16, ((height/2)-((height/2)/2))+96)
	end

	for k in pairs(baddies) do
		if baddies[k]['vitality'] == 'alive' then
			if baddies[k]['lastMove'] <= (love.timer.getTime()-.7) then
				baddies[k]['lastMove'] = love.timer.getTime()
				moveBaddie(k)
			end
		end
	end	

	testo =  "Path: "
	if moves.path == nil then
		testo = "NO PATH"
	else
		local color1 = love.graphics.getColor()
		--love.graphics.setColor( 100, 205, 0 ) 
		for i,v in ipairs(moves.path ) do
			testo = testo .. " ( "  .. tostring(v.x) .. " , " .. tostring(v.y) .. " ) "
		end
		love.graphics.setColor( color1) 
	end
	love.graphics.draw(testo  ,10,110)

end

function update(dt)
	timePassed = timePassed+dt
	checkArrows(dt)
	for i=1,#baddies do
		if baddies[i]['vitality'] == 'dead' then
			if baddies[i]['deathAnimation'] == 2 then
				baddies[i]['scale'] = baddies[i]['scale']-.1
				if baddies[i]['scale'] <= 1 then
					baddies[i]['scale'] = 1
					baddies[i]['deathAnimation'] = 3
					love.audio.play(deathRattle)
				end
			end
			if baddies[i]['deathAnimation'] == 0 then
				baddies[i]['scale'] = baddies[i]['scale']+.1
				if baddies[i]['scale'] >= 2 then
					baddies[i]['deathAnimation'] = 2
				end
			end
		end
	end
	if love.joystick.getNumJoysticks( ) > 0 then
		checkJoystick()
	end
	
	if #messages > 0 then
		for i=1, #messages do
			if messages[i]['started'] == 0 then
				messages[i]['started'] = timePassed
			end
			messages[i]['alpha'] = messages[i]['alpha'] - 1
			messages[i]['y'] = messages[i]['y']-.01
		end
	end
	
	if baddiesKilled > 0 then
		if doorOpened == false then
			if baddiesAlive == 0 then
				doorOpen = love.audio.newSound('shaktool_yowzer_event_1.wav')
				openDoor()
				love.audio.play(doorOpen)
			end
		end
	end
	
end

function openDoor()
	doorOpened = true
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

function checkJoystick()
	if timePassed-playerMoved >= .2 then
		if love.joystick.isDown( 0, 1 ) then
			playerShoot()
			playerMoved = timePassed
		end
	end

	if timePassed-playerMoved >= .1 then
		shot = 0
		joyPos1 = love.joystick.getAxis( 0, 0 )
		joyPos2 = love.joystick.getAxis( 0, 1 )
		if joyPos1 == 1 then
			movePlayer('right')
			playerMoved = timePassed
		end
		if joyPos1 == -1 then
			movePlayer('left')
			playerMoved = timePassed
		end
		if joyPos2 == -1 then
			movePlayer('up')
			playerMoved = timePassed
		end
		if joyPos2 == 1 then
			movePlayer('down')
			playerMoved = timePassed
		end
	end
end

function checkArrows(dt)
	player['liveArrows'] = 0
	for i=1, #arrows do
		if arrows[i]['isLive'] == true then
			player['liveArrows'] = player['liveArrows']+1
		end
		if player['liveArrows'] == 2 then
			player['canShoot'] = false
		else
			player['canShoot'] = true
		end
	end
	for i=1,#arrows do
		collision = false
		if arrows[i]['isLive'] == true then
			if arrows[i]['firedFrom'] == 'up' then
				for j=1, #baddies do
					if baddies[j]['vitality'] == 'alive' then
						if math.ceil(arrows[i]['y'])-1 == baddies[j]['y'] then
							if arrows[i]['x'] == baddies[j]['x'] then
								arrows[i]['x'] = baddies[j]['x']
								arrows[i]['y'] = baddies[j]['y']
								if damageBaddie(j,'arrow') == true then
									arrows[i]['isLive'] = false
									collision = true
								else
									messages[#messages+1] = {x=baddies[j]['x'],y=baddies[j]['y'],message="Miss!",alpha=255,started=0,type='get'}
								end
							end
						end
					end
				end
				if tileProperties[map[math.ceil(arrows[i]['y'])-1][math.ceil(arrows[i]['x'])]] == 'solid' then
					arrows[i]['isLive'] = false
					arrows[i]['y'] = math.ceil(arrows[i]['y'])
				end

				if arrows[i]['isLive'] == true then
					arrows[i]['y'] = arrows[i]['y']-.1
				end
			end
			
			if arrows[i]['firedFrom'] == 'right' then
				for j=1, #baddies do
					if baddies[j]['vitality'] == 'alive' then
						if math.ceil(arrows[i]['x'])+1 == baddies[j]['x'] then
							if arrows[i]['y'] == baddies[j]['y'] then
								arrows[i]['x'] = baddies[j]['x']
								arrows[i]['y'] = baddies[j]['y']
								if damageBaddie(j,'arrow') == true then
									arrows[i]['isLive'] = false
									collision = true
								else
									messages[#messages+1] = {x=baddies[j]['x'],y=baddies[j]['y'],message="Miss!",alpha=255,started=0,type='get'}
								end
							end
						end
					end
				end
				if tileProperties[map[math.ceil(arrows[i]['y'])][math.ceil(arrows[i]['x'])+1]] == 'solid' then
					arrows[i]['isLive'] = false
					arrows[i]['x'] = math.ceil(arrows[i]['x'])
				end

				if arrows[i]['isLive'] == true then
					arrows[i]['x'] = arrows[i]['x']+.1
				end
			end
			
			if arrows[i]['firedFrom'] == 'down' then
				for j=1, #baddies do
					if baddies[j]['vitality'] == 'alive' then
						if math.ceil(arrows[i]['y']+1) == baddies[j]['y'] then
							if arrows[i]['x'] == baddies[j]['x'] then
								arrows[i]['y'] = baddies[j]['y']
								if damageBaddie(j,'arrow') == true then
									arrows[i]['isLive'] = false
									collision = true
								else
									messages[#messages+1] = {x=baddies[j]['x'],y=baddies[j]['y'],message="Miss!",alpha=255,started=0,type='get'}
								end
							end
						end
					end
				end
				if tileProperties[map[math.ceil(arrows[i]['y'])+1][math.ceil(arrows[i]['x'])]] == 'solid' then
					arrows[i]['isLive'] = false
					arrows[i]['y'] = math.ceil(arrows[i]['y'])	
				end

				if arrows[i]['isLive'] == true then
					arrows[i]['y'] = arrows[i]['y']+.1
				end
			end
			
			if arrows[i]['firedFrom'] == 'left' then
				for j=1, #baddies do
					if baddies[j]['vitality'] == 'alive' then
						if math.ceil(arrows[i]['x']-1) == baddies[j]['x'] then
							if arrows[i]['y'] == baddies[j]['y'] then
								arrows[i]['x'] = baddies[j]['x']
								arrows[i]['y'] = baddies[j]['y']
								if damageBaddie(j,'arrow') == true then
									arrows[i]['isLive'] = false
									collision = true
								else
									messages[#messages+1] = {x=baddies[j]['x'],y=baddies[j]['y'],message="Miss!",alpha=255,started=0,type='get'}
								end
							end
						end
					end
				end
				if tileProperties[map[math.ceil(arrows[i]['y'])][math.ceil(arrows[i]['x'])-1]] == 'solid' then
					arrows[i]['isLive'] = false
					arrows[i]['x'] = math.ceil(arrows[i]['x'])				
				end

				if arrows[i]['isLive'] == true then
					arrows[i]['x'] = arrows[i]['x']-.1
				end
			end
		end
	end
end

function loadSounds()
	overWorldTheme = love.audio.newSound('Mr Fluff.ogg')

	playerSwordSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/attack03.wav')
	playerShootSound = love.audio.newSound('shaktool_yowzer_laser_2.wav')

	weaponHitSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/impact01.wav')
--	weaponHitSound2 = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/impact02.wav')
	ouch1 = love.audio.newSound('shaktool_yowzer_ouch_2.wav')
	arrowMissSound = love.audio.newSound('shaktool_yowzer_thud_2.wav')
	deathRattle = love.audio.newSound('shaktool_yowzer_blubber_1.wav')
	arrowPickup = love.audio.newSound('SFRX/spawn1.wav')

	uiOpenSound = love.audio.newSound('Stian_Stark_SFX_Pack_Vol_1/open01.wav')
	
	mysteriousItem = love.audio.newSound('MysteriousItem1.wav')
end

function damageBaddie(baddie,kind)
	attackRoll = math.random(1,player['atk'])+1
	defRoll = math.random(1,baddies[baddie]['def'])
	if attackRoll > defRoll then
		damageTaken = diceRoll(1,1)
		baddies[baddie]['hp'] = baddies[baddie]['hp']-damageTaken
		messages[#messages+1] = {x=baddies[baddie]['x'],y=baddies[baddie]['y'],message="-"..damageTaken,alpha=255,started=0,type='damage'}
		if kind == 'arrow' then
			love.audio.play(ouch1)
		end
		if kind == 'sword' then
			love.audio.play(weaponHitSound)
		end
		if baddies[baddie]['hp'] <= 0 then
			killBaddie(baddie)
		end
		return true
	else
		playerMissed = true
		return false
	end
end

function killBaddie(baddie)
	baddies[baddie]['hp'] = 0
	baddies[baddie]['vitality'] = 'dead'
	baddiesAlive = baddiesAlive-1
	baddiesKilled = baddiesKilled+1
end

function diceRoll(n,minimum)
	total = 0
	for i=1, n do
		roll = math.random(1,6)
		total = total+roll
	end
	if total < minimum then
		total = minimum
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
	player = {x=0,y=0,spriteX=0,spriteY=(gridSize*29),vitality='alive',hp=0,atk=diceRoll(1,3),def=diceRoll(1,3),level=1,status=0,facing='right',angle=0,arrowHave=2,sight=2,canShoot=true,liveArrows=0}
	arrows = {}
	playerMissed = false

	player['hp'] = diceRoll(2,3)
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
		baddies[i] = {x=0,y=0,spriteX=(gridSize*10),spriteY=(gridSize*8),vitality='alive',hp=diceRoll(2,3),atk=diceRoll(1,3),def=diceRoll(1,3),level=1,status=0,facing='right',angle=0,sizeH=1,sizeW=1,lastSawPlayer='none',scale=1,deathAnimation=0,deathSpriteX=(15*gridSize),deathSpriteY=(9*gridSize),canSeePlayer=false,lastMove=0}
		
		baddies[i]['totalHP'] = baddies[i]['hp']
		baddiesAlive = baddiesAlive+1
	end

	goodPos = false
	
	while goodPos == false do
		baddies[i]['x'] = getGoodX(baddies[i]['sizeW'])
		baddies[i]['y'] = getGoodY(baddies[i]['sizeH'])
		goodPos = checkXYEmpty(baddies[i]['x'],baddies[i]['y'],i)
	end
end

function playerShoot()
	if player['arrowHave'] ~= 0 then
		if player['canShoot'] == true then
			spawnArrow()
			player['arrowHave'] = player['arrowHave']-1
			turn = turn+1
		end
	else
		messages[#messages+1] = {x=player['x'],y=player['y'],message="No Arrow Have!",alpha=255,started=0,type='get'}
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
				if baddies[i]['vitality'] == 'alive' then
					if player['x']-1 == baddies[i]['x'] then
						if player['y'] == baddies[i]['y'] then
							if damageBaddie(i,'sword') == true then
								collision = true
							else
								collision = true
								messages[#messages+1] = {x=baddies[i]['x'],y=baddies[i]['y'],message="Miss!",alpha=255,started=0,type='get'}
							end
						end
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
				if baddies[i]['vitality'] == 'alive' then
					if player['x']+1 == baddies[i]['x'] then
						if player['y'] == baddies[i]['y'] then
							if damageBaddie(i,'sword') == true then
								collision = true
							else
								collision = true
								messages[#messages+1] = {x=baddies[i]['x'],y=baddies[i]['y'],message="Miss!",alpha=255,started=0,type='get'}
							end
						end
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
				if baddies[i]['vitality'] == 'alive' then
					if player['x'] == baddies[i]['x'] then
						if player['y']-1 == baddies[i]['y'] then
							if damageBaddie(i,'sword') == true then
								collision = true
							else
								collision = true
								messages[#messages+1] = {x=baddies[i]['x'],y=baddies[i]['y'],message="Miss!",alpha=255,started=0,type='get'}
							end
						end
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
				if baddies[i]['vitality'] == 'alive' then
					if player['x'] == baddies[i]['x'] then
						if player['y']+1 == baddies[i]['y'] then
							if damageBaddie(i,'sword') == true then
								collision = true
							else
								collision = true
								messages[#messages+1] = {x=baddies[i]['x'],y=baddies[i]['y'],message="Miss!",alpha=255,started=0,type='get'}
							end
						end
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
	checkForPickups()
end

function animateArrows()
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
			if debug == true then
				love.graphics.draw(math.ceil(arrows[i]['x'])..", "..math.ceil(arrows[i]['y']),arrows[i]['x']*gridSize-24,arrows[i]['y']*gridSize-24)
			end
		end
	end
end

function checkForPickups()
	arrowsGot = 0
	for i=1, #arrows do
		if arrows[i]['x'] == player['x'] then
			if arrows[i]['y'] == player['y'] then
				if arrows[i]['isOut'] == true then
					arrowGet(i)
					arrowsGot = arrowsGot+1
				end
			end
		end
	end
	if arrowsGot == 1 then
		messages[#messages+1] = {x=player['x'],y=player['y'],message="Arrow Get!!",alpha=255,started=0,type='get'}
	end
	if arrowsGot > 1 then
		messages[#messages+1] = {x=player['x'],y=player['y'],message="Arrow Get!! x"..arrowsGot,alpha=255,started=0,type='get'}
	end
end

function arrowGet(id)
	arrows[id]['isOut'] = false
	player['arrowHave'] = player['arrowHave']+1
	love.audio.play(arrowPickup)
end

function moveBaddie(baddie)
	moves.path = CalcPath(CalcMoves(mappy.array,baddies[baddie]['x'],baddies[baddie]['y'],player['x'],player['y']))
	if moves.path[1]['x'] == player['x'] then
		if moves.path[1]['y'] == player['y'] then
			attackPlayer(baddie)
		end
	end
	for k in pairs(baddies) do
		if moves.path[1]['x'] == baddies[k]['x'] then
			if moves.path[1]['y'] == baddies[k]['y'] then
				return nil
			end
		end
	end
	baddies[baddie]['x'] = moves.path[1]['x']
	baddies[baddie]['y'] = moves.path[1]['y']
end

function attackPlayer()
	attackRoll = math.random(1,baddie['atk'])+1
	defRoll = math.random(1,player['def'])
	if attackRoll > defRoll then
		damageTaken = diceRoll(1,1)
		player['hp'] = player['hp']-damageTaken
		messages[#messages+1] = {x=player['x'],y=player['y'],message="-"..damageTaken,alpha=255,started=0,type='damage'}
		if kind == 'arrow' then
			love.audio.play(ouch1)
		end
		if kind == 'sword' then
			love.audio.play(weaponHitSound)
		end
		if player['hp'] <= 0 then
			killPlayer()
		end
		return true
	else
		baddieMissed = true
		return false
	end
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
	
	for y=3, screenHeight do
		for x=1, screenWidth do
			if map[y][x] == 9 then
				map[y][x] = tileTypes[9][1]
				downStairsX = x
				downStairsY = y
			end
			if map[y][x] == 8 then
				
			end
			if map[y][x] == 7 then
			
			end
			if map[y][x] == 6 then
			
			end
			if map[y][x] == 5 then
			
			end
			if map[y][x] == 4 then
			
			end
			if map[y][x] == 3 then
				--map[y][x] = tileTypes[3][math.random(1,#tileTypes[3])]
				map[y][x] = 512
			end
			if map[y][x] == 2 then
				map[y][x] = 496
			end
			if map[y][x] == 1 then
			
			end
			if map[y][x] == 0 then
				map[y][x] = tileTypes[0][math.random(1,#tileTypes[0])]
			end
		end
	end
	
	if doorOpened == true then
		map[downStairsY][downStairsX] = tileTypes[9][2]
	else
		map[downStairsY][downStairsX] = tileTypes[9][1]
	end
	
	-- draw main background
	love.graphics.setColor( 242, 220, 144 )
	love.graphics.rectangle( 0, 0, topMenuHeight, width, height )
	
	-- draw secondary background
	love.graphics.setColor( 56, 50, 34 )
	love.graphics.rectangle(0,48,topMenuHeight+48,width-96, (height-96)-(topMenuHeight))

	for y=3, screenHeight do
		for x=1, screenWidth do
			envSpriteY = math.floor((map[y][x]-(spriteRowOffsets['environment']*16))/16)
			envSpriteX = math.floor((map[y][x]-(spriteRowOffsets['environment']*16)))-(envSpriteY*16)

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

function checkXYEmpty(x,y,id)
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
	if tileProperties[map[y][x]] == 'solid' then
		occupied = occupied + 1
	end
	if occupied > 0 then
		return false
	else
		return true
	end
end

function checkSpaceEmpty(space)
	occupied = 0
	for i=1, #baddies do
		if getSpaceFromXY(baddies[i]['x'],baddies[i]['y']) == space then
			occupied = 1
		end
	end
	if getSpaceFromXY(player['x'],player['y']) == space then
		occupied = 1
	end
	spaceXY = getXYFromSpace(space)
	if tileProperties[map[spaceXY['y']][spaceXY['x']]] == 'solid' then
		occupied = 1
	end
	if occupied == 1 then
		return false
	else
		return true
	end
end

function getSpaceFromXY(x,y)
	return (y-1)*(screenWidth)+x
end

function getXYFromSpace(space)
	thisXY = {}
	thisXY['y'] = math.ceil(space/screenWidth)
	thisXY['x'] = space-((thisXY['y']-1)*screenWidth)
	return thisXY
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
		playerShoot()
	end
	if key == love.key_r then
		love.system.restart( )
	end
	if key == love.key_o then
		showOptions()
	end
	if key == love.key_q then
		if love.keyboard.isDown(310) then 
			love.system.exit()
		end
	end
	if key == love.key_d then
		if debug == true then
			debug = false
		else
			debug = true
		end
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
		if volume == .1 then
			volume = 0
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

function round(num, idp)
  local mult = 10^0
  return math.floor(num * mult + 0.5) / mult
end