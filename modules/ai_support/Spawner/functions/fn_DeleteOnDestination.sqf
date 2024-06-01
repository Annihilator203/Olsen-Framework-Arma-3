#include "script_component.hpp"
params ["_group","_SpawnModule"];
private _DespawnSecurityRadius = _SpawnModule getVariable ["DespawnSecurityRadius",-1];
if (_DespawnSecurityRadius == -1) then {_DespawnSecurityRadius = HBQSS_DeSpawnSecurityRadius;};

private _debug = _SpawnModule getVariable ["Debug",false];
if !(HBQSS_DebugEnabled) then {_debug = false};
_CheckWatchDirection = _SpawnModule getVariable "CheckWatchDirection";
_ChecksDelay = _SpawnModule getVariable "ChecksDelay";
if(_ChecksDelay <= 0) then {_ChecksDelay = HBQSS_ChecksDelay;};


waitUntil {
	sleep 1;
	if (isNull _group) exitWith {true};
	_group getVariable "HBQ_ReachedTargetPos"
};

if (_DespawnSecurityRadius > 0) then {
	if ([leader _group, _DespawnSecurityRadius,_debug,_CheckWatchDirection,_SpawnModule] call HBQSS_fnc_PlayersNear == false) exitWith{};
	waitUntil {
		sleep (_ChecksDelay);
		if (isNull (leader _group)) exitWith {true};
		[leader _group, _DespawnSecurityRadius,_debug,_CheckWatchDirection,_SpawnModule] call HBQSS_fnc_PlayersNear == false
	};
};
private _isOnFoot = isNull objectParent leader _group;	

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
	private _vehicle = objectParent leader _group;
	deleteVehicleCrew _vehicle;
	deleteVehicle _vehicle;
};

//// DEBUG
if (_debug) then {
	format ["%1: Group Deleted", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
};
diag_log format ["INFO HBQ: %1: Group Deleted", _SpawnModule];