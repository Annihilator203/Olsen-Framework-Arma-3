params ["_group","_TargetPosition","_TaskCancelDelay","_TaskResetTriggerObj","_SecondaryTargetPosObj","_debug","_DeleteAtTargetposition",
"_DespawnSecurityRadius","_SpawnType","_CheckWatchDirection","_SpawnPosition","_ReturntoBase","_ChecksDelay","_SpawnModule"];

if !(isNull _TaskResetTriggerObj) then {
	private _StartTime = time;
	while { 
		sleep 1;
		if (isNil "_SpawnModule") exitWith {true};
		if (isNull _SpawnModule) exitWith {true};
		not triggerActivated _TaskResetTriggerObj 
		} do {
			private _NewTime = time;
			private _TimeDelta = _NewTime-_StartTime;
			
			if (_TimeDelta > _TaskCancelDelay && _TaskCancelDelay > 0) exitWith {true};
			
		};	
} else {
	sleep _TaskCancelDelay;
};

if(isClass(configFile >> "CfgPatches" >> "lambs_danger") && _debug)then {
	"LambsTask Reset!" remoteExec ["systemchat", TO_ALL_PLAYERS];	
};

{
	_x enableAI "all";
	_x switchMove "";
	_x playMoveNow "";
	_x playActionNow "";
} forEach (units _group);

private _newGroup = createGroup [(side _group),true];
_newGroup setVariable ["HBQ_SpawnedBy",_group getVariable ["HBQ_SpawnedBy",objnull],true];
_newGroup setVariable ["HBQ_SpawnPos",_group getVariable ["HBQ_SpawnPos",[]],true];
(units _group) join _newGroup;
[_newGroup]call HBQSS_fnc_deleteGroupWhenEmpty;

if (isNull _SecondaryTargetPosObj) then {
	private _wpt = _newGroup addWaypoint [_TargetPosition, 0];
	_wpt setWaypointType "MOVE";
	_wpt setWaypointCompletionRadius 5;

} else {
	[_newGroup,_SecondaryTargetPosObj,_debug,_SpawnModule,false] call HBQSS_fnc_MoveToSecondaryTargetPos;
};

_group setFormation "FILE";
_group setBehaviourStrong "AWARE";
_group setSpeedMode "FULL";
_newGroup setVariable ["HBQ_ReachedTargetPos",false,true];// PUBLIC ??

if (_DeleteAtTargetposition) then {[_newGroup,_SpawnModule] spawn HBQSS_fnc_DeleteOnDestination;};

if (_ReturntoBase and _SpawnType != "") then {
	[_newGroup, _debug,_SpawnModule,false] spawn HBQSS_fnc_ReturnToBase;
};