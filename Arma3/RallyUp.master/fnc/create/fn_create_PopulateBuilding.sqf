/*
	Author: CodeRedFox	
	Function: Fills empty spots in a building with units
	Usage: [building,[array of types],percentage] call RallyUp_fnc_create_PopulateBuilding;
	Example : [nearestBuilding player,RallyUp_Groups_EnemyInf,50] call RallyUp_fnc_create_PopulateBuilding;
	Returns: Enemy Group

*/


// Variables
  _building = _this Select 0;
  _types = _this select 1;
  _percentage = _this select 2;
    
  _buildingSpots = [];
  _EnemyGroup = createGroup (RallyUpOpFor select 0);  

// Function
if (count allunits < 50) then {
  _buildingSpots = [_building] call BIS_fnc_buildingPositions;
  	{
		_Randompercentage = random 50;
		if(_Randompercentage < _percentage) then {
			_EnemyGroup = createGroup (RallyUpOpFor select 0);
			_SelectEnemyGroup = (_types select floor random count _types) select 1;
			
			_SelectEnemyUnit = _SelectEnemyGroup select floor random count _SelectEnemyGroup;
			
			_Zfix = [_x select 0,_x select 1,(_x select 2) + 0.5];
				_Enemy = _EnemyGroup createUnit [_SelectEnemyUnit, _Zfix, [], 0, "NONE"];
			
			_Enemy setdir (random 360);
			
			RallyUp_TotalEnemyUnits = RallyUp_TotalEnemyUnits +(units _Enemy);
			diag_log format ["RallyUp : RallyUp_fnc_create_PopulateBuilding | _EnemyGroup = %1",count (units _Enemy)];
		};
	} foreach _buildingSpots;
};	




