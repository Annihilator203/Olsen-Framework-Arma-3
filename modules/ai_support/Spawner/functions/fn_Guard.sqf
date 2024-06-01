params ["_group","_TaskCancelDelay","_TaskResetTriggerObj","_SecondaryTargetPosObj","_debug","_TargetPosition","_TaskRadius","_isCrew","_SpawnModule"];

private _ReturntoBase = _SpawnModule getVariable ["ReturntoBase",false];

if (_debug) then {format ["%1: Group is Guarding the Area.", _SpawnModule] remoteExec ["systemchat", 0]};
if (_TaskRadius <= 10 and !_isCrew) then {
	sleep 5;
	[_group,_TaskRadius,_TargetPosition] spawn HBQSS_fnc_360Formation;
	waituntil {
	sleep 1;
	[_group]call HBQSS_fnc_CheckGroupCommands == false
	};
	
	{
		_x disableAI "PATH";
		_x addEventHandler ["Suppressed", {
			params ["_unit", "_distance", "_shooter", "_instigator", "_ammoObject", "_ammoClassName", "_ammoConfig"];
			private _Threshold = (group _unit) getVariable "HBQ_suppressionThreshold";
			if (getSuppression _unit > _Threshold) then {
			
			{
			_x enableAI "PATH";
			_x setUnitPos "AUTO"; 
			} foreach units (group _unit);
			
			_unit removeEventHandler [_thisEvent, _thisEventHandler];
			};
		}];

	} foreach units _group;
	
	_TaskRadius = _TaskRadius *10;
	
};

// Is Vehicle and Radius smaller than 10 make Vehicle stop
if (_isCrew && _TaskRadius < 10) then {sleep 10; (driver vehicle leader _group) disableAI "PATH";};

private _startTime = time;
private _currentTime = time;
if (_TaskCancelDelay <= 0) then {_TaskCancelDelay = 3600};

while { (_currentTime - _startTime) < _TaskCancelDelay and not triggerActivated _TaskResetTriggerObj} do
	{
		sleep 5;
		if (isNull _group) exitWith {true};
		if (count (units _group) == 0) exitWith {true};
		_currentTime = time;
		{
			if (alive _x) then {
				if (( _x distance _TargetPosition)>_TaskRadius) then {
					private _randomLocation = [[[_TargetPosition, _TaskRadius]], []] call BIS_fnc_randomPos; 
					_x doMove _randomLocation;				
					_x moveTo _randomLocation;
				};
			};
		} forEach units _group;

	};

//(driver vehicle leader _group) enableAI "PATH";

{
_x enableAI "PATH";
_x setUnitPos "AUTO";
_x doMove (getPos _x);
} foreach units _group;


if (_debug) then {format ["%1: Guard Time Over! Group procceeds Moving.", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};


if (_ReturntoBase) then {[_group,_debug,_SpawnModule,false] spawn HBQSS_fnc_ReturnToBase;};
