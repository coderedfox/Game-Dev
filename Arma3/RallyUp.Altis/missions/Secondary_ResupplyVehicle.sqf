
/*
	Author: CodeRedFox
	Uses: Creates support mission
	Note: 
	Usage: [position player] execVM "missions\Secondary_ResupplyVehicle.sqf"
	Examples:

*/
if (RallyUp_debug == true) then {hint "Loaded SQF : Secondary_ResupplyVehicle.sqf";};
diag_log format ["RallyUpDiag Starting : Secondary_ResupplyVehicle.sqf | %1",_this select 0];
if (!isServer) exitwith {};
	
	// Variables
		_currentLocation = getMarkerPos "respawn_West";				
		_Task_Status = "Canceled";	
		_waveamount = RallyUp_EnemyMultiplier + (ceil (random (count allplayers)));		
		_distance = 1000;
		_NewLocation = _currentLocation;	
		_SupplyHelo = '';
		
		_Random_HelicoptersTransport = [1,["Heli_Transport_"], [] ] call RallyUp_fnc_task_ArrayofCfg;
		_Random_TransportVehicles = [1,["Hatchback","MRAP","Offroad","Quadbike","SUV","Truck_F","Wheeled_APC"], [] ] call RallyUp_fnc_task_ArrayofCfg;
				
		
	// Find Tasking Location
		_TaskLocation = [_currentLocation,RallyUp_minDistance,RallyUp_maxDistance,RallyUp_LocationsPoints,5] call RallyUp_fnc_position_Locations;

	// Create Helicopter
		_SpawnPosition = [_currentLocation, 2000, (random 360)] call BIS_fnc_relPos;
		_DeSpawnPosition = [_currentLocation, 2000, (random 360)] call BIS_fnc_relPos;
		
		_supplyHelogroup = createGroup (RallyUpBluFor select 0);
	
		_pickedvehicletype = (_Random_HelicoptersTransport select floor random count _Random_HelicoptersTransport);
		_VehicleDropArray = _Random_TransportVehicles select floor random count _Random_TransportVehicles;
		
		_SupplyHelo = [_SpawnPosition, (random 360), _pickedvehicletype,_supplyHelogroup] call bis_fnc_spawnvehicle;
		_SupplyHeloVeh = _supplyHelo select 0;
		_Picked_VehicleDrop = _VehicleDropArray createVehicle getPos _SupplyHeloVeh;
		_SupplyHeloVeh setSlingLoad _Picked_VehicleDrop;
		sleep 1;
		if !( _SupplyHeloVeh canSlingLoad _Picked_VehicleDrop) exitWith {
			{ _SupplyHeloVeh deleteVehicleCrew _x } forEach units _SupplyHeloVeh;
			deleteVehicle _SupplyHeloVeh;
			deleteVehicle _Picked_VehicleDrop;
				true						
		};		
		
		_chopperWaypoint_1 = (_supplyHelo select 2) addWaypoint [_currentLocation,1000];
		_chopperWaypoint_2 = (_supplyHelo select 2) addWaypoint [_DeSpawnPosition, 500];
		
		_chopperWaypoint_1 setWaypointBehaviour "CARELESS";	
		_chopperWaypoint_2 setWaypointBehaviour "CARELESS";
		
		_chopperWaypoint_1 setWaypointType "UNHOOK";		
		_chopperWaypoint_2 setWaypointType "MOVE";
		_chopperWaypoint_2 setWaypointStatements ["true", "
			{deleteVehicle vehicle _x} forEach thislist;
			{deleteVehicle _x} forEach thislist;
			deleteGroup (group this);
		"];	
			
	// Diary
	
		_taskInformation = [_SupplyHelo select 0] call RallyUp_fnc_text_GetInfo;
		_taskInformationVeh = [_Picked_VehicleDrop] call RallyUp_fnc_text_GetInfo;
		_taskTitle = "Optional Vehicle Resupply";
		_taskPosition = waypointPosition _chopperWaypoint_1;
		_taskType = "Support";
		_taskDescription = str formatText ["
			<img image='\A3\UI_F_MP_Mark\Data\Tasks\Types\Support_ca.paa' width='50px'/>
			<img image='%2' width='100px'/>
			<img image='%3' width='100px'/>
			<br/>
			<br/>O P S E C : -----------------
			<br/>
			<br/>	Stand by, a %1 in on route to a drop location.
			<br/>			
			<br/>
			<br/>T I P S : -----------------
			<br/>	The task will start where ever the cargo lands.
		",_taskInformation select 1,_taskInformation select 2,_taskInformationVeh select 2];	
		_Task_Name = str formatText ["%1%2",_taskType,time];
		_Task_Mission = [(RallyUpBluFor select 0),_Task_Name,[_taskDescription,_taskTitle,_taskType],[_taskPosition select 0,_taskPosition select 1,2],0,1,true,_taskType] call BIS_fnc_taskCreate;
	

	
	
	//{playsound "Supply_Inbound"} foreach Allplayers;
	["Supply_Inbound","playSound",true] call BIS_fnc_MP;
	// [{playSound "Supply_Inbound";}, "BIS_fnc_spawn",true] call BIS_fnc_MP;
	
		
	// Task Event
		waituntil {
			sleep 5;
						
			_distance = ([AllPlayers] call RallyUp_fnc_Position_3dCenter) distance (getpos _Picked_VehicleDrop);
			if (_distance < 50) exitWith {_Task_Status = "Succeeded";true};
			if ((!alive _SupplyHeloVeh) or (!alive _Picked_VehicleDrop)) then {
				{deleteVehicle vehicle _x} forEach (units _supplyHelogroup);
				{deleteVehicle _x} forEach (units _supplyHelogroup);
				deleteGroup _supplyHelogroup;		
				_Task_Status = "Failed";
				deletevehicle _Picked_VehicleDrop;
				true
			};
			
			if ((surfaceIsWater (getpos _Picked_VehicleDrop)) or (_distance > RallyUp_maxDistance)) exitWith {
				_Task_Status = "Canceled";
				deletevehicle _Picked_VehicleDrop;
				true
			};
			false
		};

		
// Task End Events
	//[_Task_Mission,_Task_Status] call BIS_fnc_taskSetState; // _Task_Status = "Succeeded","Failed","Canceled"
if(true) exitWith {[_Task_Mission] call BIS_fnc_deleteTask};

