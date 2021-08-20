/*
	Author: CodeRedFox	
	Function: Creates and manages Enemy reinforcements
	Usage: [position,TYPE,min,max,amount,actions] spawn RallyUp_fnc_create_Enemy
	Example: [position player,200,300,["Helicopters"],1,''] spawn RallyUp_fnc_create_Enemy;
	Returns: N/A
*/	

	_position = _this select 0;	
	_min = _this select 1;
	if (_min < 10) then {_min = 1};
	
	_max = _this select 2;
	_type = _this select 3;
	_amount = ceil random (_this select 4);
	_actions = _this select 5;
	
	_Random_EnemyInf = [RallyUp_EnemySide,["_Soldier_"], ["_VR_","_crew_","VirtualCurator_F","_diver_"] ] call RallyUp_fnc_task_ArrayofCfg;	
	_Random_EnemyMech = [RallyUp_EnemySide,["_Apc_","Truck_F","Offroad_","MRAP"], "" ] call RallyUp_fnc_task_ArrayofCfg;
	_Random_Static = [RallyUp_EnemySide,["StaticAAWeapon","StaticATWeapon","StaticGrenadeLauncher","StaticMGWeapon",""], "StaticMortar" ] call RallyUp_fnc_task_ArrayofCfg;	
	_Random_HelicoptersTransport = [RallyUp_EnemySide,["Heli_Transport_"], "" ] call RallyUp_fnc_task_ArrayofCfg;
	_Random_Jets = [RallyUp_EnemySide,["Plane_Base_F"], "" ] call RallyUp_fnc_task_ArrayofCfg;
	_Random_Boats = [RallyUp_EnemySide,["Boat_F"], "" ] call RallyUp_fnc_task_ArrayofCfg;
	
	
	_foundLocation = _position;
	_direction = 180;
	
	_EnemyGroup = createGroup (RallyUpOpFor select 0);	
	if (count allunits < 50) then {
		
		_combatMode = RallyUp_combatMode;
		_formationMode = RallyUp_formationMode;		
		
		_typeArray = _type select floor random count _type;	
		
		_SetcombatMode = (RallyUp_combatMode select floor random count RallyUp_combatMode);
		_SetformationMode = (RallyUp_formationMode select floor random count RallyUp_formationMode);	
		_SetSpeedMode = (RallyUp_SpeedMode select floor random count RallyUp_SpeedMode);
				
		for "_i" from 1 to _amount do {		
		
			_direction = random 360;
			if (_max != 0) then {
				_foundLocation = [_position, 0, _max, 2, 0, 45, 0] call BIS_fnc_findSafePos;
				_direction = ([_foundLocation, _position] call BIS_fnc_dirTo)-180;
			};				

			switch (_typeArray) do {
				case "Unit": {
					_SelectEnemyUnit = _Random_EnemyInf select floor random count _Random_EnemyInf;
					_Enemy = _EnemyGroup createUnit [_SelectEnemyUnit, _foundLocation, [], 0, "NONE"];

				};

				case "Group": {
					_enemyAmount = (random 10)+2;
					_Index = 0;
					while {_Index < _enemyAmount} do {
						_SelectEnemyUnit = _Random_EnemyInf select floor random count _Random_EnemyInf;	
						_Enemy = _EnemyGroup createUnit [_SelectEnemyUnit, _foundLocation, [], 0, "NONE"];
						[_Enemy] join _EnemyGroup;
						_Index = _Index + 1;
					};						
				
				};
				case "Static": {
					_SelectEnemyGroupArray = _Random_Static select floor random count _Random_Static;
					_SelectEnemyGroup = _SelectEnemyGroupArray select floor random count _SelectEnemyGroupArray;
					_Enemy = [_foundLocation, _direction,_SelectEnemyGroup, _EnemyGroup] call bis_fnc_spawnvehicle;

				};
				case "Vehicles": {
					_SelectEnemyGroupArray = _Random_EnemyMech select floor random count _Random_EnemyMech;
					_SelectEnemyGroup = _SelectEnemyGroupArray select floor random count _SelectEnemyGroupArray;
					_Enemy = [_foundLocation, _direction,_SelectEnemyGroup, _EnemyGroup] call bis_fnc_spawnvehicle;
					[_Enemy select 0,0.5,_position] spawn RallyUp_fnc_create_fillcargo;

				};
				case "Boats": {	
							
					_SelectEnemyGroupArray = _Random_Boats select floor random count _Random_Boats;
					_SelectEnemyGroup = _SelectEnemyGroupArray select floor random count _SelectEnemyGroupArray;						
					_foundLocation = [_position, 0, 1000, 5, 2, 45, 0] call BIS_fnc_findSafePos;					
					_Enemy = [_foundLocation, _direction,_SelectEnemyGroup, _EnemyGroup] call bis_fnc_spawnvehicle;
					[_Enemy select 0,1,_position] spawn RallyUp_fnc_create_fillcargo;

				};				
				
				case "Helicopters":	{
					_foundLocation = [_position, 3000, (random 360)] call BIS_fnc_relPos;
					_SelectEnemyGroupArray = _Random_HelicoptersTransport select floor random count _Random_HelicoptersTransport;
					_SelectEnemyGroup = _SelectEnemyGroupArray select floor random count _SelectEnemyGroupArray;
					_Enemy = [_foundLocation, _direction,_SelectEnemyGroup, _EnemyGroup] call bis_fnc_spawnvehicle;
					[_Enemy select 0,0.3,_position] spawn RallyUp_fnc_create_fillcargo;
					[_Enemy select 0] spawn RallyUp_fnc_task_OpenDoors;
					
				};
				case "Jets": {
					_foundLocation = [_position, 5000, (random 360)] call BIS_fnc_relPos;
					_SelectEnemyGroupArray = _Random_Jets select floor random count _Random_Jets;
					_SelectEnemyGroup = _SelectEnemyGroupArray select floor random count _SelectEnemyGroupArray;
					_Enemy = [_foundLocation, _direction,_SelectEnemyGroup, _EnemyGroup] call bis_fnc_spawnvehicle;

				};
			};
			
			if (_actions == "NONE") then { (leader (group _EnemyGroup) ) commandMove _position};	
			if (_actions == "PATROL") then { [_EnemyGroup, _position, _min] call bis_fnc_taskPatrol;};
			if (_actions == "DEFEND") then { [_EnemyGroup, _position, _min] call bis_fnc_taskDefend;};
			
			_EnemyGroup setBehaviour _SetcombatMode;
			_EnemyGroup setformation _SetformationMode;
		
		};			
	};

// SERVER ------------------------------
diag_log format ["RallyUp : RallyUp_fnc_create_EnemyForces | _EnemyGroup = %1",count units _EnemyGroup];
RallyUp_TotalEnemyUnits = RallyUp_TotalEnemyUnits+(units _EnemyGroup);

