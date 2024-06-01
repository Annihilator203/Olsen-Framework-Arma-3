params["_group","_TargetPosition","_LambsTask","_TaskRadius","_SpawnType","_TaskCancelDelay","_TaskResetTriggerObj","_SecondaryTargetPosObj","_debug",
"_DeleteAtTargetposition","_DespawnSecurityRadius","_SpawnModule","_CheckWatchDirection","_SpawnPosition","_ReturntoBase","_ChecksDelay"];
if not (isClass(configFile >> "CfgPatches" >> "lambs_danger")) exitWith {};
if (_debug) then {format ["%1: LambsTask %2 started on Group ", _SpawnModule,_LambsTask] remoteExec ["systemchat", TO_ALL_PLAYERS];};

if(_LambsTask == "HUNT" or _LambsTask == "RUSH" or _LambsTask == "ASSAULT" ) then {
	_group setBehaviourStrong "AWARE";
	_group setCombatMode "YELLOW";
	_group setSpeedMode "NORMAL";
};

[_LambsTask, _group, _TargetPosition,_TaskRadius] call HBQSS_fnc_LambsTask;

if (_TaskCancelDelay > 0  or !(isNull _TaskResetTriggerObj)) then {
	[_group,_TargetPosition,_TaskCancelDelay,_TaskResetTriggerObj,_SecondaryTargetPosObj,_debug,_DeleteAtTargetposition,_DespawnSecurityRadius,_SpawnType,_CheckWatchDirection,_SpawnPosition,_ReturntoBase,_ChecksDelay,_SpawnModule] spawn HBQSS_fnc_ResetLambsTask;
	
};

/// IF IS TRANSPORT
if (_SpawnType == "TRANSPORT" or  _SpawnType == "NAVALTRANSPORT" or _SpawnType == "AIRTRANSPORT") then {
	// Split Driver Group
	private _VehiclesContent = [_group] call HBQSS_fnc_SplitDriverGroup;
	
	private _DriverGroup = _VehiclesContent select 0;
	_DriverGroup setVariable ["lambs_danger_disableGroupAI", true];
	_DriverGroup setVariable ["HBQ_ReachedTargetPos", true,true];

	if(_LambsTask == "HUNT" or _LambsTask == "RUSH" or _LambsTask == "ASSAULT" ) then {
	_DriverGroup setBehaviourStrong "AWARE";
	_DriverGroup setCombatMode "YELLOW";
	_DriverGroup setSpeedMode "NORMAL";
	};
	if (_TaskCancelDelay > 0  or !(isNull _TaskResetTriggerObj)) then {
	[_DriverGroup,_TargetPosition,_TaskCancelDelay,_TaskResetTriggerObj,_SecondaryTargetPosObj,_debug,_DeleteAtTargetposition,_DespawnSecurityRadius,_SpawnType,_CheckWatchDirection,_SpawnPosition,_ReturntoBase,_ChecksDelay,_SpawnModule] spawn HBQSS_fnc_ResetLambsTask;
	
};
	[_LambsTask, _DriverGroup, _TargetPosition,_TaskRadius] call HBQSS_fnc_LambsTask;
};