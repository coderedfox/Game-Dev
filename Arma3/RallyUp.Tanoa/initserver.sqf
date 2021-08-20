	// Degug
	//RallyUp_debug = true;	// Debug on or off
	//if (RallyUp_debug) then {	[] spawn RallyUp_fnc_debug_Master; };	
	

	
// --- STARTING GAME LOGIC	

	[] call RallyUp_fnc_game_RallyUp;


	["Initialize", [true]] call BIS_fnc_dynamicGroups; // Starts Dynamic Groups


	//[] spawn RallyUp_fnc_ambient_weather;	

	[] spawn RallyUp_fnc_ambient_Air;
		
	//if ( ["RallyUp_param_ambientAir"] call BIS_fnc_getParamValue == 1 ) then { [] spawn RallyUp_fnc_ambient_Air; };
	
	//if ( ["RallyUp_param_ambientGround"] call BIS_fnc_getParamValue == 1 ) then { [] spawn RallyUp_fnc_ambient_Ground; };
			
	[] execVM "missions\Tasking_Missions.sqf";	// Starts the missions
	
diag_log format ["RallyUp : RallyUp.sqf | HAS STARTED : %1 ---------------------------------------------------------------------------------------------------",serverTime];		
