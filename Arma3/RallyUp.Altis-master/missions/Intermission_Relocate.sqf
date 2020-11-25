
/*
	Author: CodeRedFox
	Uses: Relocate mission to move all players to another part of the map
	Note: 
	Usage: [position] execVM "missions\Intermission_Relocate.sqf"
	Examples:[position player] execVM "missions\Intermission_Relocate.sqf"
	
*/ diag_log format ["RallyUpDiag Starting : Intermission_Relocate.sqf | %1 | %2",time,serverTime];
if (!isServer) exitwith {};

// Variables
	_Position = _this select 0;
	_Task_Status = "Canceled";
	_countdown = time+RallyUp_TimeOutSec;
	
	_mapdistance = (RallyUp_WorldSizeCenter select 1);
	
	_minDistance = (RallyUp_WorldSizeCenter select 1)/3;
	_maxDistance = (RallyUp_WorldSizeCenter select 1);	

	_TransportationHelogroup = createGroup (RallyUpBluFor select 0);
	
// Tasking Locations
	
	[(RallyUpOpFor select 0),100] spawn RallyUp_fnc_task_CleanUp;
	sleep 10;

	_Task_LocationPickup = [_Position,0,500,RallyUp_LocationsPoints,10] call RallyUp_fnc_position_Locations;
		if (_Task_LocationPickup distance2d _Position > _maxDistance) exitWith {diag_log ["RallyUpDiag : Mission outside of _maxDistance"];true};	// Will cancel if the task to to far away	
		_Task_LocationName = [_Task_LocationPickup] call RallyUp_fnc_position_LocationsName;
	_Task_LocationDrop = [_Position,_minDistance,_maxDistance,RallyUp_LocationsPoints,10] call RallyUp_fnc_position_Locations;
		_Task_LocationNameDrop = [_Task_LocationDrop] call RallyUp_fnc_position_LocationsName;
	
	_SpawnPosition = [_Task_LocationPickup, 2500, (random 360)] call BIS_fnc_relPos;

	
// Starting Friendlies
	_pickedvehicletype = (((RallyUp_Groups_FriendlyHelicopters select 2) select 1) select floor random count ((RallyUp_Groups_FriendlyHelicopters select 2) select 1));
	_TransportationHelo = [_SpawnPosition, (random 360), _pickedvehicletype,_TransportationHelogroup] call bis_fnc_spawnvehicle;
	_TransportationHeloVeh =  _TransportationHelo select 0;
	_TransportationHeloGroup =  _TransportationHelo select 2;
	[_TransportationHeloVeh] spawn RallyUp_fnc_task_OpenDoors;

	
	
	_chopperWaypoint_01 = _TransportationHeloGroup addWaypoint [_Task_LocationPickup,0];
	_chopperWaypoint_01 setWaypointType "Move";
	_chopperWaypoint_01 setWaypointBehaviour "CARELESS";
	_chopperWaypoint_01 setWaypointStatements ["true", "
		{(vehicle _x) land 'LAND'} foreach thisList;
	"];
		

// Diary
	_taskInformation = [_TransportationHeloVeh] call RallyUp_fnc_text_GetInfo;
	
	
	_taskTitle = "Transportation";
	_taskPosition = _Task_LocationPickup;
	_taskType = "Support";
	_taskDescription = str formatText ["
		<img image='\A3\UI_F_MP_Mark\Data\Tasks\Types\Support_ca.paa' width='50px'/>
		<img image='%3' width='50px'/>
		<br/>
		<br/>O P S E C : -----------------
		<br/>
		<br/>	The emeny have been wiped out. All groups move to and wait for transportation near %1.
		<br/>	The next AO will be near %4
		<br/>
		<br/>
		<br/>O B J E C T I V E : -----------------
		<br/>
		<br/>	- All groups board the %2
		<br/>
		<br/>
		<br/>TIPS:
		<br/>	Make sure all your team mates are on as the chopper will take off without AI
		<br/>			
	",_Task_LocationName,_taskInformation select 1,_taskInformation select 3,_Task_LocationNameDrop];	
	
	_Task_Name = str formatText ["%1%2",_taskType,time];
	_Task_Mission = [(RallyUpBluFor select 0),_Task_Name,[_taskDescription,_taskTitle,_taskType],[_taskPosition select 0,_taskPosition select 1,5],1,1,true,_taskType] call BIS_fnc_taskCreate;

sleep 5;
	
	{playsound "Transport_Inbound"} foreach Allplayers;
	
// Task Event, Normally a waituntil loop
	waituntil {	
		sleep 15;

		_CountAllunits = {units group _x} foreach allplayers;
		_AllAlive = {alive _x} count _CountAllunits;
		_Allboarded = {(_x in _TransportationHeloVeh) and (alive _x)} count _CountAllunits;		
		
		if ((_AllAlive == _Allboarded) or (count _CountAllunits==0) or (!alive _TransportationHeloVeh) or ( time > _countdown)) exitwith {true};			
			false
	};
	
	[_Task_Mission,_Task_LocationDrop] call BIS_fnc_taskSetDestination;

	_chopperWaypoint_02 = _TransportationHeloGroup addWaypoint [_Task_LocationDrop,0];
	_chopperWaypoint_02 setWaypointType "UNLOAD";
	_chopperWaypoint_02 setWaypointBehaviour "CARELESS";
	_chopperWaypoint_02 setWaypointStatements ["true", "
		{(vehicle _x) land 'LAND'} foreach thisList;
		{
			{
				unassignVehicle _x;
				[_x] ordergetin false;
			} forEach (assignedcargo vehicle _x);
		} forEach thisList;
	"];
	
	waituntil {	
		sleep 5;
		_CountAllunits = {units group _x} foreach allplayers;
		_Allboarded = {(_x in _TransportationHeloVeh) && (alive _x)} count _CountAllunits;

		if ( _Allboarded == 0) exitwith {
			{playsound "Transport_accomplished"} foreach Allplayers;_Task_Status = "Succeeded";
			[(RallyUpBluFor select 0),_spawnUpdate] call RallyUp_fnc_task_UpdateSpawns;
			true;
		};
		if ( time > _countdown) exitWith {_Task_Status = "Canceled";true};
		if (!alive _TransportationHeloVeh) exitWith {_Task_Status = "Failed";true};
			false
	};	
	
	
	
	{
		sleep 2;
		moveOut _x;
	} forEach _CountAllunits;
		
	_DeSpawnPosition = [_Task_LocationDrop, 2500, (random 360)] call BIS_fnc_relPos;

	_chopperWaypoint_03 = _TransportationHeloGroup addWaypoint [_DeSpawnPosition, 500];
	_chopperWaypoint_03 setWaypointType "MOVE";
	_chopperWaypoint_03 setWaypointStatements ["true", "
		{deleteVehicle vehicle _x} forEach thislist;
		{deleteVehicle _x} forEach thislist;
		deleteGroup (group this);
	"];
	
	

// Task End Events
	[_Task_Mission,_Task_Status] call BIS_fnc_taskSetState; // _Task_Status =  "Succeeded","Failed","Canceled"
	
if(true) exitWith {};
