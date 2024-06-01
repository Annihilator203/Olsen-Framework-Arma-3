#include "script_component.hpp"
params ["_group","_SpawnModule","_debug","_Side","_EngageWhenEnemyNear","_isCrew","_ChecksDelay","_SpawnType","_FinalEngageTactic",
"_StealthEngagement","_FastDisembark","_EngagmentKnowledge","_ReturnToBase","_DespawnSecurityRadius","_SpawnPosition","_CheckWatchDirection"];
private _VehicleIsArmed = false;
private _Vehicle = objNull;
private _KnowledgeRequired = _SpawnModule getVariable ["KnowledgeRequired",false];
private _EnemyKnown = false;

if (_isCrew) then {
	_Vehicle = vehicle (leader _group);
	_VehicleIsArmed = [_Vehicle]call HBQSS_fnc_IsVehicleArmed;
};
if (_FinalEngageTactic == "NONE") then {_FinalEngageTactic = "DIRECT"};

private _NearUnits = [];
private _nearestEnemies =[];
waitUntil {
	sleep (_ChecksDelay);
	if (isNil "_SpawnModule") exitWith {true};
	if (isNull _SpawnModule) exitWith {true};
	if (isNull _group) exitWith {true};
	
	_NearUnits = [getPos (leader _group),_Side,_EngageWhenEnemyNear,false,_SpawnModule]call HBQSS_fnc_getNearUnits;
	_nearestEnemies = _NearUnits select 0;
	
	if (_KnowledgeRequired) then {
		{
		if ((_group knowsAbout _x) > 1.5) then { _EnemyKnown = true; }; 
		
		} forEach _nearestEnemies;
		
	} else {
		_EnemyKnown = true;
	};
	
	((count _nearestEnemies > 0) && _EnemyKnown)
};

if (isNull _group) exitWith {true};



if (_EngagmentKnowledge != 0) then {
	{
		(leader _group) reveal [_x, _EngagmentKnowledge];
	} foreach _nearestEnemies;
};


// Set Variables

_group setVariable ["HBQ_ReachedTargetPos",true,true];
_group setVariable ["Vcm_Disable",true];

//////////////  DELETE WAYPOINTS  ////////////////////

if(count waypoints (leader _group) > 0) then {
	{deleteWaypoint((waypoints (leader _group))select 0);}forEach waypoints (leader _group);
};

//////////////  ADD NEW WAYPOINTS  ////////////////////

if (_SpawnType == "TRANSPORT" && _isCrew) then {
private _wpt = _group addWaypoint [getPos (leader _group),0];
_wpt setWaypointType "UNLOAD";
};


//////////////  DISEMBARK  ////////////////////

if (_SpawnType == "TRANSPORT" && !_isCrew) then {
	waitUntil {
		sleep (_ChecksDelay/10);
		if (isNil{objectParent (leader _group)}) exitWith{true};
		speed (objectParent (leader _group)) < 5
	};
	{	
		sleep 0.3;
		unassignvehicle _x;
		moveout _x;		
	} foreach units _group;
};


////////////// ENGAGE  //////////////


if (_SpawnType == "AIRTRANSPORT" && !_isCrew) then {
	[objectParent (leader _group),_SpawnModule getVariable ["ParachuteOpenAltitude",250],[],false,_group,_SpawnModule] spawn HBQSS_fnc_Paradrop;
};

if (_isCrew && _VehicleIsArmed && _SpawnType == "TRANSPORT") then {sleep 10;};


if (_isCrew && _VehicleIsArmed && (_SpawnType == "TRANSPORT" or _SpawnType == "AIRTRANSPORT" or _SpawnType == "NAVALTRANSPORT")) then {
[_group,_EngageWhenEnemyNear,_debug,true,_FinalEngageTactic,_StealthEngagement,_SpawnType,_SpawnModule] spawn HBQSS_fnc_Engage; 
};


if !(_isCrew) then {
[_group,_EngageWhenEnemyNear,_debug,false,_FinalEngageTactic,_StealthEngagement,_SpawnType,_SpawnModule] spawn HBQSS_fnc_Engage; 
};


if (_SpawnType == "VEHICLES" or _SpawnType == "AIRVEHICLES" or _SpawnType == "NAVAL") then {
[_group,_EngageWhenEnemyNear,_debug,false,_FinalEngageTactic,_StealthEngagement,_SpawnType,_SpawnModule] spawn HBQSS_fnc_Engage; 
};




////////////// TRANSPORT CREW RETURN TO BASE  //////////////

if (_ReturnToBase && _isCrew && (_SpawnType == "TRANSPORT" or _SpawnType == "NAVALTRANSPORT" or _SpawnType == "AIRTRANSPORT") && !_VehicleIsArmed) then {
sleep 10;
[_group, _debug,_SpawnModule,false] spawn HBQSS_fnc_ReturnToBase;
};