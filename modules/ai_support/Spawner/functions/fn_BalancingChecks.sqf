#include "script_component.hpp"
params ["_SpawnModule","_HotZone","_Side","_MaxUnconscious","_MinEnemiesInZone","_MaxFriendliesInZone","_ForcesBalancing","_debug"];
private _Spawncheck = false;
private _NearUnits = [];
private _nearestEnemies = [];
private _nearestFriendlies = [];
private _nearDamagedUnits = [];
private _ZoneTrigger = _SpawnModule getVariable ["ZoneTrigger",""];
private _ZoneTriggerObj = missionNamespace getVariable [_ZoneTrigger , objNull];
private _OnlyConsiderOwn = _SpawnModule getVariable ["OnlyConsiderOwn",false];

if (isNull _ZoneTriggerObj) then {
	_NearUnits = [_SpawnModule,_Side,_HotZone,false,_SpawnModule]call HBQSS_fnc_getNearUnits;
} else {
	_NearUnits = [_SpawnModule,_Side,_HotZone,true,_SpawnModule]call HBQSS_fnc_getNearUnits;
};

_nearestEnemies = _NearUnits select 0;
_nearestFriendlies = _NearUnits select 1;
_nearDamagedUnits = _NearUnits select 2;


if (_OnlyConsiderOwn) then {
_nearestFriendlies = _nearestFriendlies select {(group _x) getVariable ["HBQ_Spawnedby",objNull] == _SpawnModule};

};

if (_ForcesBalancing <= 0) then {_ForcesBalancing = 9999};

private _Balance = (count _nearestFriendlies + 0.01)/(count _nearestEnemies + 0.01) ;
if (count _nearestEnemies == 0) then {_Balance = 0};

if (count _nearestFriendlies < _MaxFriendliesInZone && count _nearestEnemies >= _MinEnemiesInZone && count _nearDamagedUnits < _MaxUnconscious && _Balance < _ForcesBalancing) then {
	_Spawncheck = true;
};
 
if !(_Spawncheck) then {
	_SpawnModule setVariable ["HBQ_SpawnsCheck", false]; // PUBLIC??
} else {
	_SpawnModule setVariable ["HBQ_SpawnsCheck", true]; // PUBLIC??
}; 

// DEBUG
if (_debug == true) then {
	format ["%1: Balancing (Friendlies/Enemies): %2", _SpawnModule,_Balance toFixed 1] remoteExec ["systemchat", TO_ALL_PLAYERS];
	format ["%1: Friendlies in Zone: %2", _SpawnModule,str count _nearestFriendlies] remoteExec ["systemchat", TO_ALL_PLAYERS];
	format ["%1: Unconscious Enemies: %2", _SpawnModule,str count _nearDamagedUnits] remoteExec ["systemchat", TO_ALL_PLAYERS];
	format ["%1: Enemies in Zone: %2", _SpawnModule,str count _nearestEnemies] remoteExec ["systemchat", TO_ALL_PLAYERS];
	
	if (count _nearestEnemies < _MinEnemiesInZone and _MinEnemiesInZone != 0) then {
		format ["%1: Not enough Enemies in Zone", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
	};
	if (count _nearestFriendlies > _MaxFriendliesInZone or (_Balance >= _ForcesBalancing && _ForcesBalancing > 0)) then {
		format ["%1: To many Friendlies in Zone", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
	};
	if (count _nearDamagedUnits > _MaxUnconscious) then {
		format ["%1: To many unconscious Enemies in Zone", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
	};
	if !(_Spawncheck) then {
		format ["%1: Balancing prevented Spawn", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
	};
};

_Spawncheck