/*
	Author: CodeRedFox	
	Function: Creates and manages Enemy reinforcements
	Usage: [position,chance] spawn RallyUp_fnc_create_fillcargo
	Example : [position player,0.2] spawn RallyUp_fnc_create_fillcargo;
	Returns: N/A

*/

	_Vehicle = _this select 0;	
	_Chance = _this select 1;
	_destination = _this select 2;	
			
	_EnemyGroup = createGroup (RallyUpOpFor select 0);	
	_emptyPositions = _Vehicle emptyPositions "cargo";
	
	for "_i" from 1 to _emptyPositions do {		
		if (_Chance >= random 1) then {
			_SelectEnemyGroup = (RallyUp_Groups_EnemyInf select floor random count RallyUp_Groups_EnemyInf) select 1;	
			_SelectEnemyUnit = _SelectEnemyGroup select floor random count _SelectEnemyGroup;

			_Enemy = _EnemyGroup createUnit [_SelectEnemyUnit, getpos _Vehicle, [], 0, "NONE"];	
				
			_Enemy assignAsCargo _Vehicle;
			_Enemy moveinCargo _Vehicle;
			
			_Enemy unassignItem "NVGoggles";
			_Enemy removeItem "NVGoggles";
			_Enemy addPrimaryWeaponItem "acc_flashlight";
			
		};
		
		
	};
	

	if (!isNil "_destination") then {
		_SetcombatMode = (RallyUp_combatMode select floor random count RallyUp_combatMode);
		_SetformationMode = (RallyUp_formationMode select floor random count RallyUp_formationMode);		
		_EnemyGroup setBehaviour _SetcombatMode;
		_EnemyGroup setformation _SetformationMode;				
						
		[_EnemyGroup, _destination,(random 300)+100]  call bis_fnc_taskDefend;
	};

// SERVER ------------------------------
diag_log format ["RallyUp : RallyUp_fnc_create_fillcargo | Vehicle : %1 %2",_Vehicle,count units _EnemyGroup];
RallyUp_TotalEnemyUnits = RallyUp_TotalEnemyUnits+(units _EnemyGroup);

