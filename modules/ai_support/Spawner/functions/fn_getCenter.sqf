params [
	["_entities", [], [[]]] // array of positions, objects, markers, groups or locations
];
private _sumPositions = [];
if (_entities isEqualTo []) exitWith { _sumPositions };
{
	_sumPositions = _sumPositions vectorAdd (_x call BIS_fnc_position);
} forEach _entities;

// return center position
_sumPositions vectorMultiply (1 / count _entities);