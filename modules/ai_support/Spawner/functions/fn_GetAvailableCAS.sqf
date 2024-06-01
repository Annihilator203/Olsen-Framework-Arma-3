#include "script_component.hpp"
params ["_Spottergroup","_RadioRange"];
private _SelectedAirVeh = objnull;
private _AllVehicles = vehicles;
private _VehiclesInRange = _AllVehicles select {_x distance2d (leader _Spottergroup) < _RadioRange };
	
	
_AvailableCASVehicles = _VehiclesInRange select {((group _x) getVariable ["HBQ_IsCas",false] ) == true && _x isKindof "Air" && (group _x) getVariable ["HBQ_arty_availForMission",true]};

_AvailableCASVehicles = _AvailableCASVehicles apply { [_x distance (leader _Spottergroup), _x] };
_AvailableCASVehicles sort true;
if ((count _AvailableCASVehicles) != 0) then {_SelectedAirVeh = _AvailableCASVehicles select 0 select 1;};
_SelectedAirVeh