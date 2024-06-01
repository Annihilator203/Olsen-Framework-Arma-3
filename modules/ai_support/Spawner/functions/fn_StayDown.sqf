params["_unit","_TaskCancelDelay","_TaskResetTriggerObj","_lambs","_DCO_SFSM","_Direction","_SearchCover","_SpawnModule"];
private _time = time;
waitUntil {
	sleep 0.5;
	private _newTime = time;
	private _timeDelta = _newTime -_time;
	if !(alive _unit) exitWith {true};
	(moveToCompleted _unit) or unitReady _unit or (_timeDelta > 25)
};

if (_SearchCover) then {
	_unit setDir _Direction;
	_unit setUnitPos  "MIDDLE";
} else {
	_unit doFollow (leader group _unit);
	_unit setUnitPos  "MIDDLE";
	sleep 12;
	_unit setUnitPos  "DOWN";
};

_unit disableAI "PATH";
sleep 2;
_unit disableAI "ANIM";

_unit addEventHandler ["Suppressed", {
	params ["_unit", "_distance", "_shooter", "_instigator", "_ammoObject", "_ammoClassName", "_ammoConfig"];
	private _suppressionThreshold = (group _unit) getVariable "HBQ_suppressionThreshold";
	if (getSuppression _unit > _suppressionThreshold) then {
	{
	_x enableAI "ANIM";
	_x enableAI "PATH";
	_x enableAI "AUTOCOMBAT";
	_x setUnitPos "AUTO";
	} foreach (units group _unit);
	_unit removeEventHandler [_thisEvent, _thisEventHandler];
	};
}];

waitUntil {
sleep 1;
(group _unit) getVariable ["HBQ_HoldFire",false] == false
};
_unit enableAI "ANIM";

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
	for "_i" from 1 to (_TaskCancelDelay/2) do {
	sleep 2;
	if !(alive _unit) exitWith {true};
	};
	
};
if !(alive _unit) exitWith {true};
_unit setUnitPos "AUTO";
_unit enableAI "PATH";