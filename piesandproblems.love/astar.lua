local tAStarSearch = { tStart = {}, tGoal = {}, tOpen = {}, tClosed = {}, tSucc = {}, tSet = {}}

local function StateSet(tDst, tSrc)
	for k, v in pairs(tSrc) do tDst[k] = v end
end

local function StateCountDiff(tDst, tSrc)
	local iDiff = 0
	for k, v in pairs(tDst) do
		if rawget(tSrc, k) == nil or rawget(tSrc, k) ~= v then
			iDiff = iDiff + 1
		end
	end
	return iDiff
end

local function StateContain(tIn, tWhat)
	for k, v in pairs(tWhat) do
		if rawget(tIn, k) ~= nil and rawget(tIn, k) ~= v then
			return false
		end
	end
	return true
end

--Return the estimated cost to goal from this node (pass reference to goal node)
local function GoalDistanceEstimate(tNodeGoal, tInNode)
	return StateCountDiff(tNodeGoal.sta, tInNode.sta)
end

--Return true if this node is the goal.
local function IsGoal(tNodeGoal, tInNode)
	return (StateCountDiff(tNodeGoal.sta, tInNode.sta) == 0 and tInNode.act ~= nil)
end

--Return true if the provided state is the same as this state
local function IsSameState(tSta, tInNode)
	return (StateCountDiff(tSta.sta, tInNode.sta) == 0 and tSta.act ~= nil and tInNode.act ~= nil and tSta.act == tInNode.act)
end

local function CreateNode()
	local node = {sta = nil, act = nil, parent = nil, child = nil, g = 0.0, h = 0.0, f = 0.0}
	return node
end

local function GetSuccessors(tSrch, tInNode)
	for k, v in pairs(tSrch.tSet) do
		if StateContain(tInNode.sta, v.precond) then
			local afterAction = {}
			StateSet(afterAction, tInNode.sta)
			StateSet(afterAction, v.effect)

			local node = CreateNode()
			node.sta = afterAction
			node.act = v
			table.insert(tSrch.tSucc, node)
		end
	end
end

local function HeapCmp(tX, tY) return (tX.f &lt; tY.f) end

local function SetStartAndGoalStates(tStartSta, tGoalSta, tActions)
		tAStarSearch.tStart = CreateNode()
		tAStarSearch.tStart.sta = {}
		StateSet(tAStarSearch.tStart.sta, {bIdle = false, bRun = false, bFreeze = false, bFire = false, bReload = false})
		StateSet(tAStarSearch.tStart.sta, tStartSta)

		tAStarSearch.tGoal = CreateNode()
		tAStarSearch.tGoal.sta = {}
		StateSet(tAStarSearch.tGoal.sta, tGoalSta)

		tAStarSearch.tStart.g = 0; 
		tAStarSearch.tStart.h = GoalDistanceEstimate(tAStarSearch.tGoal, tAStarSearch.tStart);
		tAStarSearch.tStart.f = tAStarSearch.tStart.g + tAStarSearch.tStart.h;

		tAStarSearch.tOpen = {tAStarSearch.tStart}
		tAStarSearch.tClosed = {}
		tAStarSearch.tSet = tActions
end

local function SearchStep()
	if #tAStarSearch.tOpen == 0 then return &quot;failed to find&quot; end

--Pop the best node (the one with the lowest f) 
	local k, elem = next(tAStarSearch.tOpen)
	table.remove(tAStarSearch.tOpen, k)

--Check for the goal, once we pop that we're done
	if IsGoal(tAStarSearch.tGoal, elem) then
		tAStarSearch.tGoal.parent = elem
		local tChild = elem;
		local tParent = elem.parent;

		while tChild ~= tAStarSearch.tStart do
			tParent.child = tChild;

			tChild = tParent;
			tParent = tChild.parent;
		end

		return &quot;found&quot;
	else --not goal
		tAStarSearch.tSucc = {}
		GetSuccessors(tAStarSearch, elem); 

		for it, succ in pairs(tAStarSearch.tSucc) do
			local iNewG = elem.g + 1;

			local bSmallerInOpen = false
			for opIt, opV in pairs(tAStarSearch.tOpen) do
				if IsSameState(opV, succ) then
					if opV.g &lt;= iNewG then
						bSmallerInOpen = true
						break;
					end
					table.remove(tAStarSearch.tOpen, opIt)
					break;
				end
			end
			
			if bSmallerInOpen == false then
			
				local bSmallerInClosed = false
				for clIt, clV in pairs(tAStarSearch.tClosed) do
					if IsSameState(clV, succ) then
						if clV.g &lt;= iNewG then
							bSmallerInClosed = true
							break;
						end
						table.remove(tAStarSearch.tClosed, clIt)
						break;
					end
				end
				
				if bSmallerInClosed == false then
					succ.parent = elem
					succ.g = iNewG
					succ.h = GoalDistanceEstimate(tAStarSearch.tGoal, succ)
					succ.f = succ.g + succ.h

					table.insert(tAStarSearch.tOpen, succ)
					table.sort(tAStarSearch.tOpen, HeapCmp)
				end
			end
		end
--push n onto Closed, as we have expanded it now
		table.insert(tAStarSearch.tClosed, elem)
	end
	
	return &quot;work&quot;
end

local function GetSolution()
	local tSq = {}
	local tChild = tAStarSearch.tStart.child
	while tChild do
		table.insert(tSq, tChild.act)
		tChild = tChild.child
	end
	
	return tSq
end

function GOAP_GetSquence(tActions, tCurrGoal, tNeedGoal)
			
	local sTransaction = tCurrGoal.sDbgName .. &quot; ---&gt; &quot; .. tNeedGoal.sDbgName

	SetStartAndGoalStates(tCurrGoal.desired_state, tNeedGoal.desired_state, tActions)
	
	local iCount = 0
	local sLastState = &quot;work&quot;
	while sLastState == &quot;work&quot; do
	 sLastState = SearchStep()
	 iCount = iCount + 1
	end

	print(&quot;\t\t&quot;, sTransaction, &quot;(steps count &lt;&quot;, iCount,&quot;&gt;)&quot;)

	if sLastState == &quot;found&quot; then
		local tSq = GetSolution()
		for k, v in pairs(tSq) do print(&quot;\t\t\t&quot;, v.sDbgName) end
	else
		print(&quot;\t\t\t&quot;, sLastState)
	end
	print(&quot; &quot;)
end