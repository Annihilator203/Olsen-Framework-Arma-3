#include "script_component.hpp"
params ["_Spottergroup","_NearEntity"];


private _MinTargetSize = GVAR(minTargetSize);
//private _NearOtherEntity = _NearEntity nearEntities ["man",100]; // There need to be other Targets in this Range in order to make it a valid Target.
private _NearOtherEntity  = ([getpos _NearEntity,side _NearEntity,100,false]call HBQSS_fnc_getNearUnits) select 1;

if (!(_NearEntity isKindOf "LandVehicle") and !( _NearEntity isKindOf "man")) exitWith {false};
if (!alive _NearEntity) exitWith {false};
if (((leader _Spottergroup) knowsAbout _NearEntity) <= 1.5) exitWith {false};
if ((count _NearOtherEntity) >= _MinTargetSize) exitWith {true};
if !(isNull objectParent _NearEntity) exitWith {true};
if (_NearEntity isKindOf "LandVehicle") exitWith {true};
if ((count _NearOtherEntity) < _MinTargetSize) exitWith {
//if (_debug) then {format ["%1: Target to small for Support Mission.", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};
false
};
false
