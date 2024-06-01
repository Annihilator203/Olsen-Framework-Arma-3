params["_group","_TagetPosition","_TargetPosDir","_vcom","_lambs","_LambsTask","_DCO_SFSM","_TaskRadius","_SpawnType",
"_TaskCancelDelay","_TaskResetTriggerObj","_SecondaryTargetPosObj","_debug","_DeleteAtTargetposition","_DespawnSecurityRadius","_SpawnModule","_CheckWatchDirection",
"_SpawnPosition","_ReturntoBase","_TCL","_ChecksDelay"];

/// Wait until TargetPosition is reached
waitUntil {
sleep 0.2;
_group getVariable ["HBQ_ReachedTargetPos",false]
};
// GROUP SETTINGS
_group setCombatMode "RED";
_group setFormDir _TargetPosDir;
_group setFormation "LINE";


/// Search CoverPosition and Move there
private _nearestHideObjects = nearestterrainobjects [_TagetPosition,["TREE", "SMALL TREE", "BUSH"],25,false,false]; // Find Bushes and Trees near Targetposition
private _SearchCover = false;
if (count _nearestHideObjects >= ((count units _group)*1.5)) then {_SearchCover = true}; // If there is egnough Bushes/Trees go to random Bush

if (_SearchCover) then {
	{
		private _randomHideObject = selectRandom _nearestHideObjects;
		private _CloseHideObjectPos  = [[[_randomHideObject, 0.7]], []] call BIS_fnc_randomPos; 
		_x doMove _CloseHideObjectPos;
	} forEach (units _group);

} else {
	{
		_x doMove formationPosition _x;
		_x moveTo formationPosition _x;
	} forEach (units _group - [leader _group]);
};

{
	[_x,_TaskCancelDelay,_TaskResetTriggerObj,_lambs,_DCO_SFSM,_TargetPosDir,_SearchCover,_SpawnModule] spawn HBQSS_fnc_StayDown;
} forEach (units _group);

waitUntil {
	sleep 0.2;
	_group getVariable ["HBQ_HoldFire",false] == false
};

if (_TaskCancelDelay > 0 or !(isNull _TaskResetTriggerObj)) then {
	/// Wait for Trigger or Delay
	if (_TaskCancelDelay <= 0) then {_TaskCancelDelay = 3600};

	if !(isNull _TaskResetTriggerObj) then {
		private _StartTime = time;
		private _TimeDelta = 0;
		while { 
			sleep 1;
			if (isNil "_SpawnModule") exitWith {true};
			if (isNull _SpawnModule) exitWith {true};
			not triggerActivated _TaskResetTriggerObj //or not (_TimeDelta < _TaskCancelDelay)
			} do {
				private _NewTime = time;
				_TimeDelta = _NewTime-_StartTime;
				if (_TimeDelta > _TaskCancelDelay ) exitWith {true};
			};	
	} else {
		sleep _TaskCancelDelay;
	};
};

_group setVariable ["HBQ_TakeCover", false];





