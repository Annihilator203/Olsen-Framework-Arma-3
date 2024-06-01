#include "script_component.hpp"
//Return true if Unit is in Vehicle
params ["_unit"];
private _isInVehicle = false;
if !(isNull objectParent _unit) then {_isInVehicle = true};
_isInVehicle