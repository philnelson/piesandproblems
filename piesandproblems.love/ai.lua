-- EVILMANA.COM PSP LUA CODEBASE
-- www.evilmana.com/tutorials/codebase
-- A* pathfinding algorithm
-- SUBMITTED BY: Altair

--[[
A* algorithm for LUA v1.1
Ported to LUA by Altair
14 october 2006
Now with binary Heap and also the possibility of diagonal moves
--]]

--[[
USAGE:

function CalcMoves(calcMapmat, px, py, tx, ty)
PRE:
calcMapmat is a 2d array
px is the player's current x
py is the player's current y
tx is the target x
ty is the target y

Note: all the x and y are the x and y to be used in the table.
By this I mean, if the table is 3 by 2, the x can be 1,2,3 and the y can be 1 or 2.

POST:
closedlist is a list with the checked nodes.
It will return nil if all the available nodes have been checked but the target hasn't been found.

and

function CalcPath(closedlist)
PRE:
closedlist is a list with the checked nodes.
OR nil if all the available nodes have been checked but the target hasn't been found.

POST:
path is a list with all the x and y coords of the nodes of the path to the target.
OR nil if closedlist==nil

]]--
openlist = {}

function CalcMoves(calcMap, px, py, tx, ty) -- Based on code of LMelior but made 	something really different, still thx LMelior!

	if tileProperties[map[ty][tx]] == 'solid' then -- If the target node isn't walkable then return nil
		return nil
	end

	-- variables 
	local openlist = {} -- Initialize table to store possible moves
	local closedlist = {} -- Initialize table to store checked nodes
	local listk = 1 -- List counter
	local closedk = 0 -- Closedlist counter
	local tempH = math.abs(px - tx) + math.abs(py - ty)
	local tempG = 0
	openlist[1] = {x = px, y = py, g = 0, h = tempH, f = 0 + tempH ,par = 1} -- Make starting point in list
	local xsize = table.getn(calcMap[1]) -- horizontal calcMap size
	local ysize = table.getn(calcMap) -- vertical calcMap size
	local curbase = {} -- Current square from which to check possible moves
	
	-- Growing loop
	while listk > 0 do
		-- Get the lowest f of the openlist and store in closedlist
		closedk = closedk + 1
		table.insert(closedlist, closedk, openlist[1])
		curbase = closedlist[closedk] -- define current base from which to grow list
		-- If the last entry of the closedlist mathches the target -> exit function
		if closedlist[closedk].x == tx and closedlist[closedk].y == ty then
			return closedlist
		end

		-- Removing base from openlist and reorder
		openlist[1] = openlist[listk]
		table.remove(openlist, listk)
		listk = listk - 1
		local v = 1
		while true do
			local u = v
			if 2 * u + 1 <= listk then
				if openlist[u].f >= openlist[2 * u].f then
					v = 2 * u
				end
				if openlist[v].f >= openlist[2 * u + 1].f then
					v = 2 * u + 1
				end
			elseif 2 * u <= listk then
				if openlist[u].f >= openlist[2 * u].f then
					v = 2 * u
				end
			end
			if u ~= v then
				local temp = openlist[u]
				openlist[u] = openlist[v]
				openlist[v] = temp
			else
				break
			end
		end

		local rightOK = true
		local leftOK = true -- Booleans defining if they're OK to add
		local downOK = true -- (must be reset for each while loop)
		local upOK = true

		local upLeftOK = true
		local upRightOK = true
		local downLeftOK = true
		local downRightOK = true
		-- Look through closedlist
		if closedk > 0 then
			for k = 1, closedk do
				if closedlist[k].x == curbase.x + 1 and closedlist[k].y == curbase.y then
					rightOK = false
				end
				if closedlist[k].x == curbase.x - 1 and closedlist[k].y == curbase.y then
					leftOK = false
				end
				if closedlist[k].x == curbase.x and closedlist[k].y == curbase.y + 1 then
					downOK = false
				end
				if closedlist[k].x == curbase.x and closedlist[k].y == curbase.y - 1 then
					upOK = false
				end
				-- Diagonals
				if closedlist[k].x == curbase.x - 1 and closedlist[k].y == curbase.y - 1 then
					upLeftOK = false
				end
				if closedlist[k].x == curbase.x + 1 and closedlist[k].y == curbase.y - 1 then
					upRightOK = false
				end
				if closedlist[k].x == curbase.x - 1 and closedlist[k].y + 1 == curbase.y + 1 then
					downLeftOK = false
				end
				if closedlist[k].x == curbase.x + 1 and closedlist[k].y + 1 == curbase.y - 1 then
					downRightOK = false
				end
			end
		end

		-- Check if next points are on the calcMap and within moving distance
		if curbase.x + 1 > xsize then
			rightOK = false
			upRightOK = false
			downRightOK = false
		end
		if curbase.x - 1 < 1 then
			leftOK = false
			upLeftOK = false
			downLeftOK = false
		end
		if curbase.y + 1 > ysize then
			downOK = false
			downRightOK = false
			downLeftOK = false
		end
		if curbase.y - 1 < 1 then
			upOK = false
			upLeftOK = false
			upRightOK = false
		end
		-- If it IS on the calcMap, check calcMap for obstacles
		--(Lua returns an error if you try to access a table position that doesn't exist, so you can't combine it with above)
		
		if curbase.x + 1 <= xsize and calcMap[curbase.y][curbase.x + 1] ~= 0 then
			rightOK = false
		end
		if curbase.x - 1 >= 1 and calcMap[curbase.y][curbase.x - 1] ~= 0 then
			leftOK = false
		end
		if curbase.y + 1 <= ysize and calcMap[curbase.y + 1][curbase.x] ~= 0 then
			downOK = false
		end
		if curbase.y - 1 >= 1 and calcMap[curbase.y - 1][curbase.x] ~= 0 then
			upOK = false
		end
		-- Diagonals
		if curbase.x - 1 >= 1 and curbase.y - 1 >= 1 and calcMap[curbase.y - 1][curbase.x - 1] ~= 0 then
			upLeftOK = false
		end
		if curbase.x + 1 <= xsize and curbase.y - 1 >= 1 and calcMap[curbase.y - 1][curbase.x + 1] ~= 0 then
			upRightOK = false
		end
		if curbase.x - 1 >= 1 and curbase.y + 1 <= ysize and calcMap[curbase.y + 1][curbase.x - 1] ~= 0 then
			downLeftOK = false
		end
		if curbase.x + 1 <= xsize and curbase.y + 1 <= ysize and calcMap[curbase.y +1][curbase.x + 1] ~= 0 then
			downRightOK = false
		end
		-- check if the move from the current base is shorter then from the former parent
		tempG = curbase.g + 1
		tempDiagG = curbase.g + 1.4
		for k = 1,listk do
			if rightOK and openlist[k].x == curbase.x+1 and openlist[k].y == curbase.y and openlist[k].g > tempG then
				tempH = math.abs((curbase.x+1)-tx)+math.abs(curbase.y-ty)
				table.insert(openlist,k,{x=curbase.x+1, y=curbase.y, g=tempG, h=tempH,f=tempG+tempH, par=closedk})
				-- Check if the order needs to be changed
				local m = k
				while m ~= 1 do
					if openlist[m].f <= openlist[math.floor(m/2)].f then
						temp = openlist[math.floor(m/2)]
						openlist[math.floor(m/2)] = openlist[m]
						openlist[m] = temp
						m = math.floor(m/2)
					else
						break
					end
				end
				rightOK = false
			end

			if leftOK and openlist[k].x == curbase.x-1 and openlist[k].y == curbase.y and openlist[k].g > tempG then
				tempH = math.abs((curbase.x-1)-tx)+math.abs(curbase.y-ty)
				table.insert(openlist,k,{x=curbase.x-1, y=curbase.y, g=tempG, h=tempH,f=tempG+tempH, par=closedk})
				-- Check if the order needs to be changed
				m = k
				while m ~= 1 do
					if openlist[m].f <= openlist[math.floor(m/2)].f then
						temp = openlist[math.floor(m/2)]
						openlist[math.floor(m/2)] = openlist[m]
						openlist[m] = temp
						m = math.floor(m/2)
					else
						break
					end
				end
				leftOK = false
			end

			if downOK and openlist[k].x == curbase.x and openlist[k].y == curbase.y+1 and openlist[k].g > tempG then
				tempH = math.abs((curbase.x)-tx)+math.abs(curbase.y+1-ty)
				table.insert(openlist,k,{x=curbase.x, y=curbase.y+1, g=tempG, h=tempH,f=tempG+tempH, par=closedk})
				-- Check if the order needs to be changed
				m = k
				while m ~= 1 do
					if openlist[m].f <= openlist[math.floor(m/2)].f then
						temp = openlist[math.floor(m/2)]
						openlist[math.floor(m/2)] = openlist[m]
						openlist[m] = temp
						m = math.floor(m/2)
					else
						break
					end
				end
				downOK = false
			end

			if upOK and openlist[k].x == curbase.x and openlist[k].y == curbase.y-1 and
				openlist[k].g > tempG then
				tempH = math.abs((curbase.x)-tx)+math.abs(curbase.y-1-ty)
				table.insert(openlist,k,{x=curbase.x, y=curbase.y-1, g=tempG, h=tempH,f=tempG+tempH, par=closedk})
				-- Check if the order needs to be changed
				m = k
				while m ~= 1 do
					if openlist[m].f <= openlist[math.floor(m/2)].f then
						temp = openlist[math.floor(m/2)]
						openlist[math.floor(m/2)] = openlist[m]
						openlist[m] = temp
						m = math.floor(m/2)
					else
						break
					end
				end
				upOK = false
			end

			-- Diagonals
			if upLeftOK and openlist[k].x == curbase.x - 1 and openlist[k].y == curbase.y- 1 and openlist[k].g > tempDiagG then
				tempH = math.abs((curbase.x - 1) - tx) + math.abs((curbase.y - 1) - ty)
				table.insert(openlist,k,{x =curbase.x - 1, y=curbase.y - 1, g=tempDiagG, h=tempH, f=tempDiagG+tempH, par=closedk})
				-- Check if the order needs to be changed
				local m = k
				while m ~= 1 do
					if openlist[m].f <= openlist[math.floor(m/2)].f then
						temp = openlist[math.floor(m/2)]
						openlist[math.floor(m/2)] = openlist[m]
						openlist[m] = temp
						m = math.floor(m/2)
					else
						break
					end
				end
				upLeftOK = false
			end

			if upRightOK and openlist[k].x == curbase.x + 1 and openlist[k].y == curbase.y- 1 and openlist[k].g > tempDiagG then
				tempH = math.abs((curbase.x + 1) - tx) + math.abs((curbase.y - 1) - ty)
				table.insert(openlist,k,{x =curbase.x + 1, y=curbase.y - 1, g=tempDiagG, h=tempH,f=tempDiagG+tempH, par=closedk})

				-- Check if the order needs to be changed
				local m = k
				while m ~= 1 do
					if openlist[m].f <= openlist[math.floor(m/2)].f then
						temp = openlist[math.floor(m/2)]
						openlist[math.floor(m/2)] = openlist[m]
						openlist[m] = temp
						m = math.floor(m/2)
					else
						break
					end
				end
				upRightOK = false
			end 
			if downLeftOK and openlist[k].x == curbase.x - 1 and openlist[k].y == curbase.y + 1 and openlist[k].g > tempDiagG then
				tempH = math.abs((curbase.x - 1) - tx) + math.abs((curbase.y + 1) - ty)
				table.insert(openlist,k,{x =curbase.x - 1, y=curbase.y + 1, g=tempDiagG, h=tempH,f=tempDiagG+tempH, par=closedk})
				-- Check if the order needs to be changed
				local m = k
				while m ~= 1 do
					if openlist[m].f <= openlist[math.floor(m/2)].f then
						temp = openlist[math.floor(m/2)]
						openlist[math.floor(m/2)] = openlist[m]
						openlist[m] = temp
						m = math.floor(m/2)
					else
						break
					end
				end
				downLeftOK = false
			end

			if downRightOK and openlist[k].x == curbase.x + 1 and openlist[k].y == curbase.y + 1 and openlist[k].g > tempDiagG then
			tempH = math.abs((curbase.x + 1) - tx) + math.abs((curbase.y + 1) - ty)
			table.insert(openlist,k,{x =curbase.x + 1, y=curbase.y + 1, g=tempDiagG, h=tempH,f=tempDiagG+tempH, par=closedk})
			-- Check if the order needs to be changed
			local m = k
			while m ~= 1 do
				if openlist[m].f <= openlist[math.floor(m/2)].f then
					temp = openlist[math.floor(m/2)]
					openlist[math.floor(m/2)] = openlist[m]
					openlist[m] = temp
					m = math.floor(m/2)
				else
					break
				end
			end
			downRightOK = false
		end
		end
		-- Add points to openlist
		-- Add point to the right of current base point
		if rightOK then
			listk=listk+1
			tempH=math.abs((curbase.x+1)-tx)+math.abs(curbase.y-ty)
			table.insert(openlist,listk,{x=curbase.x+1, y=curbase.y, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
			-- Add node to openlist
			m = listk
			while m ~= 1 do
				if openlist[m].f <= openlist[math.floor(m/2)].f then
					temp = openlist[math.floor(m/2)]
					openlist[math.floor(m/2)] = openlist[m]
					openlist[m] = temp
					m = math.floor(m/2)
				else
					break
				end
			end
		end
		-- Add point to the left of current base point
		if leftOK then
			listk=listk+1
			tempH=math.abs((curbase.x-1)-tx)+math.abs(curbase.y-ty)
			table.insert(openlist,listk,{x=curbase.x-1, y=curbase.y, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
			-- Add node to openlist
			m = listk
			while m ~= 1 do
				if openlist[m].f <= openlist[math.floor(m/2)].f then
					temp = openlist[math.floor(m/2)]
					openlist[math.floor(m/2)] = openlist[m]
					openlist[m] = temp
					m = math.floor(m/2)
				else
					break
				end
			end
		end
		-- Add point on the top of current base point
		if downOK then
			listk=listk+1
			tempH=math.abs(curbase.x-tx)+math.abs((curbase.y+1)-ty)
			table.insert(openlist,listk,{x=curbase.x, y=curbase.y+1, g=tempG, h=tempH, f=tempG+tempH, par=closedk})

			-- Add node to openlist
			m = listk
			while m ~= 1 do
				if openlist[m].f <= openlist[math.floor(m/2)].f then
					temp = openlist[math.floor(m/2)]
					openlist[math.floor(m/2)] = openlist[m]
					openlist[m] = temp
					m = math.floor(m/2)
				else
					break
				end
			end
		end
		-- Add point on the bottom of current base point
		if upOK then
			listk=listk+1
			tempH=math.abs(curbase.x-tx)+math.abs((curbase.y-1)-ty)
			table.insert(openlist,listk,{x=curbase.x, y=curbase.y-1, g=tempG, h=tempH,f=tempG+tempH, par=closedk})
			-- Add node to openlist
			m = listk
			while m ~= 1 do
				if openlist[m].f <= openlist[math.floor(m/2)].f then
					temp = openlist[math.floor(m/2)]
					openlist[math.floor(m/2)] = openlist[m]
					openlist[m] = temp
					m = math.floor(m/2)
				else
					break
				end
			end
		end
		-- Add point to the upper left of current base point
		if upLeftOK then
			listk = listk + 1
			tempH = math.abs((curbase.x - 1) - tx) + math.abs((curbase.y - 1) - ty)
			table.insert(openlist, listk, {x=curbase.x - 1, y=curbase.y - 1, g=tempDiagG, h=tempH, f=tempDiagG+tempH, par=closedk})
			-- Add node to openlist
			m = listk
			while m ~= 1 do
				if openlist[m].f <= openlist[math.floor(m/2)].f then
					temp = openlist[math.floor(m/2)]
					openlist[math.floor(m/2)] = openlist[m]
					openlist[m] = temp
					m = math.floor(m/2)
				else
					break
				end
			end
		end
		-- Add point to the upper right of current base point
		if upRightOK then
			listk = listk + 1
			tempH = math.abs((curbase.x + 1) - tx) + math.abs((curbase.y - 1) - ty)
			table.insert(openlist, listk, {x=curbase.x + 1, y=curbase.y - 1, g=tempDiagG,h=tempH, f=tempDiagG+tempH, par=closedk})
			-- Add node to openlist
			m = listk
			while m ~= 1 do
				if openlist[m].f <= openlist[math.floor(m/2)].f then
					temp = openlist[math.floor(m/2)]
					openlist[math.floor(m/2)] = openlist[m]
					openlist[m] = temp
					m = math.floor(m/2)
				else
					break
				end
			end
		end
		-- Add point to the lower left of current base point
		if downLeftOK then
			listk = listk + 1
			tempH = math.abs((curbase.x - 1) - tx) + math.abs((curbase.y + 1) - ty)
			table.insert(openlist, listk, {x=curbase.x - 1, y=curbase.y + 1, g=tempDiagG,h=tempH, f=tempDiagG+tempH, par=closedk})
			-- Add node to openlist
			m = listk
			while m ~= 1 do
				if openlist[m].f <= openlist[math.floor(m/2)].f then
					temp = openlist[math.floor(m/2)]
					openlist[math.floor(m/2)] = openlist[m]
					openlist[m] = temp
					m = math.floor(m/2)
				else
					break
				end
			end
		end
		-- Add point to the lower right of current base point
		if downRightOK then
			listk = listk + 1
			tempH = math.abs((curbase.x + 1) - tx) + math.abs((curbase.y + 1) - ty)
			table.insert(openlist, listk, {x=curbase.x + 1, y=curbase.y + 1, g=tempDiagG,h=tempH, f=tempDiagG+tempH, par=closedk})
			-- Add node to openlist
			m = listk
			while m ~= 1 do
				if openlist[m].f <= openlist[math.floor(m/2)].f then
					temp = openlist[math.floor(m/2)]
					openlist[math.floor(m/2)] = openlist[m]
					openlist[m] = temp
					m = math.floor(m/2)
				else
					break
				end
			end
		end
	end

	return nil
end

function CalcPath(closedlist)
	if closedlist == nil or table.getn(closedlist) == 1 then
		return nil
	end
	local path = {}
	local pathIndex = {}
	local last = table.getn(closedlist)
	table.insert(pathIndex,1,last)
	local i = 1
	while pathIndex[i] > 1 do
		i = i + 1
		table.insert(pathIndex, i, closedlist[pathIndex[i - 1]].par)
	end 

	for n = table.getn(pathIndex) - 1, 1, -1 do
		table.insert(path, {x = closedlist[pathIndex[n]].x, y =	closedlist[pathIndex[n]].y})
	end

	closedlist = nil
	return path
end
