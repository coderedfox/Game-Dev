/*
	Author: CodeRedFox	
	Function: Makes all units flee away 
	Usage: 		[_position, _side ] call RallyUp_fnc_task_flee;
	Example:	[ [0,0,0], RallyUp_Enemy_Side ] call RallyUp_fnc_task_flee;
	
	Returns: NA
*/
diag_log format ["RallyUp : RallyUp_fnc_task_intel | START %1",serverTime];
// 1 Create Intel, 2 Update Intel

	_position = _this select 0; // Position to flee from
	_side = _this select 1; // side

	_fleePOS = [_position, rallyUp_maxDist,rallyUp_maxDist*2, 0 , 0 , 0.1,0,[],[ [-100,-100],[-100,-100] ]] call BIS_fnc_findSafePos;

	{
		if (side _x == _side) then {
			_x allowFleeing 1;
			
			_fleeWP01 = _x addWaypoint [ _fleePOS, 0];
			_fleeWP01 setWaypointType "MOVE";
			_fleeWP01 setWaypointCompletionRadius 300;	
			_fleeWP01 setWaypointSpeed "FULL";		
			_fleeWP01 setWaypointStatements ["true", "{deleteVehicle vehicle _x} forEach thislist;{deleteVehicle _x} forEach thislist;deleteGroup (group this);	"];		

	} forEach allGroups;

diag_log format ["RallyUp : RallyUp_fnc_task_flee| %1 | %2 | %3",_position,_side,_fleePOS];
