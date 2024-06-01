#include "script_component.hpp"
params ["_group","_deleteTime","_SpawnModule"];

// Wait for Lifetime to depelete

private _DespawnSecurityRadius = _SpawnModule getVariable ["DespawnSecurityRadius",-1];
if (_DespawnSecurityRadius == -1) then {_DespawnSecurityRadius = HBQSS_DeSpawnSecurityRadius;};
private _Debug = _SpawnModule getVariable ["Debug",false];
if !(HBQSS_DebugEnabled) then {_Debug = false};
private _CheckWatchDirection = _SpawnModule getVariable ["CheckWatchDirection",true];
private _ChecksDelay = _SpawnModule getVariable ["ChecksDelay",5];
if(_ChecksDelay == -1) then {_ChecksDelay = HBQSS_ChecksDelay;};


private _StartTime = time;
waitUntil {
	private _Currenttime = time;
	private _Timedelta = _Currenttime-_StartTime;
	sleep 5;
	if (isNull _group) exitWith {true};
	if ((count units _group)== 0) exitWith {true};
	_Timedelta > _deleteTime
};

if (_DespawnSecurityRadius > 0 ) then {
	if (isNull _group) exitWith {true};
	if (count (units _group) == 0) exitWith {true};
	if ([leader _group, _DespawnSecurityRadius,_debug,_CheckWatchDirection,_SpawnModule] call HBQSS_fnc_PlayersNear == false) exitWith{};
	waitUntil {
		sleep (_ChecksDelay + 2);
		if (isNull _group) exitWith {true};
		if (count (units _group) == 0) exitWith {true};
		[leader _group, _DespawnSecurityRadius,_debug,_CheckWatchDirection,_SpawnModule] call HBQSS_fnc_PlayersNear == false
	};
};

if (isNull _group) exitWith {true};
if (count (units _group) == 0) exitWith {true};
private _isOnFoot = isNull objectParent (leader _group);	

if (_isOnFoot) then {
	{
	
		[_x,_ChecksDelay] spawn {
		(_this select 0) setUnitPos  "DOWN";
		sleep 1;
		sleep (random (_this select 1));
		deleteVehicle (_this select 0);
		};
		
	} forEach units _group;

} else {
	private _vehicle = objectParent (leader _group);
	deleteVehicleCrew _vehicle;
	deleteVehicle _vehicle;
};

if (_debug) then {
	format ["%1: Group Deleted", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
};
diag_log format ["INFO HBQ: %1: Group Deleted", _SpawnModule];