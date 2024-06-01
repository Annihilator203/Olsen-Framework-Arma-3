#include "script_component.hpp"
params["_group"];
private _GroupHasCommands = true;
private  _UnitsWithNoCommands = (units _group) select {moveToCompleted _x};
if ((count _UnitsWithNoCommands) == (count units _group)) then {_GroupHasCommands = false};

_GroupHasCommands

