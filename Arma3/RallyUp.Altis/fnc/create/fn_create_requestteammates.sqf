/*
	Author: CodeRedFox	
	Function: Adds AI to team wityh a limit
	Usage: [] spawn RallyUp_fnc_create_requestteammates
	Returns: N/A
*/ 

	
	_object = _this select 0;
		
	_object addAction ["<t color=RallyUp_ColorHex  t size='2'>Request a teammate</t>",
		'
			_Unit = _this select 1;
			if (count units group _Unit < 5) then {			
				_Random_unit = [RallyUp_FriendlySide,["_Soldier_"], ["_VR_"] ] call RallyUp_fnc_task_ArrayofCfg;
				
				_RallyUp_UnitsArray = _Random_unit select floor random count _Random_unit;
				
				_yourteammate = _RallyUp_UnitsArray createUnit [getpos _Unit, (group _Unit)];				
										
			} else {hint "Maximum Fireteam Reached"};
		', player
	];
	
