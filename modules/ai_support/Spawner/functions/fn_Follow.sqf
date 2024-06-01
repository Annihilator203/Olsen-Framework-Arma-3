params ["_group","_toFollowGroup","_distance","_sleep","_debug","_UseHighPosition","_TaskCancelDelay","_TaskResetTriggerObj"];
private _startTime = time;
private _currentTime = time;
if (_TaskCancelDelay <= 0) then {_TaskCancelDelay = 3600};

while { (_currentTime - _startTime) < _TaskCancelDelay and not triggerActivated _TaskResetTriggerObj } do
{
	if (isNull _group) exitWith {};
	if (count units _group == 0) exitWith {};
	_currentTime = time;
	if (_group getVariable "HBQ_IsFleeing") exitWith {true};

	// DELETE WAYPOINTS
	if(count waypoints (leader _group) > 0) then {
		{deleteWaypoint((waypoints (leader _group))select 0);}forEach waypoints (leader _group);
	};
	
	private _currentPosition = getPos (leader _group);
	private _FollowGroupPosition = getPos (leader _toFollowGroup);

	private _sumPositions = _currentPosition vectorAdd (_FollowGroupPosition);
	private _ToFollowPosition = [];
	
	if (_UseHighPosition) then {
	
		//FindHighPosition
		private _MiddlePosition =_sumPositions vectorMultiply (1 / 2);
		private _randomLocations = [];
		for "_i" from 1 to 30 do {
			_randomLocation = [[[_MiddlePosition, 50]], []] call BIS_fnc_randomPos; 
			_randomLocations = _randomLocations + [_randomLocation];
		};
		
		_ToFollowPosition = _randomLocations select ([_randomLocations]call HBQSS_fnc_FindHighestPosition);

	} else {
		_ToFollowPosition =_sumPositions vectorMultiply (1 / 2);
	};
	
	if (isNil {leader _toFollowGroup}) exitWith {true};
      if ((leader _group) distance (leader _toFollowGroup) > _distance) then
      {
            if !(isNull (objectParent (leader _group))) then {{_x doMove _ToFollowPosition } forEach units _group;} else {
				//(leader _group) doMove _ToFollowPosition;

				// CREATE  WAYPOINT
				private _wpt = _group addWaypoint [_ToFollowPosition, -1];
				_wpt setWaypointType "MOVE";
			};
	  };
	if (_debug) then {
		[_ToFollowPosition, "","ICON","mil_destroy",[0.5,0.5],_sleep,"ColorRed",1,0,"SolidBorder",false,[0,0],[0,0]] spawn HBQSS_fnc_CreateDebugMarker; /// Create Last WayPointMarker (Bigger with Text)
	};
    sleep _sleep + (random 10);
};