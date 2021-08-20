/*
	Author: CodeRedFox	
	Function: Adds AI to team wityh a limit
	Usage: [] spawn RallyUp_fnc_create_requestteammates
	Returns: N/A
*/ 

	
	_object = _this select 0;
		
	_object addAction ["<t color='#ffb400'>Request a teammate</t>",
		'
			_Unit = _this select 1;
			if (count units group _Unit < 5) then {			
				
				_RallyUp_UnitsArray = Random_FriendlyInf select floor random count Random_FriendlyInf;
				
				_yourteammate = _RallyUp_UnitsArray createUnit [getpos _Unit, (group _Unit)];				
										
			} else {hint "Maximum Fireteam Reached"};
		', player
	];
	
