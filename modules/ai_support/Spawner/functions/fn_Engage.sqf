#include "script_component.hpp"
params ["_group","_searchdistance","_debug","_DoFollow","_FinalEngageTactic","_StealthEngagement","_SpawnType","_SpawnModule"];
private _TaskCancelDelay = _SpawnModule getVariable ["LambsResetDelay",0];

private _TaskResetTrigger = _SpawnModule getVariable ["TaskResetTrigger",""];
private _TaskResetTriggerObj = missionNamespace getVariable [_TaskResetTrigger , objNull];
if (_group getVariable "HBQ_IsEngaging") exitWith {true};
_group setVariable ["HBQ_IsEngaging",true];
if (_SpawnModule getVariable "IgnoreEnemies") then {
	[_group,_SpawnModule getVariable "SupportbyFire"]spawn HBQSS_fnc_ResetRush;
};

private _Leader = leader _group;
private _NearUnits = [_Leader,side _Leader,_searchdistance,false,_SpawnModule]call HBQSS_fnc_getNearUnits;
private _nearestOtherSide = _NearUnits select 0;
private _nearestSameSide = _NearUnits select 1;
if (isNil {_nearestOtherSide}) exitWith {true};
if (count _nearestOtherSide == 0 ) exitWith {true};
private _CenterOfEnemies = [_nearestOtherSide]call HBQSS_fnc_getCenter;
private _EngagePosition = [];
private _sumPositions = getPosATL _Leader vectorAdd (_CenterOfEnemies);
private _MiddlePosition =_sumPositions vectorMultiply (1 / 2);

// Tweak these for Performance
private _EngageTacticRadius = 250;
private _EngageTacticIterations = 30; 

/// Engage Tactics
if (_FinalEngageTactic == "RANDOM") then {_FinalEngageTactic = selectRandom ["HIGHGROUND","LOWGROUND","FOREST","DIRECT","URBAN"];};
private _randomLocations = [];
for "_i" from 1 to _EngageTacticIterations do {
	_randomLocation = [[[_MiddlePosition, _EngageTacticRadius]], []] call BIS_fnc_randomPos; 
	_randomLocations = _randomLocations + [_randomLocation];
};

if (_FinalEngageTactic == "HIGHGROUND") then {
	_EngagePosition = _randomLocations select ([_randomLocations]call HBQSS_fnc_FindHighestPosition);	
	_randomLocations = nil; //delete Variable to safe Memory
};

if (_FinalEngageTactic == "LOWGROUND") then {
	_EngagePosition = _randomLocations select ([_randomLocations]call HBQSS_fnc_FindLowestPosition);	
	_randomLocations = nil; //delete Variable to safe Memory
};

if (_FinalEngageTactic == "FOREST") then {
	_EngagePosition = _randomLocations select ([_randomLocations]call HBQSS_fnc_FindForestPosition);	
	_randomLocations = nil; //delete Variable to safe Memory
};

if (_FinalEngageTactic == "URBAN") then {
	_EngagePosition = _randomLocations select ([_randomLocations]call HBQSS_fnc_FindUrbanArea);	
	_randomLocations = nil; //delete Variable to safe Memory
};

if (_FinalEngageTactic == "DIRECT") then {_EngagePosition append _MiddlePosition;};

if (_SpawnType == "TRANSPORT" or  _SpawnType == "NAVALTRANSPORT" or _SpawnType == "AIRTRANSPORT") then {sleep 5;};

// If DoFollow check get nearest Group Leader that is not in Vehicle and is not the Same Group as this
if (_DoFollow) exitWith {
	_ToFollowGroup = grpNull;
	// Find Group to Follow
	{
		if (_x distance _Leader < 80 and leader _x != _Leader and isNull objectParent leader _x ) exitWith {_ToFollowGroup = group _x};
	} foreach _nearestSameSide;
	// Follow the Other Group with x Meter separation
	[_group,_ToFollowGroup,120,20,_debug,true,_TaskCancelDelay,_TaskResetTriggerObj]spawn HBQSS_fnc_Follow;
};

if (_debug) then {
	//// Draw Debug Move Line
	if (isNil {(getPos _Leader) select 0} or isNil {_EngagePosition select 0}) exitWith {};
	private _Polyline_x1 = (getPos _Leader) select 0;
	private _Polyline_y1 = (getPos _Leader) select 1;
	private _Polyline_x2 = _EngagePosition select 0;
	private _Polyline_y2 = _EngagePosition select 1;
	[_Leader,[0.2,0.2],120,"ColorBlue",0.5,[_Polyline_x1,_Polyline_y1],[_Polyline_x2,_Polyline_y2]] spawn HBQSS_fnc_CreateDebugLine;
};
{
	doStop _x;
	sleep 0.2;
	_x doFollow _x;
	_x domove [_EngagePosition select 0,_EngagePosition select 1,0];
}foreach units _group;

private _wpt1 = _group addWaypoint [[_EngagePosition select 0,_EngagePosition select 1,0], 0];
private _wpt2 = _group addWaypoint [[_CenterOfEnemies select 0,_CenterOfEnemies select 1,0], 0];
private _wpt3 = _group addWaypoint [[_CenterOfEnemies select 0,_CenterOfEnemies select 1,0], 0];
_wpt3 setWaypointType "SAD";

// Stealth Engagement
if (_StealthEngagement) then {
	_wpt1 setWaypointCombatMode "GREEN";
	_wpt2 setWaypointBehaviour "STEALTH"; 
	_wpt2 setWaypointCombatMode "GREEN"; 
};
_wpt1 setWaypointSpeed "NORMAL";
_wpt1 setWaypointBehaviour "AWARE";

[_group,[_CenterOfEnemies select 0,_CenterOfEnemies select 1,0],_debug,_SpawnModule] spawn {
	params ["_group","_tagetpos","_debug","_SpawnModule"];
	waituntil {
		sleep 10;
		if (isNull (leader _group)) exitWith {true};
		(leader _group) distance2d _tagetpos < 50
	};
	_group setVariable ["HBQ_IsEngaging",false];
	_group setVariable ["HBQ_ReachedTargetPos",false];
	if (_debug) then {format ["%1: Engagement Canceled. ", _SpawnModule] remoteExec ["systemchat", 0]};
};

// DEBUG
if (_debug) then {
	/// MARKER TACTIC 
	_markerName = str random 99999999;
	_marker = createMarker [_markerName, _EngagePosition];
	_marker setMarkerShape "ICON";
	_marker setMarkerSize [0.2,0.2];
	_marker setMarkerColor "ColorRed";
	_marker setMarkerType "mil_objective_noShadow"; 
	_marker setMarkerAlpha 0.6;
	_marker setMarkerText _FinalEngageTactic;
	/// MARKER TARGETPOS 
	_markerName = str random 99999999;
	_marker2 = createMarker [_markerName, _CenterOfEnemies];
	_marker2 setMarkerShape "ICON";
	_marker2 setMarkerSize [0.4,0.4];
	_marker2 setMarkerColor "ColorRed";
	_marker2 setMarkerType "mil_objective_noShadow"; 
	_marker2 setMarkerAlpha 0.6;
	_marker2 setMarkerText "Engage!";
	sleep 150;
	deleteMarker _marker;
	deleteMarker _marker2;
};