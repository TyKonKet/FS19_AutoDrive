function AutoDrive:onActionCall(actionName, keyStatus, arg4, arg5, arg6)
	--print("AutoDrive onActionCall.." .. actionName);

	if actionName == "ADSilomode" then			
		--print("sending event to InputHandling");
		AutoDrive:InputHandling(self, "input_silomode");
	end;	
	if actionName == "ADRecord" then
		AutoDrive:InputHandling(self, "input_record");			
	end; 
		
	if actionName == "ADRecord_Dual" then
		AutoDrive:InputHandling(self, "input_record_dual");			
	end; 
	
	if actionName == "ADEnDisable" then
		AutoDrive:InputHandling(self, "input_start_stop");			
	end; 
	
	if actionName ==  "ADSelectTarget" then
		AutoDrive:InputHandling(self, "input_nextTarget");			
	end; 
	
	if actionName == "ADSelectPreviousTarget" then
		AutoDrive:InputHandling(self, "input_previousTarget");
	end;

	if actionName ==  "ADSelectTargetUnload" then
		AutoDrive:InputHandling(self, "input_nextTarget_Unload");			
	end; 
	
	if actionName == "ADSelectPreviousTargetUnload" then
		AutoDrive:InputHandling(self, "input_previousTarget_Unload");
	end;

	if actionName == "ADSelectTargetMouseWheel" and g_inputBinding:getShowMouseCursor() then
		AutoDrive:InputHandling(self, "input_nextTarget");
	end;

	if actionName == "ADSelectPreviousTargetMouseWheel" and g_inputBinding:getShowMouseCursor() then
		AutoDrive:InputHandling(self, "input_previousTarget");
	end;
	
	if actionName == "ADActivateDebug" then 
		AutoDrive:InputHandling(self, "input_debug");			
	end; 
	
	if actionName == "ADDebugShowClosest"  then 
		AutoDrive:InputHandling(self, "input_showNeighbor");			
	end; 
	
	if actionName == "ADDebugSelectNeighbor" then 
		AutoDrive:InputHandling(self, "input_showClosest");			
	end; 
	if actionName == "ADDebugCreateConnection" then 
		AutoDrive:InputHandling(self, "input_toggleConnection");			
	end; 
	if actionName == "ADDebugChangeNeighbor" then 
		AutoDrive:InputHandling(self, "input_nextNeighbor");			
	end; 
	if actionName == "ADDebugCreateMapMarker" then 
		AutoDrive:InputHandling(self, "input_createMapMarker");			
	end; 
	if actionName == "ADRenameMapMarker" then 
		AutoDrive:InputHandling(self, "input_renameMapMarker");			
	end; 
	
	if actionName == "AD_Speed_up" then 
		AutoDrive:InputHandling(self, "input_increaseSpeed");			
	end;
	
	if actionName == "AD_Speed_down" then 
		AutoDrive:InputHandling(self, "input_decreaseSpeed");			
	end;
	
	if actionName == "ADToggleHud" then 
		AutoDrive:InputHandling(self, "input_toggleHud");			
	end;

	if actionName == "ADToggleMouse" then 
		AutoDrive:InputHandling(self, "input_toggleMouse");			
	end;

	if actionName == "ADDebugDeleteWayPoint" then 
		AutoDrive:InputHandling(self, "input_removeWaypoint");
	end;
	if actionName == "AD_export_routes" then
		AutoDrive:InputHandling(self, "input_exportRoutes");
	end;
	if actionName == "AD_import_routes" then
		AutoDrive:InputHandling(self, "input_importRoutes");
	end;
	if actionName == "ADDebugForceUpdate" then
		AutoDrive:InputHandling(self, "input_recalculate");
	end;	
	if actionName == "AD_upload_routes" then
		AutoDrive:InputHandling(self, "input_uploadRoutes");
	end;
	if actionName == "ADDebugDeleteDestination" then
		AutoDrive:InputHandling(self, "input_removeDestination");
	end;
	if actionName == "ADSelectNextFillType" then
		AutoDrive:InputHandling(self, "input_nextFillType");
	end;
	if actionName == "ADSelectPreviousFillType" then
		AutoDrive:InputHandling(self, "input_previousFillType");
	end;
	if actionName == "ADOpenGUI" then			
		AutoDrive:InputHandling(self, "input_openGUI");
	end;
	if actionName == "ADCallDriver" then			
		AutoDrive:InputHandling(self, "input_callDriver");
	end;
	if actionName == "ADGoToVehicle" then			
		AutoDrive:InputHandling(self, "input_goToVehicle");
	end;
	if actionName == 'ADNameDriver' then
		AutoDrive:InputHandling(self, 'input_nameDriver');
	end;	
	if actionName == 'ADIncLoopCounter' then
		AutoDrive:InputHandling(self, 'input_incLoopCounter');
	end;
end;

function AutoDrive:InputHandling(vehicle, input)
	--print("AutoDrive InputHandling.." .. input);
	vehicle.ad.currentInput = input;
	if vehicle.ad.currentInput == nil then
		return;
	end;

	if g_server == nil then
		AutoDrive:InputHandlingClientOnly(vehicle, input)	
	end;

	AutoDrive:InputHandlingClientAndServer(vehicle, input)	

	if g_server == nil then
		if vehicle.ad.currentInput ~= nil then
			AutoDriveUpdateEvent:sendEvent(vehicle);
		end;
		return;
	end;		

	AutoDrive:InputHandlingServerOnly(vehicle, input)

	vehicle.ad.currentInput = "";
end;

function AutoDrive:InputHandlingClientOnly(vehicle, input)
	if input == "input_uploadRoutes" then
		if vehicle.ad.createMapPoints == false then
			return;
		end;
		local user = g_currentMission.userManager:getUserByUserId(g_currentMission.playerUserId);
		if user:getIsMasterUser() then
			print("User is admin and allowed to upload course");
			AutoDrive.playerSendsMapToServer = true;
			AutoDrive.requestedWaypointCount = 1;
		else
			print("User is no admin and is not allowed to upload course");
		end;
	end;	

	if input == "input_recalculate" then --make sure the hud button shows active recalculation when server is busy
		AutoDrive.Recalculation.continue = true;
	end;	
end

function AutoDrive:InputHandlingClientAndServer(vehicle, input)
	if input == "input_createMapMarker" and (g_dedicatedServerInfo == nil) then
		if vehicle.ad.createMapPoints == false then
			return;
		end;
		if AutoDrive.mapWayPoints[AutoDrive:findClosestWayPoint(vehicle)] == nil then
			return;
		end;		
		AutoDrive.renameCurrentMapMarker = false;
		AutoDrive:onOpenEnterTargetName();	 --the workaround to prevent the function 'onEnterPressed()' to be called right away when showing the gui have been moved to delayedCallBacks
		--AutoDrive:inputCreateMapMarker(vehicle);
	end;

	if input == "input_renameMapMarker" and (g_dedicatedServerInfo == nil) then
		if vehicle.ad.createMapPoints == false then
			return;
		end;		
		AutoDrive.renameCurrentMapMarker = true;
		AutoDrive:onOpenEnterTargetName();	 --the workaround to prevent the function 'onEnterPressed()' to be called right away when showing the gui have been moved to delayedCallBacks
	end;

	if input == "input_start_stop" then
		if AutoDrive.mapWayPoints == nil or AutoDrive.mapWayPoints[1] == nil or vehicle.ad.targetSelected == -1 then
			return;
		end;
		if AutoDrive:isActive(vehicle) then
			vehicle.ad.isStoppingWithError = true;
			AutoDrive:disableAutoDriveFunctions(vehicle)
			--AutoDrive:stopAD(vehicle, true);
		else
			AutoDrive:startAD(vehicle);
		end;
	end;

	if input == "input_exportRoutes" then
		if vehicle.ad.createMapPoints == false or AutoDrive.requestedWaypoints == true then
			return;
		end;
		AutoDrive:ExportRoutes();
	end;

	if input == "input_importRoutes" then
		if vehicle.ad.createMapPoints == false then
			return;
		end;
		AutoDrive:ImportRoutes();
	end;
	
	if input == "input_toggleHud" and vehicle == g_currentMission.controlledVehicle then
		AutoDrive.Hud:toggleHud(vehicle);				
	end;
	
	if input == "input_toggleMouse" and vehicle == g_currentMission.controlledVehicle then
		g_inputBinding:setShowMouseCursor(not g_inputBinding:getShowMouseCursor());
	end;
	
	if input == "input_openGUI" and vehicle == g_currentMission.controlledVehicle then
		AutoDrive:onOpenSettings();
	end;

	if input == "input_nameDriver" then
		AutoDrive:onOpenEnterDriverName();
	end;	

	if input == "input_goToVehicle" then
		AutoDrive:inputSwitchToArrivedVehicle();
	end;

	if input == "input_incLoopCounter" then
		vehicle.ad.loopCounterSelected = (vehicle.ad.loopCounterSelected + 1) % 10;
	end;

	if input == "input_decLoopCounter" then
		if vehicle.ad.loopCounterSelected == 0 then
			vehicle.ad.loopCounterSelected = 9;
		else			
			vehicle.ad.loopCounterSelected = (vehicle.ad.loopCounterSelected - 1) % 10;
		end;
	end;		
end;

function AutoDrive:InputHandlingServerOnly(vehicle, input)	
	if input == "input_silomode" then
		AutoDrive:inputSiloMode(vehicle, 1);
	end;

	if input == "input_previousMode" then
		AutoDrive:inputSiloMode(vehicle, -1);
	end;

	if input == "input_record" then
		if vehicle.ad.createMapPoints == false or AutoDrive.requestedWaypoints == true then
			return;
		end;
		AutoDrive:inputRecord(vehicle, false)
	end;

	if input == "input_record_dual" then
		if vehicle.ad.createMapPoints == false or AutoDrive.requestedWaypoints == true then
			return;
		end;
		AutoDrive:inputRecord(vehicle, true)
	end;
	
	if input == "input_nextTarget" then
		AutoDrive:inputNextTarget(vehicle)
	end;

	if input == "input_previousTarget" then
		AutoDrive:inputPreviousTarget(vehicle)
	end;

	if input == "input_debug"  then
		if vehicle.ad.createMapPoints == false then
			vehicle.ad.createMapPoints = true;
		else
			vehicle.ad.createMapPoints = false;
		end;
	end;
	
	if input == "input_displayMapPoints"  then
		vehicle.ad.displayMapPoints = not vehicle.ad.displayMapPoints;
	end;

	if input == "input_showClosest" then
		AutoDrive:inputShowClosest(vehicle);
	end;

	if input == "input_showNeighbor" then
		AutoDrive:inputShowNeighbors(vehicle)		
	end;

	if input == "input_toggleConnection" then
		if vehicle.ad.createMapPoints == false or AutoDrive.requestedWaypoints == true then
			return;
		end;
		local closest = AutoDrive:findClosestWayPoint(vehicle);
		AutoDrive:toggleConnectionBetween(AutoDrive.mapWayPoints[closest], vehicle.ad.iteratedDebugPoints[vehicle.ad.selectedDebugPoint]);
	end;

	if input == "input_nextNeighbor" then
		if AutoDrive.requestedWaypoints == true then
			return;
		end;
		AutoDrive:nextSelectedDebugPoint(vehicle, 1);
	end;
	
	if input == "input_previousNeighbor" then
		if AutoDrive.requestedWaypoints == true then
			return;
		end;
		AutoDrive:nextSelectedDebugPoint(vehicle, -1);
	end;

	if input == "input_increaseSpeed" then
		if vehicle.ad.targetSpeed < 100 then
			vehicle.ad.targetSpeed = vehicle.ad.targetSpeed + 1;
		end;
		AutoDrive.lastSetSpeed = vehicle.ad.targetSpeed;
	end;

	if input == "input_decreaseSpeed" then
		if vehicle.ad.targetSpeed > 2 then
			vehicle.ad.targetSpeed = vehicle.ad.targetSpeed - 1;
		end;
		AutoDrive.lastSetSpeed = vehicle.ad.targetSpeed;
	end;	

	if input == "input_removeWaypoint" then
		if vehicle.ad.createMapPoints == false or AutoDrive.requestedWaypoints == true then
			return;
		end;
		if vehicle.ad.showClosestPoint == true and AutoDrive.mapWayPoints[1] ~= nil then
			local closest = AutoDrive:findClosestWayPoint(vehicle)
			AutoDrive:removeMapWayPoint( AutoDrive.mapWayPoints[closest] );
		end;

	end;

	if input == "input_removeDestination" then
		if vehicle.ad.createMapPoints == false or AutoDrive.requestedWaypoints == true then
			return;
		end;
		if vehicle.ad.showClosestPoint == true and AutoDrive.mapWayPoints[1] ~= nil then
			local closest = AutoDrive:findClosestWayPoint(vehicle)
			AutoDrive:removeMapMarker( AutoDrive.mapWayPoints[closest] );
		end;
	end;

	if input == "input_recalculate" then
		if AutoDrive.requestedWaypoints == true then
			return;
		end;
		AutoDrive:ContiniousRecalculation();
	end;	

	if input == "input_nextTarget_Unload" then
		if  AutoDrive.mapMarker[1] ~= nil and AutoDrive.mapWayPoints[1] ~= nil then
			if vehicle.ad.mapMarkerSelected_Unload == -1 then
				vehicle.ad.mapMarkerSelected_Unload = 1

				vehicle.ad.targetSelected_Unload = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].id;

				vehicle.ad.nameOfSelectedTarget_Unload = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].name;
			else
				vehicle.ad.mapMarkerSelected_Unload = vehicle.ad.mapMarkerSelected_Unload + 1;
				if vehicle.ad.mapMarkerSelected_Unload > AutoDrive.mapMarkerCounter then
					vehicle.ad.mapMarkerSelected_Unload = 1;
				end;
				vehicle.ad.targetSelected_Unload = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].id;
				vehicle.ad.nameOfSelectedTarget_Unload = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].name;
			end;
		end;

	end;

	if input == "input_previousTarget_Unload" then
		if AutoDrive.mapMarker[1] ~= nil and AutoDrive.mapWayPoints[1] ~= nil then
			if vehicle.ad.mapMarkerSelected_Unload == -1 then
				vehicle.ad.mapMarkerSelected_Unload = AutoDrive.mapMarkerCounter;

				vehicle.ad.targetSelected_Unload = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].id;
				vehicle.ad.nameOfSelectedTarget_Unload = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].name;
			else
				vehicle.ad.mapMarkerSelected_Unload = vehicle.ad.mapMarkerSelected_Unload - 1;
				if vehicle.ad.mapMarkerSelected_Unload < 1 then
					vehicle.ad.mapMarkerSelected_Unload = AutoDrive.mapMarkerCounter;
				end;
				vehicle.ad.targetSelected_Unload = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].id;
				vehicle.ad.nameOfSelectedTarget_Unload = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].name;
			end;
		end;
	end;

	if input == "input_nextFillType" then		
		vehicle.ad.unloadFillTypeIndex = vehicle.ad.unloadFillTypeIndex + 1;
		if g_fillTypeManager:getFillTypeByIndex(vehicle.ad.unloadFillTypeIndex) == nil then
			vehicle.ad.unloadFillTypeIndex = 2;
		end;		
	end;

	if input == "input_previousFillType" then
		vehicle.ad.unloadFillTypeIndex = vehicle.ad.unloadFillTypeIndex - 1;
		if vehicle.ad.unloadFillTypeIndex <= 1 then
			while g_fillTypeManager:getFillTypeByIndex(vehicle.ad.unloadFillTypeIndex) ~= nil do 
				vehicle.ad.unloadFillTypeIndex = vehicle.ad.unloadFillTypeIndex + 1;
			end;
			vehicle.ad.unloadFillTypeIndex = vehicle.ad.unloadFillTypeIndex - 1;
		end;
	end;

	if input == "input_continue" then
		if vehicle.ad.isPaused == true then
			vehicle.ad.isPaused = false;
			if vehicle.ad.combineState == AutoDrive.WAIT_FOR_COMBINE then
				if getDistanceToTargetPosition(vehicle) < 10 then
					local closest = AutoDrive:findClosestWayPoint(vehicle);
					vehicle.ad.wayPoints = AutoDrive:FastShortestPath(AutoDrive.mapWayPoints, closest, AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].name, AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected_Unload].id);
					vehicle.ad.wayPointsChanged = true;
					vehicle.ad.currentWayPoint = 1;

					vehicle.ad.targetX = vehicle.ad.wayPoints[vehicle.ad.currentWayPoint].x;
					vehicle.ad.targetZ = vehicle.ad.wayPoints[vehicle.ad.currentWayPoint].z;
					if vehicle.ad.currentCombine ~= nil then
						vehicle.ad.currentCombine.ad.currentDriver = nil;
						vehicle.ad.currentCombine.ad.preCalledDriver = false;
						vehicle.ad.currentCombine.ad.driverOnTheWay = false;
						vehicle.ad.currentCombine = nil;
					end;
					AutoDrive.waitingUnloadDrivers[vehicle] = nil;
					vehicle.ad.combineState = AutoDrive.DRIVE_TO_UNLOAD_POS;
				else
					--Drive to startpos with path finder
					vehicle.ad.combineState = AutoDrive.DRIVE_TO_START_POS;
					AutoDrivePathFinder:startPathPlanningToStartPosition(vehicle, vehicle.ad.currentCombine);
					if vehicle.ad.currentCombine ~= nil then
						vehicle.ad.currentCombine.ad.currentDriver = nil;
						vehicle.ad.currentCombine.ad.preCalledDriver = false;
						vehicle.ad.currentCombine.ad.driverOnTheWay = false;
						vehicle.ad.currentCombine = nil;
					end;
				end;
			end;
		end;
	end;

	if input == "input_callDriver" then
		if vehicle.spec_pipe ~= nil and vehicle.spec_enterable ~= nil then
		--if vehicle.typeName == "combineDrivable" or vehicle.typeName == "combineCutterFruitPreparer" or vehicle.typeName == "pdlc_claasPack.combineDrivableCrawlers" then
			AutoDrive:callDriverToCombine(vehicle);
		end;
	end;
	
	if input == "input_setParkDestination" then
		if vehicle.ad.mapMarkerSelected ~= nil and vehicle.ad.mapMarkerSelected ~= -1 and vehicle.ad.mapMarkerSelected ~= 0 then
			vehicle.ad.parkDestination = vehicle.ad.mapMarkerSelected;
			
			AutoDrive:printMessage(vehicle, "" .. g_i18n:getText("AD_parkVehicle_selected") .. AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].name);
			AutoDrive.print.showMessageFor = 10000;
		end;
	end;

	if input == "input_parkVehicle" then
		if vehicle.ad.parkDestination ~= nil and vehicle.ad.parkDestination >= 1 and AutoDrive.mapMarker[vehicle.ad.parkDestination] ~= nil then
			vehicle.ad.mapMarkerSelected = vehicle.ad.parkDestination;
            vehicle.ad.targetSelected = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].id;
            vehicle.ad.nameOfSelectedTarget = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].name;
			if AutoDrive:isActive(vehicle) then
				AutoDrive:InputHandling(vehicle, "input_start_stop"); --disable if already active
			end;
			vehicle.ad.mode = 1;			
			AutoDrive:InputHandling(vehicle, "input_start_stop");	
			vehicle.ad.onRouteToPark = true;		
		else
			AutoDrive:printMessage(vehicle, g_i18n:getText("AD_parkVehicle_noPosSet"));
			AutoDrive.print.showMessageFor = 10000;
		end;
	end;
end;

function AutoDrive:inputSiloMode(vehicle, increase)
    vehicle.ad.mode = vehicle.ad.mode + increase;
    if (vehicle.ad.mode > AutoDrive.MODE_BGA) then
        vehicle.ad.mode = AutoDrive.MODE_DRIVETO;
	end;
	if (vehicle.ad.mode < AutoDrive.MODE_DRIVETO) then
		vehicle.ad.mode = AutoDrive.MODE_BGA
	end;
    AutoDrive:enableCurrentMode(vehicle);
end;

function AutoDrive:enableCurrentMode(vehicle)
    if vehicle.ad.mode == AutoDrive.MODE_DRIVETO then
        vehicle.ad.drivingForward = true;
    elseif vehicle.ad.mode == AutoDrive.MODE_DELIVERTO then
        vehicle.ad.drivingForward = true;
    elseif vehicle.ad.mode == AutoDrive.MODE_PICKUPANDDELIVER then
        vehicle.ad.drivingForward = true;  
    elseif vehicle.ad.mode == AutoDrive.MODE_UNLOAD then
        vehicle.ad.drivingForward = true;  
    elseif vehicle.ad.mode == AutoDrive.MODE_LOAD then
        vehicle.ad.drivingForward = true;  
    end;
end;

function AutoDrive:inputRecord(vehicle, dual)
    if vehicle.ad.creationMode == false then
        vehicle.ad.creationMode = true;
        vehicle.ad.creationModeDual = dual;
        vehicle.ad.currentWayPoint = 0;
        vehicle.ad.isActive = false;
		vehicle.ad.wayPoints = {};
		vehicle.ad.wayPointsChanged = true;
		
        AutoDrive:disableAutoDriveFunctions(vehicle)
    else
		vehicle.ad.creationMode = false;
		vehicle.ad.creationModeDual = false;
		
		if AutoDrive:getSetting("autoConnectEnd") then 
			if vehicle.ad.wayPoints ~= nil and ADTableLength(vehicle.ad.wayPoints) > 0 then
				local targetID = AutoDrive:findMatchingWayPointForVehicle(vehicle);
				if targetID ~= nil then
					local targetNode = AutoDrive.mapWayPoints[targetID];
					if targetNode ~= nil then
						targetNode.incoming[ADTableLength(targetNode.incoming)+1] = vehicle.ad.wayPoints[ADTableLength(vehicle.ad.wayPoints)].id;
						vehicle.ad.wayPoints[ADTableLength(vehicle.ad.wayPoints)].out[ADTableLength(vehicle.ad.wayPoints[ADTableLength(vehicle.ad.wayPoints)].out)+1] = targetNode.id;
						
						AutoDriveCourseEditEvent:sendEvent(targetNode);
					end;
				end;
			end;
		end;
    end;
end;

function AutoDrive:inputNextTarget(vehicle)
    if  AutoDrive.mapMarker[1] ~= nil and AutoDrive.mapWayPoints[1] ~= nil then
        if vehicle.ad.mapMarkerSelected == -1 then
            vehicle.ad.mapMarkerSelected = 1

            vehicle.ad.targetSelected = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].id;
            vehicle.ad.nameOfSelectedTarget = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].name;
        else
            vehicle.ad.mapMarkerSelected = vehicle.ad.mapMarkerSelected + 1;
            if vehicle.ad.mapMarkerSelected > AutoDrive.mapMarkerCounter then
                vehicle.ad.mapMarkerSelected = 1;
            end;
            vehicle.ad.targetSelected = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].id;
            vehicle.ad.nameOfSelectedTarget = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].name;            
        end;
    end;
end;

function AutoDrive:inputPreviousTarget(vehicle)
    if AutoDrive.mapMarker[1] ~= nil and AutoDrive.mapWayPoints[1] ~= nil then
        if vehicle.ad.mapMarkerSelected == -1 then
            vehicle.ad.mapMarkerSelected = AutoDrive.mapMarkerCounter;

            vehicle.ad.targetSelected = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].id;
            vehicle.ad.nameOfSelectedTarget = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].name;
        else
            vehicle.ad.mapMarkerSelected = vehicle.ad.mapMarkerSelected - 1;
            if vehicle.ad.mapMarkerSelected < 1 then
                vehicle.ad.mapMarkerSelected = AutoDrive.mapMarkerCounter;
            end;
            vehicle.ad.targetSelected = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].id;
            vehicle.ad.nameOfSelectedTarget = AutoDrive.mapMarker[vehicle.ad.mapMarkerSelected].name;
        end;
    end;
end;

function AutoDrive:toggleConnectionBetween(startNode, targetNode)
	if ((startNode == nil) or (targetNode == nil)) then
		return;
	end;
	local out_counter = 1;
    local exists = false;
    for i in pairs(startNode.out) do
        if exists == true then
            startNode.out[out_counter] = startNode.out[i];
            out_counter = out_counter +1;
        else
            if startNode.out[i] == targetNode.id then
                AutoDrive:MarkChanged()
                startNode.out[i] = nil;

                if AutoDrive.loadedMap ~= nil and AutoDrive.adXml ~= nil then
                    removeXMLProperty(AutoDrive.adXml, "AutoDrive." .. AutoDrive.loadedMap .. ".waypoints.wp".. startNode.id ..".out" .. i) ;
                end;

                local incomingExists = false;
                for _,i2 in pairs(targetNode.incoming) do
                    if i2 == startNode.id or incomingExists then
                        incomingExists = true;
                        if targetNode.incoming[_ + 1] ~= nil then
                            targetNode.incoming[_] = targetNode.incoming[_ + 1];
                            targetNode.incoming[_ + 1] = nil;
                        else
                            targetNode.incoming[_] = nil;
                        end;
                    end;
                end;

                exists = true;
            else
                out_counter = out_counter +1;
            end;
        end;
    end;
       
    if exists == false then
        startNode.out[out_counter] = targetNode.id;

        local incomingCounter = 1;
        for _,id in pairs(targetNode.incoming) do
            incomingCounter = incomingCounter + 1;
        end;
        targetNode.incoming[incomingCounter] = startNode.id;

        AutoDrive:MarkChanged()
    end;		

    AutoDriveCourseEditEvent:sendEvent(startNode);
    AutoDriveCourseEditEvent:sendEvent(targetNode);		
end;

function AutoDrive:nextSelectedDebugPoint(vehicle, increase)
	vehicle.ad.selectedDebugPoint = vehicle.ad.selectedDebugPoint + increase;
	if vehicle.ad.selectedDebugPoint < 1 then
		vehicle.ad.selectedDebugPoint = #vehicle.ad.iteratedDebugPoints;
	end;
    if vehicle.ad.iteratedDebugPoints[vehicle.ad.selectedDebugPoint] == nil then
        vehicle.ad.selectedDebugPoint = 1;
    end;
end;

function AutoDrive:finishCreatingMapMarker(vehicle)
	local closest = AutoDrive:findClosestWayPoint(vehicle);
	if closest ~= nil and closest ~= -1 and AutoDrive.mapWayPoints[closest] ~= nil then
		AutoDrive.mapMarkerCounter = AutoDrive.mapMarkerCounter + 1;
		local node = createTransformGroup(vehicle.ad.enteredMapMarkerString);
		setTranslation(node, AutoDrive.mapWayPoints[closest].x, AutoDrive.mapWayPoints[closest].y + 4 , AutoDrive.mapWayPoints[closest].z  );

		AutoDrive.mapMarker[AutoDrive.mapMarkerCounter] = {id=closest, name= vehicle.ad.enteredMapMarkerString, node=node, group="All"};
		vehicle.ad.creatingMapMarker = false;
		AutoDrive:MarkChanged();
		g_currentMission.isPlayerFrozen = false;
		vehicle.isBroken = false;    
		vehicle.ad.enteringMapMarker = false;
		g_inputBinding:revertContext(true);
		
		if g_server ~= nil then
			AutoDrive:broadCastUpdateToClients();
		else
			AutoDriveCreateMapMarkerEvent:sendEvent(vehicle, closest, vehicle.ad.enteredMapMarkerString);
		end;
		AutoDrive.Hud.lastUIScale = 0;
	end;
end;

function AutoDrive:inputShowNeighbors(vehicle)
	if vehicle.ad.showSelectedDebugPoint == false then
		-- Find all candidate points, no further away than 15 units from vehicle
		local x1,_,z1 = getWorldTranslation(vehicle.components[1].node);
		local candidateDebugPoints = {}
		for _,point in pairs(AutoDrive.mapWayPoints) do
			local distance = AutoDrive:getDistance(point.x,point.z,x1,z1);
			if distance < 15 then
				-- Add new element consisting of 'distance' (for sorting) and 'point'
				table.insert(candidateDebugPoints, {distance=distance, point=point})
			end
		end;
		-- If more than one point found, then arrange them from inner closest to further out
		if ADTableLength(candidateDebugPoints) > 1 then
			-- Sort by distance
			table.sort(candidateDebugPoints, function(left,right)
				return left.distance < right.distance
			end)
			-- Clear the array for any previous 'points'
			vehicle.ad.iteratedDebugPoints = {}
			-- Only need 'point' in the iteratedDebugPoints-array
			for _,elem in pairs(candidateDebugPoints) do
				table.insert(vehicle.ad.iteratedDebugPoints, elem.point)
			end
			-- Begin at the 2nd closest one (assuming 1st is 'ourself / the closest')
			vehicle.ad.selectedDebugPoint = 2

			-- But try to find a node with no IncomingRoads, and use that as starting from
			for idx,point in pairs(vehicle.ad.iteratedDebugPoints) do
				if ADTableLength(point.incoming) < 1 then
					vehicle.ad.selectedDebugPoint = idx
					break -- Since array was already sorted by distance, we dont need to search for another one
				end
			end

			vehicle.ad.showSelectedDebugPoint = true;
		end
	else
		vehicle.ad.showSelectedDebugPoint = false;
	end;
end;

function AutoDrive:inputShowClosest(vehicle)
    vehicle.ad.showClosestPoint = not vehicle.ad.showClosestPoint;
end;

--function AutoDrive:inputCreateMapMarker(vehicle)
--    if AutoDrive.mapWayPoints[AutoDrive:findClosestWayPoint(vehicle)] == nil then
--        return;
--    end;
--    if vehicle.ad.showClosestPoint == true then
--        if vehicle.ad.creatingMapMarker == false then
--            vehicle.ad.creatingMapMarker  = true;
--            vehicle.ad.enteringMapMarker = true;
--            vehicle.ad.enteredMapMarkerString = "" .. AutoDrive.mapWayPointsCounter;
--            g_currentMission.isPlayerFrozen = true;
--            vehicle.isBroken = true;				
--            g_inputBinding:setContext("AutoDrive.Input_MapMarker", true, false);
--       else
--            vehicle.ad.creatingMapMarker  = false;
 --           vehicle.ad.enteringMapMarker = false;
 --           vehicle.ad.enteredMapMarkerString = "";
 --           g_currentMission.isPlayerFrozen = false;
 --           vehicle.isBroken = false;
 --           g_inputBinding:revertContext(true);
 --       end;
 --   end;
--end;

function AutoDrive:inputSwitchToArrivedVehicle()
	if AutoDrive.print.referencedVehicle ~= nil then
		g_currentMission:requestToEnterVehicle(AutoDrive.print.referencedVehicle);
	end;
end;