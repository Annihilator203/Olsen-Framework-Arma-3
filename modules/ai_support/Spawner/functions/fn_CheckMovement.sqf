params["_unit","_MovePosition"];
// Check ob Einheit sich bewegt und erzeuge Waypoint wenn nicht.
private _currentUnitPos = position _unit;
private _NewPos = [0,0,0];
sleep 10;
while {_currentUnitPos distance2d _NewPos > 10 and alive _unit} do {
	_currentUnitPos = position _unit;
	sleep 10;
	_NewPos = position _Unit;
};

if (isNull _unit) exitWith {true};
(group _unit) addWaypoint [_MovePosition, 0];
_unit doMove _MovePosition;
_unit MoveTo _MovePosition;