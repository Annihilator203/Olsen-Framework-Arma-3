#include "script_component.hpp"
params ["_group","_ChecksDelay","_SpawnModule","_LandPos"];
//private _TargetPosition = getPos _PosObj;
private _SpawnType = _SpawnModule getVariable ["HBQ_SpawnType",""];

waitUntil {
	sleep (_ChecksDelay/5);
	if (_SpawnType == "NAVALTRANSPORT")then {sleep 0.1} else {sleep 1};
	if (isNull _group) exitWith {true};
	if (isNull (leader _group)) exitWith {true};
	if !(alive (leader _group)) exitWith {true};
	if (count (units _group) == 0) exitWith {true};
	
	((leader _group) distance2d _LandPos) < 150
};

/// Land When TargetPosition is on Ground
if ( ((_LandPos select 2) < 5)  and  ((vehicle (leader _group)) isKindOf "Helicopter")) then {
	vehicle (leader _group) land "LAND";
};