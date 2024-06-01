params ["_group","_TagetPosition","_PatrolRadius","_TaskCancelDelay","_TaskResetTriggerObj","_SecondaryTargetPosObj","_debug","_SpawnModule"];

///// DELETE WAYPOINTS
if(count waypoints _group > 0) then {
	{deleteWaypoint((waypoints _group)select 0);}forEach waypoints _group;
};

//////  CREATE RANDOM WAYPOINTS

private _RandomPatrolPos_1 = _TagetPosition getPos [_PatrolRadius * (1 - abs random [- 1, 0, 1]), random (360)];
private _RandomPatrolPos_1_safe = [_RandomPatrolPos_1, 0, 70, 2, 0, 1, 0, [], [_TagetPosition]] call BIS_fnc_findSafePos;
private _wpt1 = _group addWaypoint [_RandomPatrolPos_1_safe, 0];
_wpt1 setWaypointType "MOVE";
_wpt1 setWaypointSpeed "LIMITED";
_wpt1 setWaypointFormation "COLUMN";
_wpt1 setWaypointBehaviour "SAFE";
//_wpt1 setWaypointCompletionRadius 5;

private _RandomPatrolPos_2 = _TagetPosition getPos[_PatrolRadius * (1 - abs random [- 1, 0, 1]), random (360)];
private _RandomPatrolPos_2_safe = [_RandomPatrolPos_2, 0, 70, 2, 0, 1, 0, [], [_TagetPosition]] call BIS_fnc_findSafePos;
private _wpt2 = _group addWaypoint [_RandomPatrolPos_2_safe, 0];
_wpt2 setWaypointType "MOVE";
_wpt2 setWaypointCompletionRadius 5;
private _RandomPatrolPos_3 = _TagetPosition getPos[_PatrolRadius * (1 - abs random [- 1, 0, 1]), random (360)];
private _RandomPatrolPos_3_safe = [_RandomPatrolPos_3, 0, 70, 2, 0, 1, 0, [], [_TagetPosition]] call BIS_fnc_findSafePos;
private _wpt3 = _group addWaypoint [_RandomPatrolPos_3_safe, 0];
_wpt3 setWaypointType "MOVE";
_wpt3 setWaypointCompletionRadius 5;
private _RandomPatrolPos_4 = _TagetPosition getPos[_PatrolRadius * (1 - abs random [- 1, 0, 1]), random (360)];
private _RandomPatrolPos_4_safe = [_RandomPatrolPos_4, 0, 70, 2, 0, 1, 0, [], [_TagetPosition]] call BIS_fnc_findSafePos;
private _wpt4 = _group addWaypoint [_RandomPatrolPos_4_safe, 0];
_wpt4 setWaypointType "MOVE";
_wpt4 setWaypointCompletionRadius 5;
private _RandomPatrolPos_5 = _TagetPosition getPos [_PatrolRadius * (1 - abs random [- 1, 0, 1]), random (360)];
private _RandomPatrolPos_5_safe = [_RandomPatrolPos_5, 0, 70, 2, 0, 1, 0, [], [_TagetPosition]] call BIS_fnc_findSafePos;
private _wpt5 = _group addWaypoint [_RandomPatrolPos_5_safe, 5];
_wpt5 setWaypointType "CYCLE";