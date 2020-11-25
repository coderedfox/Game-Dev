
/*
	Author: CodeRedFox
	Uses: Main Game Call
	Note: !!!  DO NOT EDIT ANYTHING IN THIS FILE  !!!
	
*/

// Server & Client Settings	
	#include "RallyUp_Assets.hpp"	
	[] execVM "data\CfgLocations.sqf";
	//[] spawn RallyUp_fnc_ambient_weather;
	
	// Debugging
	if (RallyUp_debug) then {	[] spawn RallyUp_fnc_debug_Master; };	

	
	
// Server only Settings
	if (isServer) then {
	
		["Initialize"] call BIS_fnc_dynamicGroups;	
		_pickedSpot = [RallyUp_WorldSizeCenter,1000,RallyUp_WorldSize,RallyUp_LocationsLocal,10] call RallyUp_fnc_position_Locations; 
		
		[(RallyUpBluFor select 0),_pickedSpot] call RallyUp_fnc_task_UpdateSpawns;
		
		RallyUp_EnemyMultiplier = ["RallyUp_param_WAVENUMBER"] call BIS_fnc_getParamValue;
				

		//[] spawn RallyUp_fnc_ambient_EnemyGround;
		//[] spawn RallyUp_fnc_ambient_EnemyAir;		
		//[] execVM "missions\Tasking_Mission.sqf";	
		
		diag_log format ["RallyUp : RallyUp.sqf | %1",_this];
	};

// Client only Settings
	if (hasInterface) then {	
		[] call RallyUp_fnc_diary_RallyUpInfo;	
		
		// Revive loadout saves
		player addEventhandler ["killed",{[_this select 0, [_this select 0, "mySavedLoadout"]] call BIS_fnc_saveInventory}]; 
		player addEventhandler ["respawn",{[_this select 0,[_this select 0, "mySavedLoadout"]] call BIS_fnc_loadInventory}];
		
		// Group Assign
		["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;
			_squadName = ["Squade"] call RallyUp_fnc_text_RandomName;
			_GroupAssign = [nil, _squadName, false];	
			[ "RegisterGroup", [ group player, leader group player, _GroupAssign ] ] remoteExec [ "BIS_fnc_dynamicGroups", 2 ];
		_PlayerSquadName = (group player) setGroupIDGlobal [_squadName];
		
		player addBackpack "B_Respawn_TentDome_F";
		
		if (RallyUp_UISettings) then {[player] spawn RallyUp_fnc_ui_settings; };
		
		diag_log format ["RallyUp : RallyUp.sqf | Player : %1",player];

		
	};

	
	



	
