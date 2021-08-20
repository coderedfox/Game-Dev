/*

	Author: CodeRedFox
	Uses: Debug MASTER

*/ 
if (!RallyUp_debug) exitwith {};

	player allowDamage false;
	OnMapSingleClick "vehicle player SetPos [_pos select 0, _pos select 1, _pos select 2]";
	
	[] spawn RallyUp_fnc_debug_allunits;

