/*
	Author: CodeRedFox
	Uses: This is the collection of all the game assets that will be used.
	Note: To add/switch in your mod assets, enter it here under the correct class.
	Usage: [] call compile preprocessFileLineNumbers "RallyUp.sqf"; 
	
	Helpful Links: 
		GitHub : https://github.com/coderedfox/RallyUp.Altis
		BI ARMA 3 Unit and Vehicle list : https://community.bistudio.com/wiki/Arma_3_Assets/
		
	Array example :
		["classname"]
		["Group Name", ["class name"]]
		
	Array Returns Example :	
		RallyUp_Groups_EnemyInf : Returns the whole array all groups and classnames
		(RallyUp_Groups_EnemyInf select 0) : Returns "Insurgent Spotters"
		((RallyUp_Groups_EnemyInf select 0) select 1): Returns "O_G_Soldier_M_F"
		
*/

if ( !isServer) exitwith { diag_log format ["RallyUp : fn_game_rallyup.sqf | NOT SERVER %1",serverTime]; }; // Exit if not the server
diag_log format ["RallyUp : fn_game_rallyup.sqf | START %1",serverTime];

// ---------------------------------------------------------------------
// Variables
// ---------------------------------------------------------------------

	// Info about the world.
	RallyUp_GameStatus = true;  // DO NOT EDIT lets the mission know if its running
	RallyUp_TotalEnemyUnits = []; // DO NOT EDIT counts up total units

	RallyUp_WorldSize = getNumber (configfile >> "CfgWorlds" >> worldName >> "mapSize"); // auto Map size	
	RallyUp_WorldSizeCenter = [RallyUp_WorldSize / 2,RallyUp_WorldSize / 2,0]; // Auto center of map
	RallyUp_BuildingTypes = ["Building"];	// This should cover everything ["Building","house","Ruins","Church"];
	RallyUp_LocationsLocal = ["NameVillage","NameLocal"]; // Small Locations
	RallyUp_LocationsPopulace = ["NameCity","NameCityCapital","NameVillage"]; // All city's and Villages
	RallyUp_LocationsPoints = ["Hill","NameMarine","Mount"]; // Non Populated areas
	RallyUp_AINVG = ["RallyUp_param_AINVG"] call BIS_fnc_getParamValue; // Should AI have NVG?
	publicVariable "RallyUp_AINVG";

	RallyUp_EnemyMultiplier = ["RallyUp_param_WAVENUMBER"] call BIS_fnc_getParamValue; 	// Params to multply enemy
	RallyUp_minDist = ["RallyUp_param_MINDISTANCE"] call BIS_fnc_getParamValue; // Missions spawn minumum distance
	RallyUp_maxDist = ["RallyUp_param_MAXDISTANCE"] call BIS_fnc_getParamValue; // Missions spawn max distance
	RallyUp_TimeOutSec = 7200; // Gloabal Mission timeout, default to 7200 or 2 hours to end missions

	RallyUp_Intel_Updated = false; //For use with Intel items Sets up as false first
	
	RallyUp_ColorHex = "#ffb400"; publicVariable "RallyUp_ColorHex"; // Coloring but not being used
	RallyUp_ColorRGBA = [1,0.706,0,1]; publicVariable "RallyUp_ColorRGBA"; // Coloring but not being used

	// Sides From Params
	RallyUp_param_PlayerSide = ["RallyUp_param_PlayerSide"] call BIS_fnc_getParamValue; // Player set friendly side
	RallyUp_param_BLUFORFactions = ["RallyUp_param_BLUFORFaction"] call BIS_fnc_getParamValue; // Player set BLURFOR faction
	RallyUp_param_OPFORFactions = ["RallyUp_param_OPFORFaction"] call BIS_fnc_getParamValue; // Player set OPFOR faction

	// Selects BLUFOR Factions
	switch ( RallyUp_param_BLUFORFactions ) do
	{
		case 0: { RallyUp_BLUFORFaction = "BLU_F" }; 		// NATO
		case 1: { RallyUp_BLUFORFaction = "BLU_G_F" }; 		// FIA
		case 2: { RallyUp_BLUFORFaction = "BLU_T_F" }; 		// Pacific NATO
		case 3: { RallyUp_BLUFORFaction = "BLU_CTRG_F" }; 	// Pacific CTRG
		case 4: { RallyUp_BLUFORFaction = "BLU_GEN_F" }; 	// Gendarmerie
		case 5: { RallyUp_BLUFORFaction = "BLU_W_F" }; 		// Woodland NATO
	};

	// Selects OPFOR Factions
	switch ( RallyUp_param_OPFORFactions ) do
	{
		case 0: { RallyUp_OPFORFaction = "OPF_F" }; 		// Iranian CSAT
		case 1: { RallyUp_OPFORFaction = "OPF_G_F" }; 		// FIA
		case 2: { RallyUp_OPFORFaction = "OPF_T_F" }; 		// Chinese CSAT
		case 3: { RallyUp_OPFORFaction = "OPF_R_F" }; 		// Spetznatz
	};

	// Sets Player picked side
	switch ( RallyUp_param_PlayerSide ) do
	{
		case 0: {
			RallyUp_Friend_Side = WEST;	RallyUp_Friend_Faction = RallyUp_BLUFORFaction;
			RallyUp_Enemy_Side = EAST; RallyUp_Enemy_Faction = RallyUp_OPFORFaction;
		};
		case 1 :{
			RallyUp_Friend_Side = EAST; RallyUp_Friend_Faction = RallyUp_OPFORFaction;
			RallyUp_Enemy_Side = WEST;	RallyUp_Enemy_Faction = RallyUp_BLUFORFaction;
		};
	};	

	// Selects Independent Factions
	RallyUp_GUER_Side = Independent; RallyUp_GUERFaction = "OPF_G_F";

	// Selects Civillian Factions
	RallyUp_CIV_Side = Civilian; RallyUp_CIVFaction = "CIV_F";

	diag_log format ["RallyUp : Sides and Factions | Friend %1 \ %2 | Enemy%3 \ %4", RallyUp_Friend_Side,	RallyUp_Friend_Faction,	RallyUp_Enemy_Side,	RallyUp_Enemy_Faction];

	// Creates and Updates Spawn Position
	RallyUp_Respawn_MRK = "respawn_" + str(RallyUp_Friend_Side);	
	_pickedSpot = [ [random RallyUp_WorldSize,random RallyUp_WorldSize],0,RallyUp_WorldSize,RallyUp_LocationsLocal,5] call RallyUp_fnc_position_Locations; 
	[RallyUp_Friend_Side,_pickedSpot] call RallyUp_fnc_task_UpdateSpawns; // Picks first spawn spot

	// ---------------------------------------------------------------------
	// Randomzied variables
	// ---------------------------------------------------------------------
	// USEAGE:	_var = [SIDE, Faction, ARRAY Types, ARRAY Excluded names , ARRAY Must Contain Attrib] call RallyUp_fnc_task_ArrayofCfg;
	// EXAMPLE: _var = [RallyUp_Friend_Side, RallyUp_Friend_Faction, ["_Soldier_"], ["_unarmed_"] , ["transportSoldier"]] call RallyUp_fnc_task_ArrayofCfg;

	// Randomize friendly and Vehicles	
	Random_FriendlyInf = [RallyUp_Friend_Side, RallyUp_Friend_Faction, "Men", ["Range","_unarmed_","pilot","_Survivor_","Parade","Crew","Competitor"], [] ] call RallyUp_fnc_task_ArrayofCfg;
		publicVariable "Random_FriendlyInf"; // allows clients to read data to spawn units
	Random_FriendlyVeh = [RallyUp_Friend_Side, RallyUp_Friend_Faction, "Car", [], [] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_FriendlyMech = [RallyUp_Friend_Side, RallyUp_Friend_Faction,  "Armored", [], [] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_FriendlyHeliTrans = [RallyUp_Friend_Side, RallyUp_Friend_Faction,  "Air", [], ["transportSoldier"] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_FriendlyHeli = [RallyUp_Friend_Side, RallyUp_Friend_Faction,  "Air", [], ["transportSoldier"] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_FriendlyJet = [RallyUp_Friend_Side, RallyUp_Friend_Faction,  "Air", ["Heli"], [] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_FriendlyBoats = [RallyUp_Friend_Side, RallyUp_Friend_Faction,  "Ship", [], [] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_FriendlyUAV = [RallyUp_Friend_Side, RallyUp_Friend_Faction,  "Autonomous", ["UGV","Ship","SAM","AAA","Radar","Medical"], [] ] call RallyUp_fnc_task_ArrayofCfg;

	// Randomize Enemy and Vehicles
	Random_EnemyInf = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction, "Men", ["Range","_unarmed_","pilot","survior","Parade","Crew","Competitor"], [] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_EnemyVeh = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction, "Car", [], [] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_EnemyMechTrans = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction,  "Armored", [], ["transportSoldier"] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_EnemyMech = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction,  "Armored", [], [] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_EnemyHeliTrans = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction,  "Air", [], ["transportSoldier"] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_EnemyHeli = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction,  "Air", [], ["transportSoldier"] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_EnemyJet = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction,  "Air", ["Heli"], [] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_EnemyPara = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction,  "Air", [], ["transportSoldier"] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_EnemyBoats = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction,  "Ship", [], [] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_EnemyUAV = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction,  "Autonomous", ["UGV","Ship","SAM","AAA","Radar","Medical"], [] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_EnemyStatics = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction,  "Static", [], [] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_EnemyMortars = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction,  "Static", [], ["artilleryScanner"] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_EnemyArtillery = [RallyUp_Enemy_Side, RallyUp_Enemy_Faction,  "Armored", [], ["artilleryScanner"] ] call RallyUp_fnc_task_ArrayofCfg;

	// 	Random Civillians
	Random_CivAir = [RallyUp_CIV_Side, RallyUp_CIVFaction,  "Air", ["_Wreck_"], [] ] call RallyUp_fnc_task_ArrayofCfg;
	Random_CivVeh = [RallyUp_CIV_Side, RallyUp_CIVFaction, "Car", ["_Wreck_"], ["transportSoldier"] ] call RallyUp_fnc_task_ArrayofCfg;

	// Random AmmoCrates 
	RallyUp_AmmoCrates = [RallyUp_CIV_Side, "Default", "Ammo", [str RallyUp_Enemy_Side], [] ] call RallyUp_fnc_task_ArrayofCfg;

	// Random Wrecks typesvehicleClass = "Wreck_sub";
	RallyUp_Wrecks = [RallyUp_CIV_Side, "Default", "Wreck", ["Traw","Boat" ], [] ] call RallyUp_fnc_task_ArrayofCfg;
		
	// Random Assassinate and Rescue items : People 
	RallyUp_POI = [RallyUp_CIV_Side, RallyUp_CIVFaction, "Men", [], [] ] call RallyUp_fnc_task_ArrayofCfg;

	// Random Assassinate and Rescue items : Vehicles
	RallyUp_POIVehicles = ( [RallyUp_CIV_Side, RallyUp_CIVFaction, "Car", [], [] ] call RallyUp_fnc_task_ArrayofCfg) + ([RallyUp_CIV_Side, RallyUp_CIVFaction, "Air", [], [] ] call RallyUp_fnc_task_ArrayofCfg);

	// Random Objectives Types
	RallyUp_BldObjectives = ["Land_Communication_","Land_Cargo_Tower_"];
	
	// Random Mine types
	RallyUp_MinesAP = [4, "None", "Mines", ["UnderwaterMine","SatchelCharge","DemoCharge"], ["camouflage"] ] call RallyUp_fnc_task_ArrayofCfg;

	// Different kinda of actions for AI
	RallyUp_combatMode = ["AWARE","COMBAT","STEALTH"];
	RallyUp_formationMode =["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","FILE","DIAMOND"];
	RallyUp_SpeedMode = ["LIMITED","NORMAL","FULL"];

diag_log format ["RallyUp : fn_game_rallyup.sqf | END %1",serverTime];
if(true) exitWith {}