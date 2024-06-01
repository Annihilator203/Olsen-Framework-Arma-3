#include "script_component.hpp"
params["_group","_MovePosition","_patrol","_PatrolRadius","_SpawnType","_debug","_HotZone","_SpawnDirection","_SpawnAngle",
"_SpawnPosObj","_Paradrop","_GroupSizeFinal","_LoiterRadius","_SpawnModule","_Vcom","_CreateWPs"];

/// Variables
private _SyncronizedMovepositions = [];
private _WayPoints = [];
private _SyncronizedObjs = [];
private _SyncronizedObjs_WayPoint_1 = [];
private _SyncronizedMovePos_WayPoint_1 = [];
private _SyncronizedObjs_WayPoint_2 = [];
private _SyncronizedMovePos_WayPoint_2 = [];
private _WayPointPos_1 = ObjNull;
private _WayPointPos_2 = ObjNull;
private _WayPointPos_3 = ObjNull;
private _WayPointPos_4 = ObjNull;
private _WayPointPos_5 = ObjNull;
private _WayPointPos_6 = ObjNull;
private _WayPointPos_7 = ObjNull;
private _WayPointPos_8 = ObjNull;
private _WayPointPos_9 = ObjNull;
private _WayPointPos_10 = ObjNull;


// CUSTOM INIT CODE CARGITEM
//private _CustomTargetPosCode = [_SpawnModule getVariable ["CustomTargetPosCode",""],"spawnedItem","(_this select 0)"]call HBQSS_fnc_stringReplace;
private _CustomTargetPosCode = _SpawnModule getVariable ["CustomTargetPosCode",""];





///// WAYPOINT 1
_SyncronizedObjs = synchronizedObjects _SpawnPosObj;
_SyncronizedMovepositions =_SyncronizedObjs select {typeOf _x == "HBQ_MovePosition";};
if (count _SyncronizedMovepositions > 0 ) then { 
	_WayPointPos_1 = selectRandom _SyncronizedMovepositions;
	_WayPoints = _WayPoints +[_WayPointPos_1];
} else {
	_WayPoints = _WayPoints + [_MovePosition];
};

///// WAYPOINT 2
if !(isNull _WayPointPos_1) then {
	_SyncronizedObjs_WayPoint_1 = synchronizedObjects _WayPointPos_1;
	_SyncronizedMovePos_WayPoint_1 =_SyncronizedObjs_WayPoint_1 select {typeOf _x == "HBQ_MovePosition";};

	if (count _SyncronizedMovePos_WayPoint_1 > 0 )then { 
		_SyncronizedObjs_WayPoint_2 = synchronizedObjects _WayPointPos_1;
		_SyncronizedMovePos_WayPoint_2 =_SyncronizedObjs_WayPoint_2 select {typeOf _x == "HBQ_MovePosition";};
		_WayPointPos_2 = selectRandom _SyncronizedMovePos_WayPoint_2;
		if !(isNull _WayPointPos_2) then {
			_WayPoints = _WayPoints + [_WayPointPos_2];
		};
	};
};

///// WAYPOINT 3
if !(isNull _WayPointPos_2) then {
	if (count ([_WayPointPos_2]call HBQSS_fnc_GetSyncedMovePositions) > 0 )then { 
		_WayPointPos_3 = selectRandom ([_WayPointPos_2]call HBQSS_fnc_GetSyncedMovePositions);
		if !(isNull _WayPointPos_3) then {_WayPoints = _WayPoints + [_WayPointPos_3];};
	};
};

///// WAYPOINT 4
if !(isNull _WayPointPos_3) then {
	if (count ([_WayPointPos_3]call HBQSS_fnc_GetSyncedMovePositions) > 0 )then { 
		_WayPointPos_4 = selectRandom ([_WayPointPos_3]call HBQSS_fnc_GetSyncedMovePositions);
		if !(isNull _WayPointPos_4) then {_WayPoints = _WayPoints + [_WayPointPos_4];};
	};
};

///// WAYPOINT 5
if !(isNull _WayPointPos_4) then {
	if (count ([_WayPointPos_4]call HBQSS_fnc_GetSyncedMovePositions) > 0 )then { 
		_WayPointPos_5 = selectRandom ([_WayPointPos_4]call HBQSS_fnc_GetSyncedMovePositions);
		if !(isNull _WayPointPos_5) then {_WayPoints = _WayPoints + [_WayPointPos_5];};
	};
};

///// WAYPOINT 6
if !(isNull _WayPointPos_5) then {
	if (count ([_WayPointPos_5]call HBQSS_fnc_GetSyncedMovePositions) > 0 )then { 
		_WayPointPos_6 = selectRandom ([_WayPointPos_5]call HBQSS_fnc_GetSyncedMovePositions);
		if !(isNull _WayPointPos_6) then {_WayPoints = _WayPoints + [_WayPointPos_6];};
	};
};

///// WAYPOINT 7
if !(isNull _WayPointPos_6) then {
	if (count ([_WayPointPos_6]call HBQSS_fnc_GetSyncedMovePositions) > 0 )then { 
		_WayPointPos_7 = selectRandom ([_WayPointPos_6]call HBQSS_fnc_GetSyncedMovePositions);
		if !(isNull _WayPointPos_7) then {_WayPoints = _WayPoints + [_WayPointPos_7];};
	};
};

///// WAYPOINT 8
if !(isNull _WayPointPos_7) then {
	if (count ([_WayPointPos_7]call HBQSS_fnc_GetSyncedMovePositions) > 0 )then { 
		_WayPointPos_8 = selectRandom ([_WayPointPos_7]call HBQSS_fnc_GetSyncedMovePositions);
		if !(isNull _WayPointPos_8) then {_WayPoints = _WayPoints + [_WayPointPos_8];};
	};
};

///// WAYPOINT 9
if !(isNull _WayPointPos_8) then {
	if (count ([_WayPointPos_8]call HBQSS_fnc_GetSyncedMovePositions) > 0 )then { 
		_WayPointPos_9 = selectRandom ([_WayPointPos_8]call HBQSS_fnc_GetSyncedMovePositions);
		if !(isNull _WayPointPos_9) then {_WayPoints = _WayPoints + [_WayPointPos_9];};
	};
};
 
///// WAYPOINT 10
if !(isNull _WayPointPos_9) then {
	if (count ([_WayPointPos_9]call HBQSS_fnc_GetSyncedMovePositions) > 0 )then { 
		_WayPointPos_10 = selectRandom ([_WayPointPos_9]call HBQSS_fnc_GetSyncedMovePositions);
		if !(isNull _WayPointPos_10) then {_WayPoints = _WayPoints + [_WayPointPos_10];};
	};
};


// IF first and last Waypoint is close together enable Circle Patrol. (Makes Patrol follow Waypoints in a Circle)
private _CirclePatrol = false;
if (((_WayPoints select 0) distance2d (_WayPoints select -1)) < 20) then {_CirclePatrol = true};

/// SIMPLE PATROL (Add all Waypoints again in Reverted order) 

if (_patrol == "SIMPLE PATROL" and !_CirclePatrol) then {
	private _RevertedWaypoints = [];
	
	{
		_RevertedWaypoints = _RevertedWaypoints + [_x];
	} forEach _Waypoints;
	
	
	reverse _RevertedWaypoints;
	
	_WayPoints append _RevertedWaypoints;

	

};



/// Define LastWaypoint
private _LastWaypoint = _WayPoints select -1;


if (_CreateWPs) then {


	//// DEBUG POLYLINE MARKER FIRST LINE
	if (_debug) then {
		_Polyline_x1=(getPos (_WayPoints select 0)) select 0;
		_Polyline_y1=(getPos (_WayPoints select 0)) select 1;
		_Polyline_x2=(getPos (leader _group )) select 0;
		_Polyline_y2=(getPos (leader _group)) select 1;
		[_SpawnModule,[0.2,0.2],120,"ColorBlue",0.5,[_Polyline_x1,_Polyline_y1],[_Polyline_x2,_Polyline_y2]] spawn HBQSS_fnc_CreateDebugLine;
	};

	// SIMPLE PATROL WAYPOINT
	if (_patrol == "SIMPLE PATROL") then {
		private _wptFirst = _group addWaypoint [getPos leader _group, 0];
		_wptFirst setWaypointType "MOVE";
	};

	/// ForEach Waypoint
	{
		// DEBUG
		//create Debug Marker Move Position
		if (_debug) then {
			if (_forEachIndex == ((count _WayPoints)-1)) then { /// Last Waypoint check
				[getPos _x, "","ICON","mil_objective_noShadow",[0.5,0.5],120,"ColorRed",1,0,"SolidBorder",false] spawn HBQSS_fnc_CreateDebugMarker; /// Create Last WayPointMarker (Bigger with Text)
			} else {
				[getPos _x, "","ICON","Waypoint",[0.5,0.5],120,"ColorRed",1,0,"SolidBorder",false] spawn HBQSS_fnc_CreateDebugMarker;  /// Create WayPointMarker
			};
			//// Draw Debug Move Line
			_Polyline_x1=(getPos (_WayPoints select (_forEachIndex+ 1))) select 0;
			_Polyline_y1=(getPos (_WayPoints select (_forEachIndex+ 1))) select 1;
			_Polyline_x2=(getPos (_WayPoints select _forEachIndex)) select 0;
			_Polyline_y2=(getPos (_WayPoints select _forEachIndex)) select 1;

			if not(isNil {_Polyline_x1}) then { 
				[_SpawnModule,[0.2,0.2],120,"ColorBlue",0.5,[_Polyline_x1,_Polyline_y1],[_Polyline_x2,_Polyline_y2]] spawn HBQSS_fnc_CreateDebugLine;
			};
		}; // Debug End

		private _wptpos = getPosATL _x;
		private _Radius = 0;
		if (_SpawnType == "NAVALTRANSPORT") then {_wptpos = getPos _x;_Radius = -1};
		private _wpt = _group addWaypoint [_wptpos,_Radius];
		_wpt setWaypointType "MOVE";
		
		private _Statement = "(group this) setVariable ['HBQ_ReachedTargetPos',true,true]; ";
		if (_CustomTargetPosCode != "") then { 
		_Statement = _Statement + _CustomTargetPosCode;
		
		};

		if (_forEachIndex == ((count _WayPoints)-1)) then {
			_wpt setWaypointStatements ["true", _Statement];
		};

		if (_forEachIndex == ((count _WayPoints)-1) && (!(_SpawnType == "TRANSPORT" or _SpawnType == "NAVALTRANSPORT" or _SpawnType == "AIRTRANSPORT")) && _SpawnModule getVariable ["SearchDestroy",false]) then {
		_wpt setWaypointType "SAD";
		};



	   


		if (_forEachIndex == ((count _WayPoints)-1) and (_SpawnType == "TRANSPORT" or _SpawnType == "NAVALTRANSPORT" or _SpawnType == "AIRTRANSPORT") and _Paradrop == false) then {
			if (_GroupSizeFinal != 0 && _patrol != "SIMPLE PATROL") then {_wpt setWaypointType "TR UNLOAD"};
			if (_SpawnType == "NAVALTRANSPORT") then {_wpt setWaypointCompletionRadius 0};
		};
		
		if (_forEachIndex == ((count _WayPoints)-1) and (_SpawnType == "AIRVEHICLES" or _SpawnType == "AIRTRANSPORT" or  _SpawnType == "AIRCARGOTRANSPORT") and _LoiterRadius > 0 ) then {
			_wpt setWaypointType "LOITER";
			_wpt setWaypointLoiterRadius _LoiterRadius;
		};

		// Add Extra Waypoint at TagetPosition (To prevent Vcom from overwriting the Waypoint)
		if (_forEachIndex == (count _WayPoints)-1 && _Vcom && _patrol == "NONE" && _LoiterRadius <= 0) then {
			private _wptDouble = _group addWaypoint [getPos _x, 0];
			_wptDouble setWaypointType "MOVE";
			
		};
		
		if (_patrol == "SIMPLE PATROL") then {
			if (_forEachIndex == (count _WayPoints)-1) then {
				private _wptCycle = _group addWaypoint [getPos _x, 0];
				_wptCycle setWaypointType "CYCLE";	
			};
		};	
	} forEach _WayPoints;
	
	
	
	



	if (isNull _SpawnModule) exitWith {_LastWaypoint};
	private _NewWaypoints = _SpawnModule getVariable "HBQ_SyncedMovePositions";

	_NewWaypoints insert [0, _WayPoints, true];
	_SpawnModule setVariable ["HBQ_SyncedMovePositions",_NewWaypoints,true];// PUBLIC ??



};


_LastWaypoint