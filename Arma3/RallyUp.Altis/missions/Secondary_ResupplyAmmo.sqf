
/*
	Author: CodeRedFox
	Uses: Creates support mission
	Note: 
	Usage: [position player] execVM "missions\Secondary_ResupplyAmmo.sqf"
	Examples:

*/
if (RallyUp_debug == true) then {hint "Loaded SQF : Secondary_ResupplyAmmo.sqf";};

diag_log format ["RallyUpDiag Starting : Secondary_Support.sqf | %1",_this select 0];

if (!isServer) exitwith {};
	
	// Variables
		_currentLocation = getMarkerPos "respawn_West";
		_waveamount = RallyUp_EnemyMultiplier + (ceil (random (count allplayers)));		
		_distance = 1000;
		_NewLocation = _currentLocation;
		
		_Random_HelicoptersTransport = [RallyUp_FriendlySide,["Heli_Transport_"], "" ] call RallyUp_fnc_task_ArrayofCfg;
		
	// Find Tasking Location
		_TaskLocation = [_currentLocation,RallyUp_minDistance,RallyUp_maxDistance,RallyUp_LocationsPoints,5] call RallyUp_fnc_position_Locations; 

	// Create Helicopter
		_SpawnPosition = [_currentLocation, 3000, (random 360)] call BIS_fnc_relPos;
		_DeSpawnPosition = [_currentLocation, 3000, (random 360)] call BIS_fnc_relPos;
		
		
		
		_supplyHelogroup = createGroup (RallyUpBluFor select 0);
		_pickedvehicletype = (_Random_HelicoptersTransport select floor random count _Random_HelicoptersTransport);
		_supplyHelo = [_SpawnPosition, (random 360), _pickedvehicletype,_supplyHelogroup] call bis_fnc_spawnvehicle;
		_SupplyHeloVeh = _supplyHelo select 0;

		_AmmoCrateArray = RallyUp_AmmoCrates select floor random count RallyUp_AmmoCrates;
		_Picked_AmmoCrate = _AmmoCrateArray createVehicle getPos _SupplyHeloVeh;
		_SupplyHeloVeh setSlingLoad _Picked_AmmoCrate;
		["AmmoboxInit",[_Picked_AmmoCrate,true]] call BIS_fnc_arsenal;
		

		_chopperWaypoint_1 = (_supplyHelo select 2) addWaypoint [_currentLocation,1000];
		_chopperWaypoint_2 = (_supplyHelo select 2) addWaypoint [_DeSpawnPosition, 500];
		
		_chopperWaypoint_1 setWaypointBehaviour "CARELESS";	
		_chopperWaypoint_2 setWaypointBehaviour "CARELESS";
		
		_chopperWaypoint_1 setWaypointType "UNHOOK";		
		_chopperWaypoint_2 setWaypointType "MOVE";
		
		_chopperWaypoint_1 setWaypointStatements ["true", "
			{playsound 'Supply_Dropped'} foreach Allplayers;
			_ammocrateLight = 'Chemlight_green' createVehicle (getPos _Picked_AmmoCrate);
			_ammocrateSmoke = 'SmokeShellGreen' createVehicle (getPos _Picked_AmmoCrate);
						
			"];
		
		_chopperWaypoint_2 setWaypointStatements ["true", "
			{deleteVehicle vehicle _x} forEach thislist;
			{deleteVehicle _x} forEach thislist;
			deleteGroup (group this);
		"];			
		
	// Diary
	
		_taskInformation = [_SupplyHeloVeh] call RallyUp_fnc_text_GetInfo;
		_taskStatus = "Canceled";
		_taskTitle = "Optional Ammo Resupply";
		_taskPosition = _currentLocation;
		_taskType = "container";
		_taskDescription = str formatText ["
			<img image='\A3\UI_F_MP_Mark\Data\Tasks\Types\Support_ca.paa' width='50px'/>
			<img image='%2' width='100px'/>
			<br/>
			<br/>O P S E C : -----------------
			<br/>
			<br/>	Stand by, a %1 in on route to a drop location.
			<br/>			
			<br/>
			<br/>T I P S : -----------------
			<br/>	The task will start where ever the cargo lands.
		",_taskInformation select 1,_taskInformation select 2];	
		_Task_Name = str formatText ["%1%2",_taskType,time];
		_Task_Mission = [(RallyUpBluFor select 0),_Task_Name,[_taskDescription,_taskTitle,_taskType],[_taskPosition select 0,_taskPosition select 1,2],0,1,true,_taskType] call BIS_fnc_taskCreate;
	

	

	{playsound "Supply_Inbound"} foreach Allplayers;
	// ["Supply_Inbound","playSound",true] call BIS_fnc_MP;
	// [{playSound "Supply_Inbound";}, "BIS_fnc_spawn",true] call BIS_fnc_MP;	
	
	// Task Event

		[_Task_Name,waypointPosition _chopperWaypoint_1] call BIS_fnc_taskSetDestination;
		
		_isDropped = False;
		
		waituntil {
			sleep 5;					
			
			
			
			_distance = ([allPlayers] call RallyUp_fnc_Position_3dCenter) distance (getpos _Picked_AmmoCrate);
			if (_distance < 50) exitWith {_taskStatus = "Succeeded";true};			

			if ((damage _SupplyHeloVeh > 0.9 ) and (currentWaypoint _supplyHelogroup == 1)) exitWith {
				{deleteVehicle vehicle _x} forEach (units _supplyHelogroup);
				{deleteVehicle _x} forEach (units _supplyHelogroup);
				deleteGroup _supplyHelogroup;
				deletevehicle _SupplyHeloVeh;
				if (getPosATL _Picked_AmmoCrate select 2 > 10) then {deletevehicle _Picked_AmmoCrate;};
		
				_taskStatus = "Failed";
					true
			};
				
				false
		};
		
// Task End Events
[_Task_Mission,_taskStatus] call BIS_fnc_taskSetState;
sleep 5;
if(true) exitWith {[_Task_Mission] call BIS_fnc_deleteTask};
