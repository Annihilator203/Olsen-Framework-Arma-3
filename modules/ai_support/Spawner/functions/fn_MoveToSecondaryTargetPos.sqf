#include "script_component.hpp"
params ["_group","_SecondaryTargetPosObj","_debug","_SpawnModule","_isCrew"];
private _Vehicle = objNull;
if (isNull _SecondaryTargetPosObj) exitWith {true};
private _SpawnType = _SpawnModule getVariable ["HBQ_SpawnType",""];

// VARIABLES
if (_isCrew) then {_Vehicle = (objectParent leader _group)};
private _ChecksDelay = _SpawnModule getVariable ["ChecksDelay",5];
if(_ChecksDelay == -1) then {_ChecksDelay = HBQSS_ChecksDelay;};

// DELETE WAYPOINTS
if(count waypoints (leader _group) > 0) then {
	{deleteWaypoint((waypoints (leader _group))select 0);}forEach waypoints (leader _group);
};

// BEHAVIOUR 
_group setBehaviourStrong "AWARE";
(leader _group) setBehaviour "AWARE";
_group setFormation "FILE";


/// If Secondarytargetobject is a Group follow the Group
if (typeName _SecondaryTargetPosObj == "GROUP") exitWith {
	
	if (_debug) then {format ["%1: Following Group.", _SpawnModule]remoteExec ["systemchat", TO_ALL_PLAYERS];};
	[_group,_SecondaryTargetPosObj,30,15,false,false,0,objNull]spawn HBQSS_fnc_Follow;

}; 

private _SecondaryTargetPos = getPos _SecondaryTargetPosObj;

/// LAND IF IS AIR VEHICLE AND TARGET POS IN ON GROUND
[_group,_ChecksDelay,_SpawnModule,getPos _SecondaryTargetPosObj] spawn HBQSS_fnc_Land;



//// Pack StaticWeapons

if (_SpawnType == "TURRETS" or (_group getVariable ["HBQ_isArtillery",false]) or _SpawnModule getVariable ["DeployStaticWeapons",false]) then {
		
	if (count (units _group) >= 3 ) then {
		{
			if ( (objectparent _x) isKindOf "StaticWeapon") then {
				[_group,_SpawnModule] spawn HBQSS_fnc_PackStaticWeapon;
				sleep 10;
			};
		} forEach units _group;

	};
};



// CREATE  WAYPOINT

{
	_x setVariable ["HBQ_IsForcedToMove",true];
	if (_x == leader group _x) then {
		_x doMove getpos _x;
		_x doMove _SecondaryTargetPos;
		(group _x) setVariable ["HBQ_TargetPos", _SecondaryTargetPos];
	} else {
		_x doFollow (leader group _x);
	};
} forEach units _group;


private _wpt = _group addWaypoint [_SecondaryTargetPos, -1];
_wpt setWaypointType "MOVE";
private _wpt2 = _group addWaypoint [_SecondaryTargetPos, -1];
_wpt2 setWaypointType "SAD";

if (isNil "_SpawnModule") exitWith {true};
if (isNull _SpawnModule) exitWith {true};
private _FleeToSecondaryPos = _SpawnModule getVariable ["FleeToSecondaryPos",false];

// FLEEING

if (_FleeToSecondaryPos) then {
	if (_debug) then {
		format ["%1: Group is Fleeing", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
	};

	private _CivilianGroup = createGroup [CIVILIAN,true];
	
	_CivilianGroup setVariable ["HBQ_SpawnPos",_group getVariable ["HBQ_SpawnPos",[]],true];
	_CivilianGroup setVariable ["HBQ_SpawnedBy",_SpawnModule,true];
	_CivilianGroup setFormation "FILE";
	_CivilianGroup setVariable ["Vcm_Disable",true]; 
	_CivilianGroup setVariable ["lambs_danger_disableGroupAI", true];
	_CivilianGroup setSpeedMode "FULL";
	_CivilianGroup allowFleeing 0;
	[_CivilianGroup]call HBQSS_fnc_deleteGroupWhenEmpty;
	
	
	/// Delete Crew (Gets created new because it does not work otherwise for some reason.)
	{
		if (_isCrew) then {
			deleteVehicle _x;
		};
	} forEach units _group;
	
	
	_group setVariable ["HBQ_IsFleeing", true];
	
	// Foreach Unit in Group
	{
		if (isNull _x) then {continue};
		[_x] spawn HBQSS_fnc_KillStuckUnit;
		_x joinAsSilent [_CivilianGroup,1];
		_x disableAI "AUTOCOMBAT";
		_x disableAI "AUTOTARGET";
		_x disableAI "CHECKVISIBLE";
		_x disableAI "TARGET";
		_x disableAI "COVER";
		_x setVariable ["lambs_danger_disableAI", true];
		_x playMoveNow "";
		_x playActionNow "";
		doStop _x;
		sleep 0.2;
		_x doFollow _x;
		sleep 0.5;
		_x doMove _SecondaryTargetPos;
		sleep 0.2;
		_x moveTo _SecondaryTargetPos;
	} forEach units _group;
	
	private _wpt = _CivilianGroup addWaypoint [_SecondaryTargetPos, 0.5];
	_CivilianGroup setVariable ["HBQ_ReachedTargetPos",false,true];
	if (_isCrew) then {
		_CivilianGroup createVehicleCrew _Vehicle;
		
		doStop (driver _Vehicle);
		sleep 0.2;
		(driver _Vehicle) doFollow (driver _Vehicle);
		sleep 0.5;
		(driver _Vehicle) doMove _SecondaryTargetPos;
		sleep 0.2;
		(driver _Vehicle) moveTo _SecondaryTargetPos;

		
	};
	
	private _DistanceThreshold = 10;
	if (_isCrew && (_Vehicle isKindOf "Plane" or _Vehicle isKindOf "Helicopter")) then {_DistanceThreshold = 150;};
	 
	waitUntil {
		sleep (_ChecksDelay/2);
		if (isNil "_CivilianGroup") exitWith {true};
		if (isNull _CivilianGroup) exitWith {true};
		if !(alive (leader _CivilianGroup)) exitWith {true};
		((leader _CivilianGroup) distance2d _SecondaryTargetPos) < _DistanceThreshold
	};
	_CivilianGroup setVariable ["HBQ_ReachedTargetPos",true,true];
	[_CivilianGroup,_SpawnModule] spawn HBQSS_fnc_DeleteOnDestination;

} else {
	if (_debug) then {"Groups move to secondary Targetposition." remoteExec ["systemchat", TO_ALL_PLAYERS];};
};