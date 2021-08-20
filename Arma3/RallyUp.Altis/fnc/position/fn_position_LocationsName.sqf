/*
	Author: CodeRedFox	
	Function: Finds closest name to a position
	Usage: [position] call RallyUp_fnc_position_LocationsName;
	Example : [position player] call RallyUp_fnc_position_LocationsName; 
	Returns: Location name  = _Name	
*/

	_position = _this select 0;
	
	_locations = (RallyUp_LocationsPopulace+RallyUp_LocationsLocal);
	
	_Name = text ((nearestLocations [_position, _locations,5000]) select 0);

diag_log format ["RallyUp : RallyUp_fnc_position_LocationsName | _Name = %1",_Name];
_Name
