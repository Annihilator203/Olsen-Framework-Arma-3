params ["_TaskCancelDelay","_TaskResetTriggerObj","_SpawnModule","_group","_SecondaryTargetPosObj","_debug","_isCrew"];

/// EXIT IF CREW OF TRANSPORT
private _SpawnType = _SpawnModule getVariable ["HBQ_SpawnType",""];
if (_isCrew && (_SpawnType == "TRANSPORT" or _SpawnType == "CARGOTRANSPORT" or _SpawnType == "AIRTRANSPORT" or _SpawnType == "NAVALTRANSPORT")) exitwith {true};


/// Wait for Trigger or Delay
if (_TaskCancelDelay <= 0) then {_TaskCancelDelay = 3600};
if !(isNull _TaskResetTriggerObj) then {
	private _StartTime = time;
	private _TimeDelta = 0;
	while { 
		sleep 1;
		if (isNil "_SpawnModule") exitWith {true};
		if (isNull _SpawnModule) exitWith {true};
		(not triggerActivated _TaskResetTriggerObj) //or not (_TimeDelta < _TaskCancelDelay)
		} do {
			private _NewTime = time;
			_TimeDelta = _NewTime-_StartTime;
			if (_TimeDelta > _TaskCancelDelay ) exitWith {true};
		};		
} else {
	waituntil {
		sleep 1;
		_group getVariable ["HBQ_ReachedTargetPos",false]
	};
	sleep _TaskCancelDelay;
	
};
[_group,_SecondaryTargetPosObj,_debug,_SpawnModule,_isCrew] call HBQSS_fnc_MoveToSecondaryTargetPos;
