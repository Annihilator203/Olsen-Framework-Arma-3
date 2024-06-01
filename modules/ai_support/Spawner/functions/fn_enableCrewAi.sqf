#include "script_component.hpp"
// Unhide and Enable Simulation and AI Features with a Delay
params["_unit","_AI_FeatureActivationDelay","_StaticAI","_ShutUp","_Raycasting","_SpawnPosition","_SpawnType","_SetFormationPosition",
"_SpawnedVehicle","_SpawnDirection","_RushTargetPosition","_SpawnModule","_SyncedArtyModule","_UseOptimizedSpawnMethod","_Lambs","_DCO_SFSM"];


if !(_RushTargetPosition) then {
_unit setVariable ["lambs_danger_disableAI", not _Lambs];
//(group _unit) setVariable ["Vcm_Disable",not ((group _unit) getVariable "HBQ_Vcom")]; 
//(group _unit) setVariable ["lambs_danger_disableGroupAI",not ((group _unit) getVariable "HBQ_Lambs")];
_unit setVariable ["SFSM_excluded", _DCO_SFSM];
};


private _AI_NewFeatureActivationDelay = (_AI_FeatureActivationDelay/6);
sleep _AI_NewFeatureActivationDelay;

if (_UseOptimizedSpawnMethod) then {

_unit enableAI "ANIM";
sleep _AI_NewFeatureActivationDelay;
_unit enableAI "ALL";
sleep _AI_NewFeatureActivationDelay;
_unit enableSimulationGlobal true;

};


if (_ShutUp) then {
	_unit disableConversation true;
	_unit disableAI "RADIOPROTOCOL";
} else {
	_unit disableConversation false;
	_unit enableAI "RADIOPROTOCOL";
};



if (! isNull _SyncedArtyModule ) then {
	if (_SyncedArtyModule getVariable ["DisableArtyAI",false]) then {
	_unit setVariable ["SFSM_excluded", true];
	_unit setVariable ["lambs_danger_disableAI", true];
	_unit disableAI "AUTOCOMBAT";
	_unit disableAI "AUTOTARGET";
	_unit disableAI "TARGET";
	};
};


if !(_Raycasting) then {_unit disableAI "CHECKVISIBLE"};

/* 
 if (not _isCrew) then {
	if (_SpawnType == "TRANSPORT" or _SpawnType == "NAVALTRANSPORT" or _SpawnType == "AIRTRANSPORT") then {
		_unit assignasCargo _SpawnedVehicle; 
		_unit moveInCargo _SpawnedVehicle;
	} else {

		_unit setDir _SpawnDirection;
		_unit setFormDir _SpawnDirection;
		
		if (_SetFormationPosition) then {
			private _formationPos = formationPosition _unit;
			_formationPos set [2, 0];
			_unit setPosATL _formationPos;
		} else {
			_unit setPos _SpawnPosition;
		};
	}; */


if (_UseOptimizedSpawnMethod) then {
sleep _AI_NewFeatureActivationDelay;
_unit hideObjectGlobal false;
sleep _AI_NewFeatureActivationDelay;
};

if (_StaticAI) then {_unit disableAI "PATH"} else {_unit enableAI "PATH"};

_unit setVariable ["HBQ_SpwnFin", true];