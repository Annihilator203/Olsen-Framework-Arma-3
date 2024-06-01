#include "script_component.hpp"
params["_unit","_HideChance","_RebelChance","_debug"];
if (side _unit != civilian) exitWith {false};

if (random 1 <= _HideChance) then {
	if (random 1 <= _RebelChance) then {

		_unit addEventHandler ["FiredNear", {
			params ["_unit", "_firer"];
			if !(alive _unit) exitWith {};
			private _RebelWeapon = (group _unit) getVariable "HBQ_RebelWeapon";
			private _RebelMagazine = (group _unit) getVariable "HBQ_RebelMagazine";
			private _Vcom = (group _unit) getVariable "HBQ_Vcom";
			private _Lambs = (group _unit) getVariable "HBQ_Lambs";
			private _DCO_SFSM = (group _unit) getVariable "HBQ_DCO_SFSM";
			[_unit, _RebelWeapon, _RebelMagazine, _Vcom, _Lambs,_DCO_SFSM] spawn HBQSS_fnc_Rebel;
			_unit removeEventHandler [_thisEvent, _thisEventHandler];
		}];
	} else {

		_unit addEventHandler ["FiredNear", {
			params ["_unit"];
			if !(alive _unit) exitWith {};
			private _DespawnSecurityRadius = (group _unit) getVariable "HBQ_DespawnSecurityRadius";
			private _CheckWatchDirection = (group _unit) getVariable "HBQ_CheckWatchDirection";
			private _debug = (group _unit) getVariable ["HBQ_debug",false];
			private _SpawnModule = (group _unit) getVariable ["HBQ_SpawnedBy",objnull];
			[_unit, _DespawnSecurityRadius,_debug,_CheckWatchDirection,false,1,_Spawnmodule] spawn HBQSS_fnc_FleeHide;
			_unit removeEventHandler [_thisEvent, _thisEventHandler];
		}];
	};
} else {
	if (random 1 <= _RebelChance) then {

		_unit addEventHandler ["FiredNear", {
			params ["_unit", "_firer"];
			if !(alive _unit) exitWith {};
			private _RebelWeapon = (group _unit) getVariable "HBQ_RebelWeapon";
			private _RebelMagazine = (group _unit) getVariable "HBQ_RebelMagazine";
			private _Vcom = (group _unit) getVariable "HBQ_Vcom";
			private _Lambs = (group _unit) getVariable "HBQ_Lambs";
			private _DCO_SFSM = (group _unit) getVariable "HBQ_DCO_SFSM";
			[_unit, _RebelWeapon, _RebelMagazine, _Vcom, _Lambs,_DCO_SFSM] spawn HBQSS_fnc_Rebel;
			_unit removeEventHandler [_thisEvent, _thisEventHandler];
		}];
	};
};