params ["_unit","_RetreatGroupsize","_DespawnSecurityRadius","_CheckWatchDirection","_debug","_JoinNearGroups","_ChecksDelay","_Spawnmodule"];
sleep 30; // Wait so Units dont Retreat right after spawning
waitUntil {
	sleep _ChecksDelay; 
	if (isNull _unit) exitWith {true};
	if (isNull (group _unit)) exitWith {true};
	if (isNil {(group _unit) getVariable "HBQ_SpawnFinished"}) exitWith {true};
	(group _unit) getVariable ["HBQ_SpawnFinished",false]
};

waituntil {
	sleep _ChecksDelay; 
	if (isNull _unit) exitWith {true};
	count (units (group _unit) select {alive _x}) <= _RetreatGroupsize
};

if (isNull _unit) exitWith {true};
(group _unit) allowFleeing 0;
(group _unit) setVariable ["Vcm_Disable",true]; 
[_unit, _DespawnSecurityRadius,_debug,_CheckWatchDirection,_JoinNearGroups,_RetreatGroupsize,_Spawnmodule] spawn HBQSS_fnc_FleeHide;