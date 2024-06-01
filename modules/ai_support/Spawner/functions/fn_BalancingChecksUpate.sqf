#include "script_component.hpp"
params ["_SpawnPosObj","_Side","_SpawnModule","_ChecksDelay","_HotZone","_MaxUnconscious","_MinEnemiesInZone","_MaxFriendliesInZone","_ForcesBalancing","_debug"];

waitUntil {
	if (isNil "_SpawnModule") exitWith {true};
	_SpawnPosObj setVariable ["HBQ_BalancingCheck",false];
	if (_HotZone >= 0 && _HotZone < 100) then {sleep (_ChecksDelay/5);}; 
	if (_HotZone >= 100 && _HotZone < 500) then {sleep _ChecksDelay/3;}; 
	if (_HotZone >= 500 && _HotZone < 1000) then {sleep _ChecksDelay/2;}; 
	if (_HotZone >= 1000 && _HotZone < 3000) then {sleep (_ChecksDelay);};
	if (_HotZone >= 3000) then {sleep (_ChecksDelay*2)}; 
	[_SpawnModule,_HotZone,_Side,_MaxUnconscious,_MinEnemiesInZone,_MaxFriendliesInZone,_ForcesBalancing,_debug]call HBQSS_fnc_BalancingChecks
};
	
_SpawnPosObj setVariable ["HBQ_BalancingCheck",true];
