#include "script_component.hpp"
params ["_position","_group"];
private _Helipad = createVehicle ["Land_HelipadEmpty_F", [_position select 0,_position select 1,0], [], 0, "CAN_COLLIDE"];

waitUntil {
	sleep 2;
	if (isNull _group) exitWith {true};
	if (isNull _Helipad) exitWith {true};
	_group getVariable ["HBQ_ReachedTargetPos",true]
};
sleep 180;
if (!isNull _Helipad) then {deleteVehicle _Helipad;};