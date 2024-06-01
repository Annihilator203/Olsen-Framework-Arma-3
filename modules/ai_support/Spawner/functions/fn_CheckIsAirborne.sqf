#include "script_component.hpp"
params["_Vehicle"];
private _IsAirborne = false;
if ((getPos _Vehicle) select 2 > 5) then {_IsAirborne = true};
_IsAirborne