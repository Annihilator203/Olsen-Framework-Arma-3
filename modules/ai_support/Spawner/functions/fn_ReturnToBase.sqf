params ["_group","_debug","_SpawnModule","_Wait"];
private _DeleteThreshold = 40;

private _SpawnType = _SpawnModule getVariable ["HBQ_SpawnType",""];
private _TaskCancelDelay = _SpawnModule getVariable ["LambsResetDelay",0];
private _TaskResetTrigger = _SpawnModule getVariable ["TaskResetTrigger",""];
private _TaskResetTriggerObj = missionNamespace getVariable [_TaskResetTrigger , objNull];
private _DespawnSecurityRadius = _SpawnModule getVariable ["DespawnSecurityRadius",-1];
if (_DespawnSecurityRadius == -1) then {_DespawnSecurityRadius = HBQSS_DeSpawnSecurityRadius;};
private _SpawnPosition = _group getVariable ["HBQ_SpawnPos", [0,0,0]];
private _StartAirOnGround = _SpawnModule getVariable ["StartAirOnGround",false];
private _ChecksDelay = _SpawnModule getVariable ["ChecksDelay",5];
if(_ChecksDelay == -1) then {_ChecksDelay = HBQSS_ChecksDelay;};

if (_Wait) then {
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
};

if (_group getVariable ["HBQ_Returning",false]) exitWith {true};

if (_debug) then {"Group returns to Base!" remoteExec ["systemchat", TO_ALL_PLAYERS];};

// DELETE WAYPOINTS
if(count waypoints (leader _group) > 0) then {
	{deleteWaypoint((waypoints (leader _group))select 0);}forEach waypoints (leader _group);
};

// CREATE RETURN WAYPOINT
private _RTBwpt = _group addWaypoint [_SpawnPosition, -1];
_RTBwpt setWaypointType "MOVE";

// CREATE LANDINGZONE
if ((_SpawnType == "AIRVEHICLES" or _SpawnType == "AIRTRANSPORT" or _SpawnType == "AIRCARGOTRANSPORT") and _StartAirOnGround) then {
	[_SpawnPosition,_group] spawn HBQSS_fnc_CreateLandingZone;
};

{
	_x enableAI "Path";
	//_x disableAI "FSM";
	_x disableAI "AUTOCOMBAT";
	_x disableAI "WEAPONAIM";
	_x disableAI "COVER";
	_x disableAI "AUTOTARGET";
	_x setVariable ["lambs_danger_disableAI", true];
	_x setVariable ["SFSM_excluded", true];
	_x setVariable ["HBQ_IsForcedToMove",true];
} forEach (units _group);

_group setVariable ["HBQ_Returning",true];

if ((behaviour leader _group) == "COMBAT") then {
_group setBehaviourStrong "AWARE";
//(leader _group) setBehaviour "AWARE";
};

_group setVariable ["Vcm_Disable",true]; 
_group setVariable ["lambs_danger_disableGroupAI",true];
_group setFormation "FILE";
_group setBehaviourStrong "AWARE";

if (_SpawnType == "TRANSPORT" or _SpawnType == "CARGOTRANSPORT"  or _SpawnType == "AIRTRANSPORT"  or _SpawnType == "AIRCARGOTRANSPORT" or _SpawnType == "NAVALTRANSPORT") then {
	_group setBehaviourStrong "SAFE";
	//(leader _group) setBehaviour "SAFE";
};
_group setCombatMode "GREEN";
_group setSpeedMode "FULL";
_group allowFleeing 0;
{_x setUnitPos "UP";} forEach units _group;

if (_SpawnType == "NAVALTRANSPORT" or _SpawnType == "AIRTRANSPORT" or _SpawnType == "AIRVEHICLES" or  _SpawnType == "AIRCARGOTRANSPORT") then {
	_DeleteThreshold = 200;
	if (_StartAirOnGround && _SpawnType != "NAVALTRANSPORT") then {_DeleteThreshold = 500};
};

// Wait until SpawnPosition is Reached
waitUntil {
	if !(alive leader _group) exitWith {true};
	sleep (_ChecksDelay/5);
	((getPos (leader _group)) distance2d _SpawnPosition) < _DeleteThreshold
};

if (_StartAirOnGround) then {
	(vehicle leader _group) flyInHeight 30;
};
_group setVariable ["HBQ_ReachedTargetPos",true,true];

if ((_SpawnType == "AIRVEHICLES" or _SpawnType == "AIRTRANSPORT"  or  _SpawnType == "AIRCARGOTRANSPORT") and _StartAirOnGround) then {
	waitUntil {
		if !(alive leader _group) exitWith {true};
		sleep (_ChecksDelay/5);
		((getPos (leader _group)) distance _SpawnPosition) < 150
	};

	(vehicle leader _group) land "LAND";

	waitUntil {
		sleep (_ChecksDelay/5);
		[vehicle leader _group]call HBQSS_fnc_CheckIsAirborne == false
	};
	sleep 40; // Wait for Motors to turn down
};

[_group,_SpawnModule] spawn HBQSS_fnc_DeleteOnDestination;
