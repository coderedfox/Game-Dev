
/*
	Author: CodeRedFox
	Uses: This picks the tasks for the game world
	Note: 
	Usage: [] execVM "missions\Tasking_Missions.sqf"
*/ diag_log format ["RallyUp : Tasking_Missions.sqf | %1",getMarkerPos "respawn_West"];
if (!isServer) exitwith {};

	sleep 5;
	
	_spawnUpdate = getMarkerPos "respawn_West";
	
	while {RallyUp_GameStatus} do {	
		sleep 10;
		// Pick Tasks
			_IntermissionStringText = str formatText ["Missions\Intermission_%1.sqf",(RallyUp_MissionsIntermission select floor random count RallyUp_MissionsIntermission)];
			_PrimaryStringText = str formatText ["Missions\Primary_%1.sqf",(RallyUp_MissionsPrimary select floor random count RallyUp_MissionsPrimary)];
			_SecondaryStringText = str formatText ["Missions\Secondary_%1.sqf",(RallyUp_MissionsSecondary select floor random count RallyUp_MissionsSecondary)];
		
		// Intermission Mission. Waits until completed
			_Launch_IntermissionMissions = [_spawnUpdate] execVM format["%1",_IntermissionStringText];
				waitUntil{sleep 5;scriptdone _Launch_IntermissionMissions};
				
			// Update Spawn
				_spawnUpdate = [AllPlayers] call RallyUp_fnc_Position_3dCenter;
				[(RallyUpBluFor select 0),_spawnUpdate] call RallyUp_fnc_task_UpdateSpawns;	
		
		// Primary and Secondary missions. Waits until Primary is completed
			_Launch_SecondaryMissions = [_spawnUpdate] execVM format["%1",_SecondaryStringText];
			sleep (RallyUp_TimeOutSec/20);
			_Launch_PrimaryMissions = [_spawnUpdate] execVM format["%1",_PrimaryStringText];
				waitUntil{sleep 5;scriptdone _Launch_PrimaryMissions};
		
			// Update Spawn
				_spawnUpdate = [AllPlayers] call RallyUp_fnc_Position_3dCenter;
				[(RallyUpBluFor select 0),_spawnUpdate] call RallyUp_fnc_task_UpdateSpawns;				
				[(RallyUpOpFor select 0),500] spawn RallyUp_fnc_task_CleanUp;
				
	};

if(true) exitWith {endMission "END1";};
