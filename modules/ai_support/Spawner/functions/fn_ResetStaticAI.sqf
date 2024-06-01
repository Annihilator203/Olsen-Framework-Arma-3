params ["_unit","_StaticResetDelay","_TaskResetTriggerObj","_SpawnModule"];	
// Wait for Trigger or Delay
if (_StaticResetDelay <= 0) then {_StaticResetDelay = 3600};

if !(isNull _TaskResetTriggerObj) then {
	private _StartTime = time;
	private _TimeDelta = 0;
	while { 
		sleep 1;
		if (isNil "_SpawnModule") exitWith {true};
		if (isNull _SpawnModule) exitWith {true};
		if (!Alive _unit) exitWith {true};
		(not triggerActivated _TaskResetTriggerObj) //or not (_TimeDelta < _TaskCancelDelay)
		} do {
			private _NewTime = time;
			_TimeDelta = _NewTime-_StartTime;
			if (_TimeDelta > _StaticResetDelay ) exitWith {true};
		};	
		
} else {
	sleep _StaticResetDelay;
};
_unit enableAI "PATH";
_unit setUnitPos  "AUTO";
(group _unit) setVariable ["HBQ_Static", false];