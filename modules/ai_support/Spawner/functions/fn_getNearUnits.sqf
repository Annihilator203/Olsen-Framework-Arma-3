#include "script_component.hpp"
params ["_position","_Side","_distance","_UseTrigger"];

private _nearUnits = [];

if (_UseTrigger) then {
	private _ZoneTrigger = _SpawnModule getVariable ["ZoneTrigger",""];
	private _ZoneTriggerObj = missionNamespace getVariable [_ZoneTrigger , objNull];
	_nearUnits =  allUnits inAreaArray _ZoneTriggerObj;
} else {
	_nearUnits = _position nearEntities ["Man", _distance];
};

private _allVehiclesCrew = entities [["LandVehicle","Air"], ["Logic","EmptyDetector"], true, true];
private _NearVehiclesCrews = _allVehiclesCrew select {(_x distance2d _position)< _distance};
_nearUnits append _NearVehiclesCrews;

private _nearestOtherSide =[];
private _nearestSameSide =[];
private _nearDamagedUnits =[];
{
	if (side _x != _Side && side _x != civilian && !(isAgent teamMember _x) && damage _x < 0.5 && alive _x) then {
		_nearestOtherSide = _nearestOtherSide + [_x];
	};
	if (side _x == _Side && damage _x < 0.5 && alive _x) then {
		_nearestSameSide = _nearestSameSide + [_x];
	};
	
	
	
	//if (HBQSS_ACE_Loaded) then {
		if (side _x != _Side && !(isAgent teamMember _x) && (_x getVariable ["ACE_isUnconscious", false]) && alive _x) then {
			_nearDamagedUnits = _nearDamagedUnits + [_x];
		};
	/*} else {
		if (side _x != _Side && !(isAgent teamMember _x) && damage _x > 0.1 && alive _x) then {
			_nearDamagedUnits = _nearDamagedUnits + [_x];
		};
		*/
} forEach _nearUnits;
	
[_nearestOtherSide,_nearestSameSide,_nearDamagedUnits]