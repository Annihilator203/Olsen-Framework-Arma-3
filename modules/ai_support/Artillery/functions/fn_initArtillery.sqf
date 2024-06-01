#include "script_component.hpp"
if (!isServer) exitWith {}; 

_this spawn { 
params["_ArtilleryModule"];
private _SyncedGroups = [];

private _SyncedObjs = synchronizedObjects _ArtilleryModule;
_SyncedUnits = _SyncedObjs select {_x isKindOf "AllVehicles"};
{_SyncedGroups = _SyncedGroups + [group _x];} forEach _SyncedUnits;

{
	_x setVariable ["HBQ_TypeOfShells",_ArtilleryModule getVariable ["TypeOfShells",""],true];
	_x setVariable ["HBQ_RequestedRounds",_ArtilleryModule getVariable ["RequestedRounds",5],true];
	_x setVariable ["HBQ_RoundsDelay",_ArtilleryModule getVariable ["RoundsDelay",5],true];
	_x setVariable ["HBQ_ArtillerySpread",_ArtilleryModule getVariable ["ArtillerySpread",200],true];
	_x setVariable ["HBQ_ArtyCoolDown",_ArtilleryModule getVariable ["cooldown",180],true];
	_x setVariable ["HBQ_VanillaArty",_ArtilleryModule getVariable ["VanillaArty",false],true];
	
	_x setVariable ["HBQ_isArtillery",true,true];
	_x setVariable ["HBQ_arty_availForMission",true,true];
	_x setVariable ["HBQ_artySpot_roundsFired", 0, true];
	_x setVariable ["HBQ_Maxrounds",_ArtilleryModule getVariable ["MaxRounds",32],true];
	if (_ArtilleryModule getVariable ["DisableArtyAI",false]) then {
		_x setVariable ["TCL_Disabled", true];
		_x setVariable ["lambs_danger_enableGroupReinforce", false,true];
		_x setVariable ["Vcm_Disable",true];
		_x setVariable ["lambs_danger_disableGroupAI", true];

		{	
			_x setVariable ["SFSM_excluded", true];
			_x setVariable ["lambs_danger_disableAI", true];
			_x disableAI "AUTOCOMBAT";
			_x disableAI "AUTOTARGET";
			_x disableAI "TARGET";
		} forEach units _x;

	};

	
} forEach _SyncedGroups;


};
