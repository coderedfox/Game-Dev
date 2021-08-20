/*

	Author: CodeRedFox
	Uses: Debug with markers
	Note:
	Usage:		[] spawn RallyUp_fnc_debug_allunits;

*/ diag_log format ["RallyUp : RallyUp_fnc_debug_allunits | %1 | %2",time,serverTime];


_allunits = [];
_MarkerArray = [];

_type = "mil_dot";
_text = "";
_color = "ColorBlack";

	waituntil {

		_MarkerArray = [];
		_MarkerType = allunits+vehicles+allDead;		
		
		{
				switch (side _x) do {
					case RallyUp_Enemy_Side: {_color = "ColorGREEN"};	
					case RallyUp_Enemy_Side: {_color = "ColorRED"};
					case civilian: {_color = "ColorBlue"};
						default {_color = "ColorBlack"};
				};			
				
				_markerDebug = createMarkerLocal [format["RallyUp_%1",_x],position _x];
				_markerDebug setMarkerShapelocal "ICON";			
				_markerDebug setMarkerTypelocal _type;	

				_name = ([_x] call RallyUp_fnc_text_GetInfo) select 1;
				
				_markerDebug setMarkerText _name;
				_markerDebug setMarkercolor _color;
				_markerDebug setMarkerDir (getdir _x);
				
				_MarkerArray pushBack _markerDebug;	
		} foreach _MarkerType;
		
		sleep 5;
		
		{		
			deleteMarker _x;
			
		} foreach _MarkerArray;	
		
		false		
	};
	
