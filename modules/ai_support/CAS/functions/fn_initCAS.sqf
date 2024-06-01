#include "script_component.hpp"
if (!isServer) exitWith {}; 

_this spawn { 
	/*
params["_CASModule"];
private _SyncedGroups = [];

private _SyncedObjs = synchronizedObjects _CASModule;
_SyncedUnits = _SyncedObjs select {_x isKindOf "AllVehicles"};
{_SyncedGroups = _SyncedGroups + [group _x];} forEach _SyncedUnits;

*/
params["_x"];

	group _x setVariable ["HBQ_IsCas",true,true];
	group _x setVariable ["HBQ_arty_availForMission",GVAR(casAvail),true];
	
	group _x setVariable ["HBQ_CasAttackDistance",GVAR(casAttackDist),true];

	group _x setVariable ["HBQ_MissilePrecision",GVAR(casAcc),true];
	group _x setVariable ["HBQ_RequestedMissiles",GVAR(numMissiles),true];
	group _x setVariable ["HBQ_MissilesDelay",GVAR(delay),true];
	
	group _x setVariable ["HBQ_ArtyCoolDown",GVAR(cooldown),true];
	group _x setVariable ["HBQ_UsePylon",GVAR(usePylon),true];
	
	
	group _x setVariable ["HBQ_CasSearchDistance",GVAR(searchDistance),true];
	group _x setVariable ["HBQ_MaxMissionTime",GVAR(maxTime),true];
	group _x setVariable ["HBQ_FlyHight",GVAR(flyHeight),true];
	group _x setVariable ["TCL_Disabled", true];
	group _x setVariable ["lambs_danger_enableGroupReinforce", false,true];
	group _x setVariable ["Vcm_Disable",true];
	group _x setVariable ["lambs_danger_disableGroupAI", true];
	//[_x, "NoAI", true] call PZAI_fnc_setInit;
};

	
// } forEach _SyncedGroups;


//};


