function AutoDrive:removeMapWayPoint(toDelete)
	AutoDrive:MarkChanged();
	
	--remove node on all out going nodes
	for _,node in pairs(toDelete.out) do	
		local deleted = false;
		for __,incoming in pairs(AutoDrive.mapWayPoints[node].incoming) do
			if incoming == toDelete.id then
				deleted = true
			end				
			if deleted then
				if AutoDrive.mapWayPoints[node].incoming[__ + 1] ~= nil then
					AutoDrive.mapWayPoints[node].incoming[__] = AutoDrive.mapWayPoints[node].incoming[__ + 1];
				else
					AutoDrive.mapWayPoints[node].incoming[__] = nil;
				end;
			end;								
		end;			
	end;
	
	local mapWayPoints = AutoDrive.mapWayPoints;
	local mapWayPointsCounter = AutoDrive.mapWayPointsCounter;

	--remove node on all incoming nodes	
	for _,node in pairs(mapWayPoints) do		
		local deleted = false;
		for __,out_id in pairs(node.out) do
			if out_id == toDelete.id then
				deleted = true;
			end;			
			
			if deleted then
				if node.out[__ + 1 ] ~= nil then
					node.out[__] = node.out[__+1];
				else
					node.out[__] = nil;
				end;
			end;
		end;	
	end;
	
	--adjust ids for all succesive nodes :(		
	local deleted = false;
	for nodeID, node in pairs(mapWayPoints) do
		for outGoingIndex, outGoingNodeID in pairs(node.out) do
			if outGoingNodeID > toDelete.id then
				node.out[outGoingIndex] = outGoingNodeID - 1;
			end;
		end;

		for incomingIndex, incomingNodeID in pairs(node.incoming) do
			if incomingNodeID > toDelete.id then
				node.incoming[incomingIndex] = incomingNodeID - 1;
			end;
		end;
			
		if nodeID > toDelete.id then

			mapWayPoints[nodeID - 1] = node;
			node.id = node.id - 1;
			
			if mapWayPoints[nodeID + 1] == nil then
				deleted = true;
				mapWayPoints[nodeID] = nil;
				mapWayPointsCounter = mapWayPointsCounter - 1;
			end;
		end;
	end;
	
	--must have been last added waypoint that got deleted. handle this here:
	if deleted == false then
		mapWayPoints[mapWayPointsCounter] = nil;
		mapWayPointsCounter = mapWayPointsCounter - 1;
	end;
	
	--adjust all mapmarkers
	local deletedMarkerID = -1;
	local deletedMarker = false;
	for markerID, marker in pairs(AutoDrive.mapMarker) do
		if marker.id == toDelete.id then
			deletedMarker = true;
			deletedMarkerID = markerID;
			AutoDrive.mapMarkerCounter = AutoDrive.mapMarkerCounter - 1;
		end;
		if deletedMarker then
			if AutoDrive.mapMarker[markerID+1] ~= nil then
				AutoDrive.mapMarker[markerID] =  AutoDrive.mapMarker[markerID+1];
			else
				AutoDrive.mapMarker[markerID] = nil;
				removeXMLProperty(AutoDrive.adXml, "AutoDrive." .. AutoDrive.loadedMap .. ".mapmarker.mm".. markerID) ;
			end;			
		end;
		if marker.id > toDelete.id then
			marker.id = marker.id -1;
		end;
	end;

	if deletedMarker then
		for _, vehicle in pairs(g_currentMission.vehicles) do
			if vehicle.ad ~= nil then
				if vehicle.ad.parkDestination ~= nil and vehicle.ad.parkDestination > deletedMarkerID then
					vehicle.ad.parkDestination = vehicle.ad.parkDestination - 1;
				end;			
				if vehicle.ad.mapMarkerSelected ~= nil and vehicle.ad.mapMarkerSelected > deletedMarkerID then
					vehicle.ad.mapMarkerSelected = vehicle.ad.mapMarkerSelected - 1;				
					vehicle.ad.targetSelected = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].id;
					vehicle.ad.nameOfSelectedTarget = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].name;
				end;
				if vehicle.ad.mapMarkerSelected_Unload ~= nil and vehicle.ad.mapMarkerSelected_Unload > deletedMarkerID then
					vehicle.ad.mapMarkerSelected_Unload = vehicle.ad.mapMarkerSelected_Unload - 1;
					vehicle.ad.targetSelected_Unload = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].id;
					vehicle.ad.nameOfSelectedTarget_Unload = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].name;
				end;
			end;
		end;
	end;

	AutoDrive.mapWayPoints = mapWayPoints;
	AutoDrive.mapWayPointsCounter = mapWayPointsCounter;

	AutoDrive:broadCastUpdateToClients();
	
	AutoDrive:notifyDestinationListeners();	
	AutoDrive.Hud.lastUIScale = 0;
end;

function AutoDrive:removeMapMarker(toDelete)
	--adjust all mapmarkers
	local deletedMarkerID = -1;
	local deletedMarker = false;
	for markerID,marker in pairs(AutoDrive.mapMarker) do
		if marker.id == toDelete.id then
			deletedMarker = true;
			deletedMarkerID = markerID;
			AutoDrive.mapMarkerCounter = AutoDrive.mapMarkerCounter - 1;
		end;
		if deletedMarker then
			if AutoDrive.mapMarker[markerID+1] ~= nil then
				AutoDrive.mapMarker[markerID] =  AutoDrive.mapMarker[markerID+1];
			else
				AutoDrive.mapMarker[markerID] = nil;
				removeXMLProperty(AutoDrive.adXml, "AutoDrive." .. AutoDrive.loadedMap .. ".mapmarker.mm".. markerID) ;
			end;
		end;
	end;

	if deletedMarker then
		for _, vehicle in pairs(g_currentMission.vehicles) do
			if vehicle.ad ~= nil then
				if vehicle.ad.parkDestination ~= nil and vehicle.ad.parkDestination >= deletedMarkerID then
					vehicle.ad.parkDestination = vehicle.ad.parkDestination - 1;
				end;
				if vehicle.ad.mapMarkerSelected ~= nil and vehicle.ad.mapMarkerSelected >= deletedMarkerID then
					vehicle.ad.mapMarkerSelected = vehicle.ad.mapMarkerSelected - 1;				
					vehicle.ad.targetSelected = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].id;
					vehicle.ad.nameOfSelectedTarget = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].name;
				end;
				if vehicle.ad.mapMarkerSelected_Unload ~= nil and vehicle.ad.mapMarkerSelected_Unload >= deletedMarkerID then
					vehicle.ad.mapMarkerSelected_Unload = vehicle.ad.mapMarkerSelected_Unload - 1;
					vehicle.ad.targetSelected_Unload = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].id;
					vehicle.ad.nameOfSelectedTarget_Unload = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].name;
				end;
			end;
		end;
	end;

	AutoDrive:MarkChanged();
	AutoDrive:notifyDestinationListeners();
	
	AutoDrive:broadCastUpdateToClients();
	
	AutoDrive.Hud.lastUIScale = 0;	
end

function AutoDrive:createWayPoint(vehicle, x, y, z, connectPrevious, dual)
	AutoDrive:MarkChanged();
	if vehicle.ad.createMapPoints == true then
		AutoDrive.mapWayPointsCounter = AutoDrive.mapWayPointsCounter + 1;
		if AutoDrive.mapWayPointsCounter > 1 and connectPrevious then
			--edit previous point
			local out_index = 1;
			if AutoDrive.mapWayPoints[AutoDrive.mapWayPointsCounter-1].out[out_index] ~= nil then out_index = out_index+1; end;
			AutoDrive.mapWayPoints[AutoDrive.mapWayPointsCounter-1].out[out_index] = AutoDrive.mapWayPointsCounter;
		end;
		
		--edit current point
		--print("Creating Waypoint #" .. AutoDrive.mapWayPointsCounter);
		AutoDrive.mapWayPoints[AutoDrive.mapWayPointsCounter] = AutoDrive:createNode(AutoDrive.mapWayPointsCounter,x, y, z, {},{},{});
		if connectPrevious then
			AutoDrive.mapWayPoints[AutoDrive.mapWayPointsCounter].incoming[1] = AutoDrive.mapWayPointsCounter-1;
		end;
	end;
	if vehicle.ad.creationModeDual == true and connectPrevious then
		local incomingNodes = 1;
		for _,__ in pairs(AutoDrive.mapWayPoints[AutoDrive.mapWayPointsCounter-1].incoming) do
			incomingNodes = incomingNodes + 1;
		end;
		AutoDrive.mapWayPoints[AutoDrive.mapWayPointsCounter-1].incoming[incomingNodes] = AutoDrive.mapWayPointsCounter;
		--edit current point
		AutoDrive.mapWayPoints[AutoDrive.mapWayPointsCounter].out[1] = AutoDrive.mapWayPointsCounter-1;
	end;

	AutoDriveCourseEditEvent:sendEvent(AutoDrive.mapWayPoints[AutoDrive.mapWayPointsCounter]);
	if (AutoDrive.mapWayPoints[AutoDrive.mapWayPointsCounter-1] ~= nil) then
		AutoDriveCourseEditEvent:sendEvent(AutoDrive.mapWayPoints[AutoDrive.mapWayPointsCounter-1]);
	end;

	return AutoDrive.mapWayPoints[AutoDrive.mapWayPointsCounter];
end;

function AutoDrive:handleRecording(vehicle)
	if vehicle == nil or vehicle.ad.creationMode == false then
		return;
	end;

	if g_server == nil then
		return;
	end;

	local i = 1;
	for n in pairs(vehicle.ad.wayPoints) do 
		i = i+1;
	end;
	
	--first entry
	if i == 1 then
		local startPoint = AutoDrive:findClosestWayPoint(vehicle);
		local x1,y1,z1 = getWorldTranslation(vehicle.components[1].node);		
		if vehicle.ad.createMapPoints == true then
			vehicle.ad.wayPoints[i] = AutoDrive:createWayPoint(vehicle, x1, y1, z1, false, vehicle.ad.creationModeDual)		
		end;
		
		if AutoDrive:getSetting("autoConnectStart") then 
			if startPoint ~= nil then
				local startNode = AutoDrive.mapWayPoints[startPoint];
				if startNode ~= nil then
					if AutoDrive:getDistanceBetweenNodes(startPoint, AutoDrive.mapWayPointsCounter) < 20 then
						startNode.out[ADTableLength(startNode.out)+1] = vehicle.ad.wayPoints[i].id;
						vehicle.ad.wayPoints[i].incoming[ADTableLength(vehicle.ad.wayPoints[i].incoming)+1] = startNode.id;

						if vehicle.ad.creationModeDual then
							local incomingNodes = 1;
							for _,__ in pairs(AutoDrive.mapWayPoints[startPoint].incoming) do
								incomingNodes = incomingNodes + 1;
							end;
							AutoDrive.mapWayPoints[startPoint].incoming[incomingNodes] = AutoDrive.mapWayPointsCounter;
							--edit current point
							vehicle.ad.wayPoints[i].out[1] = startPoint;
						end;

						AutoDriveCourseEditEvent:sendEvent(startNode);
					end;
				end;
			end;
		end;
		
		i = i+1;
	else
		if i == 2 then
			local x,y,z = getWorldTranslation(vehicle.components[1].node);
			local wp = vehicle.ad.wayPoints[i-1];
			if AutoDrive:getDistance(x,z,wp.x,wp.z) > 3 then
				if vehicle.ad.createMapPoints == true then
					vehicle.ad.wayPoints[i] = AutoDrive:createWayPoint(vehicle, x, y, z, true, vehicle.ad.creationModeDual)		
				end;
				i = i+1;
			end;
		else
			local x,y,z = getWorldTranslation(vehicle.components[1].node);
			local wp = vehicle.ad.wayPoints[i-1];
			local wp_ref = vehicle.ad.wayPoints[i-2]
			local angle = math.abs(AutoDrive:angleBetween( {x=x-wp_ref.x,z=z-wp_ref.z},{x=wp.x-wp_ref.x, z = wp.z - wp_ref.z } ))
			local max_distance = 6;
			if angle < 1 then max_distance = 6; end;
			if angle >= 1 and angle < 2 then max_distance = 4; end;
			if angle >= 2 and angle < 3 then max_distance = 4; end;
			if angle >= 3 and angle < 5 then max_distance = 3; end;
			if angle >= 5 and angle < 8 then max_distance = 2; end;
			if angle >= 8 and angle < 12 then max_distance = 1; end;
			if angle >= 12 and angle < 15 then max_distance = 1; end;
			if angle >= 15 and angle < 50 then max_distance = 0.5; end;

			if AutoDrive:getDistance(x,z,wp.x,wp.z) > max_distance then
				if vehicle.ad.createMapPoints == true then
					vehicle.ad.wayPoints[i] = AutoDrive:createWayPoint(vehicle, x, y, z, true, vehicle.ad.creationModeDual)		
				end;
				i = i+1;
			end;
		end;
	end;
end;

function AutoDrive:handleRecalculation(vehicle)
	if AutoDrive.Recalculation ~= nil and ((vehicle == g_currentMission.controlledVehicle and g_server ~= nil) or (g_server ~= nil)) then	
		if AutoDrive.Recalculation.continue == true then
			if AutoDrive.Recalculation.nextCalculationSkipFrames <= 0 then
				AutoDrive.recalculationPercentage = AutoDrive:ContiniousRecalculation();
				AutoDrive.Recalculation.nextCalculationSkipFrames = 0;

				AutoDrive.recalculationPercentage = math.min(AutoDrive.recalculationPercentage, 100);

				AutoDrive:printMessage(vehicle, g_i18n:getText("AD_Recalculationg_routes_status") .. " " .. AutoDrive.recalculationPercentage .. "%");
				AutoDrive.print.showMessageFor = 500;
				if AutoDrive.recalculationPercentage == 100 then
					AutoDrive.print.showMessageFor = 5000;
				end;
			else
				AutoDrive.Recalculation.nextCalculationSkipFrames =  AutoDrive.Recalculation.nextCalculationSkipFrames - 1;
			end;
		end;

	end;
end;

function AutoDrive:isDualRoad(start, target)
	if start == nil or target == nil or start.incoming == nil or target.id == nil then
		return false;
	end;
	for _,incoming in pairs(start.incoming) do
		if incoming == target.id then
			return true;
		end;
	end;
	return false;
end;

function AutoDrive:getDistanceBetweenNodes(start, target)
	local isMapMarker = false;
	for _,mapMarker in pairs(AutoDrive.mapMarker) do
		if mapMarker.id == start then
			isMapMarker = true;
		end;
	end;

	local euclidianDistance = AutoDrive:getDistance(AutoDrive.mapWayPoints[start].x, AutoDrive.mapWayPoints[start].z, AutoDrive.mapWayPoints[target].x, AutoDrive.mapWayPoints[target].z);

	local distance = euclidianDistance;
	if isMapMarker and AutoDrive:getSetting("avoidMarkers") == true then
		distance = distance + AutoDrive:getSetting("mapMarkerDetour");
	end;

	return distance;
end;

function AutoDrive:getDriveTimeBetweenNodes(start, target, past, maxDrivingSpeed, arrivalTime)
	--changed setToUse to defined 3 point for angle calculation														
	local wp_ahead = AutoDrive.mapWayPoints[target];
	local wp_current = AutoDrive.mapWayPoints[start];
	
	
	if wp_ahead == nil or wp_current == nil then
		return 0;
	end;

	local angle = 0;
	
	if past ~= nil then
		local wp_ref = AutoDrive.mapWayPoints[past]
		if wp_ref ~= nil then
			angle = math.abs(AutoDrive:angleBetween( 	{x=	wp_ahead.x	-	wp_current.x, z = wp_ahead.z - wp_current.z },
														{x=	wp_current.x-	wp_ref.x, z = wp_current.z - wp_ref.z } ));  
		end; 
	end;
	
	local driveTime = 0;
	local drivingSpeed = 50;
	if maxDrivingSpeed ~= nil then
		drivingSpeed = maxDrivingSpeed;
	end;

	if angle < 3 then drivingSpeed = math.min(drivingSpeed, 50); end;
	if angle >= 3 and angle < 5 then drivingSpeed = math.min(drivingSpeed, 38); end;
	if angle >= 5 and angle < 8 then drivingSpeed = math.min(drivingSpeed, 27); end;
	if angle >= 8 and angle < 12 then drivingSpeed = math.min(drivingSpeed, 20); end;
	if angle >= 12 and angle < 15 then drivingSpeed = math.min(drivingSpeed, 13); end;
	if angle >= 15 and angle < 20 then drivingSpeed = math.min(drivingSpeed, 10); end;
	if angle >= 20 and angle < 30 then drivingSpeed = math.min(drivingSpeed, 7); end;
	if angle >= 30 then drivingSpeed = math.min(drivingSpeed, 4); end;

	local drivingDistance = AutoDrive:getDistance(wp_ahead.x, wp_ahead.z, wp_current.x, wp_current.z);	

	driveTime = (drivingDistance) / (drivingSpeed * (1000/3600));

	--avoid map marker
	
	if not arrivalTime == true then --only for djikstra, for live travel timer we ignore it
		local isMapMarker = false;
		for _,mapMarker in pairs(AutoDrive.mapMarker) do
			if mapMarker.id == start then
				isMapMarker = true;
				break;
			end;
		end;
	
		if isMapMarker and AutoDrive:getSetting("avoidMarkers") == true then
			driveTime = driveTime + (AutoDrive:getSetting("mapMarkerDetour") / (20 / 3.6));
		end;
	end;												 
	return driveTime;
end;

function AutoDrive:getDriveTimeForWaypoints(wps, currentWaypoint, maxDrivingSpeed)
	local totalTime = 0;

	if wps ~= nil and currentWaypoint ~= nil and wps[currentWaypoint+1] ~= nil and wps[currentWaypoint] ~= nil and wps[currentWaypoint-1] == nil then
		totalTime = totalTime + AutoDrive:getDriveTimeBetweenNodes(wps[currentWaypoint].id, wps[currentWaypoint+1].id, nil , maxDrivingSpeed, true); --first segment, only 2 points, no angle
		currentWaypoint = currentWaypoint + 1;
	end;
	while wps ~= nil and wps[currentWaypoint-1] ~= nil and currentWaypoint ~= nil and wps[currentWaypoint+1] ~= nil do
		if wps[currentWaypoint] ~= nil then
			totalTime = totalTime + AutoDrive:getDriveTimeBetweenNodes(wps[currentWaypoint].id, wps[currentWaypoint+1].id, wps[currentWaypoint-1].id, maxDrivingSpeed, true); --continuous segments, 3 points for angle
		end;
		currentWaypoint = currentWaypoint + 1;
	end;
	return totalTime * 1.15; --reduced the factor a little bit
end;

function AutoDrive:sortNodesByDistance(x, z, listOfNodes)
	local sortedList = {};
	local outerLoop = 1;
	local minDistance = math.huge;
	local minDistanceNode = -1;
	for i = 1, ADTableLength(listOfNodes) do
		for currentNode,checkNode in pairs(listOfNodes) do
			local distance = AutoDrive:getDistance(x, z, AutoDrive.mapWayPoints[checkNode.id].x, AutoDrive.mapWayPoints[checkNode.id].z);
			
			local alreadyInList = false;	
			for _,alreadySorted in pairs(sortedList) do
				if alreadySorted.id == checkNode.id then
					alreadyInList = true;
				end;
			end;

			if (distance < minDistance) and (not alreadyInList) then
				minDistance = distance;
				minDistanceNode = checkNode;
			end;
		end;	
		sortedList[i] = minDistanceNode;
		minDistance = math.huge;
	end;

	return sortedList;
end;

function AutoDrive:getHighestConsecutiveIndex()
	local toCheckFor = 0;
	local consecutive = true;
	while consecutive == true do
		toCheckFor = toCheckFor + 1;
		consecutive = false;
		if AutoDrive.mapWayPoints[toCheckFor] ~= nil then
			if AutoDrive.mapWayPoints[toCheckFor].id == toCheckFor then
				consecutive = true;
			end;
		end;
	end;
	
	return (toCheckFor-1);
end;

function AutoDrive:FastShortestPath(Graph,start,markerName, markerID)	
	local wp = {};
	local count = 1;
	local id = start;
	while id ~= -1 and id ~= nil do		
		wp[count] = Graph[id];
		count = count+1;
		if id == markerID then
			id = nil;
		else
			if AutoDrive.mapWayPoints[id] ~= nil then
				id = AutoDrive.mapWayPoints[id].marker[markerName];
			else
				id = nil;
			end;
		end;
		if count > 5000 then
			return {};  --something went wrong. prevent overflow here
		end;
	end;
	
	local wp_copy = AutoDrive:graphcopy(wp);
		
	return wp_copy;
end;

function AutoDrive:findClosestWayPoint(veh)
	if veh.ad.closest ~= nil then
		return veh.ad.closest;
	end;

	--returns waypoint closest to vehicle position
	local x1,y1,z1 = getWorldTranslation(veh.components[1].node);
	local closest = -1;
	if AutoDrive.mapWayPoints[1] ~= nil then

		local distance = math.huge; --AutoDrive:getDistance(AutoDrive.mapWayPoints[1].x,AutoDrive.mapWayPoints[1].z,x1,z1);
		for i in pairs(AutoDrive.mapWayPoints) do
			local dis = AutoDrive:getDistance(AutoDrive.mapWayPoints[i].x,AutoDrive.mapWayPoints[i].z,x1,z1);
			if dis < distance then
				closest = i;
				distance = dis;
			end;
		end;
	end;
	
	veh.ad.closest = closest;

	return closest;
end;

function AutoDrive:findMatchingWayPointForVehicle(veh)
	--returns waypoint closest to vehicle position and with the most suited heading
	local x1,y1,z1 = getWorldTranslation(veh.components[1].node);
	local rx,ry,rz = localDirectionToWorld(veh.components[1].node, 0,0,1);
	local vehicleVector = {x= rx, z=rz };
	local point = {x=x1, z=z1};

	local bestPoint = AutoDrive:findMatchingWayPoint(point, vehicleVector, 1, 20);	

	if bestPoint == -1 then
		return AutoDrive:findClosestWayPoint(veh);
	end;

	return bestPoint;	
end;

function AutoDrive:findMatchingWayPoint(point, direction, rangeMin, rangeMax)
	local candidates = AutoDrive:getWayPointsInRange(point, rangeMin, rangeMax);
	
	local closest = -1;
	local distance = -1;
	local lastAngleToPoint = -1;
	local lastAngleToVehicle = -1;
	for i,id in pairs(candidates) do
		local toCheck = AutoDrive.mapWayPoints[id];
		local nextP = nil;
		local outIndex = 1;
		if toCheck.out ~= nil then			
			if toCheck.out[outIndex] ~= nil then
				nextP = AutoDrive.mapWayPoints[toCheck.out[outIndex]];
			end;

			while nextP ~= nil do
				local vecToNextPoint 	= {x = nextP.x - toCheck.x, 	z = nextP.z - toCheck.z};
				local vecToVehicle 		= {x = toCheck.x - point.x, 		z = toCheck.z - point.z };
				local angleToNextPoint 	= AutoDrive:angleBetween(direction, vecToNextPoint);
				local angleToVehicle 	= AutoDrive:angleBetween(direction, vecToVehicle);
				local dis = AutoDrive:getDistance(toCheck.x,toCheck.z,point.x,point.z);
				if closest == -1 and (math.abs(angleToNextPoint) < 60 and math.abs(angleToVehicle) < 30) then
					closest = toCheck.id;
					distance = dis;
					lastAngleToPoint = angleToNextPoint;
					lastAngleToVehicle = angleToVehicle;
				else
					if math.abs(angleToNextPoint + angleToVehicle) < math.abs(lastAngleToPoint + lastAngleToVehicle) and (math.abs(angleToNextPoint) < 60 and math.abs(angleToVehicle) < 30) then
						closest = toCheck.id;
						distance = dis;
						lastAngleToPoint = angleToNextPoint;
						lastAngleToVehicle = angleToVehicle;
					end;
				end;

				outIndex = outIndex + 1;
				if toCheck.out[outIndex] ~= nil then
					nextP = AutoDrive.mapWayPoints[toCheck.out[outIndex]];
				else
					nextP = nil;
				end;
			end;
		end;
	end;

	return closest;
end;

function AutoDrive:getWayPointsInRange(point, rangeMin, rangeMax)
	local inRange = {};
	local counter = 0;

	for i in pairs(AutoDrive.mapWayPoints) do
		local dis = AutoDrive:getDistance(AutoDrive.mapWayPoints[i].x,AutoDrive.mapWayPoints[i].z,point.x,point.z);
		if dis < rangeMax and dis > rangeMin then
			counter = counter + 1;
			inRange[counter] = i;
		end;
	end;

	return inRange;
end;

function AutoDrive:findMatchingWayPointForReverseDirection(veh)
	--returns waypoint closest to vehicle position and with the most suited heading
	local x1,y1,z1 = getWorldTranslation(veh.components[1].node);
	local rx,ry,rz = localDirectionToWorld(veh.components[1].node, 0,0,1);
	local vehicleVector = {x= -rx ,z= -rz };
	local point = {x=x1, z=z1};

	local bestPoint = AutoDrive:findMatchingWayPoint(point, vehicleVector, 0.1, 5);	

	if bestPoint == -1 then
		return nil;
	end;

	return bestPoint;	
end;

function AutoDrive:graphcopy(Graph)
	local Q = {};
	for i in pairs(Graph) do
		local id = Graph[i]["id"];
		local out = {};
		local incoming = {};
		local marker = {};
		
		for i2 in pairs(Graph[i]["out"]) do
			out[i2] = Graph[i]["out"][i2];
		end;

		for i3 in pairs(Graph[i]["incoming"]) do
			incoming[i3] = Graph[i]["incoming"][i3];
		end;	
		for i5 in pairs(Graph[i]["marker"]) do
			marker[i5] = Graph[i]["marker"][i5];
		end;		
		
		Q[i] = AutoDrive:createNode(id, Graph[i].x, Graph[i].y, Graph[i].z, out,incoming, marker);		
	end;
	return Q;
end;

function AutoDrive:createNode(id,x,y,z,out,incoming, marker)
	local p = {};
	p["x"] = x;
	p["y"] = y;
	p["z"] = z;
	p["id"] = id;
	p["out"] = out;
	p["incoming"] = incoming;
	p["marker"] = marker;
	
	return p;
end

function  AutoDrive:getDistance(x1,z1,x2,z2)
	return math.sqrt((x1-x2)*(x1-x2) + (z1-z2)*(z1-z2) );
end;

function AutoDrive:handleYPositionIntegrityCheck(vehicle)
	if AutoDrive.handledIntegrity ~= true then
		for _,wp in pairs(AutoDrive.mapWayPoints) do
			if wp.y == -1 then
				wp.y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, wp.x, 1, wp.z)
			end;
		end;
		AutoDrive.handledIntegrity = true;
	end;
end;

