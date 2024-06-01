#include "script_component.hpp"
params ["_Vehicle"];
private _Crew = crew _Vehicle;
private _Cargo = _Crew select {assignedVehicleRole _x select 0 == "cargo"};
private _CargoUnmounted = false;
if (count _Cargo == 0) then {_CargoUnmounted = true};
_CargoUnmounted