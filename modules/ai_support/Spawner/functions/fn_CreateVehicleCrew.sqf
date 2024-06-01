#include "script_component.hpp"
params ["_VehicleData","_SpawnPosition","_Crewgroup","_LambsRadio",
"_UseOptimizedSpawnMethod","_SpawnModule","_AI_FeatureActivationDelay","_StaticAI",
"_ShutUp","_SpawnedVehicle","_Raycasting","_SpawnType","_RushTargetPosition",
"_CustomLoadout","_AllowDamageVehicle","_SyncedArtyModule","_SpawnDirection","_Lambs","_DCO_SFSM","_Behaviour"];

private _StartAirOnGround = _SpawnModule getVariable ["StartAirOnGround",false];
private _CrewData = _VehicleData select 0 select 0;

private _Skill = _VehicleData select 0 select 0 select 0 select 2;
private _StaticResetDelay = _SpawnModule getVariable ["StaticResetDelay",0];
private _TaskResetTrigger = _SpawnModule getVariable ["TaskResetTrigger",""];
private _TaskResetTriggerObj = missionNamespace getVariable [_TaskResetTrigger , objNull];
private _Loadout = [];

createVehicleCrew _SpawnedVehicle;
(crew _SpawnedVehicle) join _Crewgroup;
_Crewgroup addVehicle _SpawnedVehicle;


{
		if ((_forEachIndex) >= (count (_CrewData))) then {
			_Loadout = ((selectrandom _CrewData)  select 1);
			
		} else {
			_Loadout = (_CrewData select _forEachIndex select 1);
		};
	
	
	
	if (_CustomLoadout) then {_x setUnitLoadout _Loadout;};
	_x setVariable ["HBQ_SpwnFin", false];
	_x setVariable ["lambs_danger_dangerRadio", _LambsRadio];

	[_x,_Skill,_SpawnModule] spawn HBQSS_fnc_SetSkills;
	_x allowDamage _AllowDamageVehicle;
	_x  setBehaviour _Behaviour;
	if ((_SpawnType == "AIRVEHICLES" or _SpawnType == "AIRTRANSPORT"  or _SpawnType == "AIRCARGOTRANSPORT") && _StartAirOnGround) then {
		_x  setBehaviour "SAFE";
	};
	
	
	if (_UseOptimizedSpawnMethod) then {
		[_x] call HBQSS_fnc_DisableAI;
		[_x,_AI_FeatureActivationDelay,_StaticAI,_ShutUp,_Raycasting,_SpawnPosition,_SpawnType,false,_SpawnedVehicle,0,_RushTargetPosition,_SpawnModule,_SyncedArtyModule,_UseOptimizedSpawnMethod,_Lambs,_DCO_SFSM] spawn HBQSS_fnc_enableCrewAi;
	} else {
		[_x,0,_StaticAI,_ShutUp,_Raycasting,_SpawnPosition,_SpawnType,false,_SpawnedVehicle,0,_RushTargetPosition,_SpawnModule,_SyncedArtyModule,_UseOptimizedSpawnMethod,_Lambs,_DCO_SFSM] spawn HBQSS_fnc_enableCrewAi;
	};
	
	if ((_SpawnModule getVariable "HBQ_WaveBudget") > 0) then {
		_SpawnModule setVariable ["HBQ_WaveBudget",((_SpawnModule getVariable "HBQ_WaveBudget")-1),true]; // PUBLIC ??
	};
	
	/////////////////////// RESET STATIC AI ( Units will continue with Waypoints if they have any)
	if (_StaticResetDelay > 0 or !(isNull  _TaskResetTriggerObj)) then {
		[_x,_StaticResetDelay,_TaskResetTriggerObj,_SpawnModule] spawn HBQSS_fnc_ResetStaticAI;
	};

	
}foreach (units _Crewgroup);


