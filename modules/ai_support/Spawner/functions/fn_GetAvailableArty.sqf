#include "script_component.hpp"
params ["_Spottergroup","_RadioRange"];
private _SelectedArty = objnull;
private _AllVehicles = vehicles;

private _AllUnitsSide = units (side _Spottergroup);
//private _VehiclesInRange = _AllVehicles select {_x distance2d (leader _Spottergroup) < _RadioRange };
private _AllUnitsInRange = _AllUnitsSide select {_x distance2d (leader _Spottergroup) < _RadioRange };
		
_AvailableArtilleryVehicles = _AllUnitsInRange select {
((group _x) getVariable ["HBQ_isArtillery",false] ) == true && (group _x) getVariable ["HBQ_artySpot_roundsFired",0] < (group _x) getVariable ["HBQ_Maxrounds",32] && (group _x) getVariable ["HBQ_arty_availForMission",true]
};
_AvailableArtilleryVehicles = _AvailableArtilleryVehicles apply { [_x distance (leader _Spottergroup), _x] };
_AvailableArtilleryVehicles sort true;
if (count _AvailableArtilleryVehicles != 0) then {_SelectedArty = _AvailableArtilleryVehicles select 0 select 1;};


_SelectedArty