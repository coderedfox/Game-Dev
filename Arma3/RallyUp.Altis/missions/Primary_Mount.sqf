
/*
	Author: CodeRedFox
	Uses: Creates a Defend a building mission. Defend until all units are dead.
	Note: 
	Usage: [position] execVM "missions\Primary_Mount.sqf"
	Examples:[position player] execVM "missions\Primary_Mount.sqf";

*/ diag_log format ["RallyUpDiag Starting : Primary_Mount.sqf | %1",_this select 0];
if (!isServer) exitwith {};
  
	// Variables
	
		_TaskingPosition = _this select 0;
		_Task_Status = "Canceled";			
	
		
		_waveamount = RallyUp_EnemyMultiplier + (ceil (random (count allplayers)));
		
	// Find Tasking Location
		_Defend_Location = [_TaskingPosition,RallyUp_minDistance,RallyUp_maxDistance] call RallyUp_fnc_position_LocationsBuilding;
		if (_Defend_Location distance2d _TaskingPosition > RallyUp_maxDistance) exitWith {diag_log ["RallyUpDiag : Mission outside of RallyUp_maxDistance"];true};;	// Will cancel if the task to to far away		
		
		_LocationName = [_Defend_Location] call RallyUp_fnc_position_LocationsName;
		_Defend_LocationSpots = [_Defend_Location] call RallyUp_fnc_position_LocationsSpots;
		
	// Create Starting Enemy's	
		[_Defend_Location,0,50,["Group","Static","Vehicles"],_waveamount,"PATROL"] spawn RallyUp_fnc_create_Enemy;
		
		
		_FindBuildings = nearestObjects [_Defend_Location, ["Building"], 50];
		{
			[_x,RallyUp_Groups_EnemyInf,5] call RallyUp_fnc_create_PopulateBuilding;
		} foreach _FindBuildings;
		
	
	// Diary
		_taskTitle = ["Mission"] call RallyUp_fnc_text_RandomName;
		_taskPosition = _Defend_Location;
		_taskType = "Defend";
		_taskDescription = str formatText ["
			<img image='\A3\UI_F_MP_Mark\Data\Tasks\Types\Defend_ca.paa' width='50px'/>
			<br/>
			<br/>O P S E C : -----------------
			<br/>
			<br/>	Move and defend the building at %1 near %2
			<br/>
			<br/>
			<br/>O B J E C T I V E : -----------------
			<br/>
			<br/>	- Defend %1 until all enemies are defeated.
			<br/>
			<br/>
			<br/>TIPS:
			<br/>	Mission will be complete after all hostile are eliminated.
			<br/>			
		",_Defend_Location,_LocationName];	
		_Task_Name = str formatText ["%1%2",_taskType,time];
		_Task_Mission = [(RallyUpBluFor select 0),_Task_Name,[_taskDescription,_taskTitle,_taskType],[_taskPosition select 0,_taskPosition select 1,5],1,1,true,_taskType] call BIS_fnc_taskCreate;
	
		
	// Task Event
		waituntil {
			sleep 15;			
			_areaTrigger = [allplayers,(RallyUpBluFor select 0),_Defend_Location,RallyUp_minDistance,75] call RallyUp_fnc_task_isTriggered;							
			if (_areaTrigger) exitWith {true;};
				false
		};
		
		[_Defend_Location,_waveamount] spawn RallyUp_fnc_create_reinforcements;
		
		waituntil {
			sleep 60;			
			_areaTrigger = [allplayers,(RallyUpBluFor select 0),_Defend_Location,RallyUp_minDistance,75] call RallyUp_fnc_task_isTriggered;
			_EnemyTrigger = [RallyUp_TotalEnemyUnits,(RallyUpOpFor select 0),_Defend_Location,RallyUp_maxDistance,10] call RallyUp_fnc_task_isTriggered;						
			if (_areaTrigger && !_EnemyTrigger) exitWith {_Task_Status = "Succeeded";true};
				false
		};
		
	
// Task End Events
	[_Task_Mission,_Task_Status] call BIS_fnc_taskSetState; // "Succeeded","Failed","Canceled"
	
if(true) exitWith {};
