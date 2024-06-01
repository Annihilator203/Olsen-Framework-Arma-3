#include "script_component.hpp"
params ["_Vehicle"];
private _isArmed = false;
if (!isNil{allTurrets [_Vehicle, false] select 0}) then {_isArmed = true};
_isArmed