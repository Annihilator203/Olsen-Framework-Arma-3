#include "script_component.hpp"
/// Checks if Spawning should happen or not by checking synced Triggers,Max Duration setting and Stoptrigger
params ["_SpawnModule","_SpawnStopTrigger","_MaxSpawnDuration","_debug","_ChecksDelay"];
private _TimeDepleted = false;
private _BudgetDepleted = false;
_SpawnModule setVariable ["HBQ_SpawnsTerminated", false,true]; // PUBLIC ??

/// Check if Max Spawnduration expires or Stop Trigger activates and turn Spawn enabled OFF
private _StartTime = time;
private _MaxSpawnDurationNew = _MaxSpawnDuration;
if (isNull _SpawnStopTrigger && _MaxSpawnDuration <= 0 && (_SpawnModule getVariable "HBQ_WaveBudget")<= 0) exitWith {_SpawnModule setVariable ["HBQ_SpawnsTerminated", false,true];}; // PUBLIC ??

if (_MaxSpawnDuration <= 0) then {
	_MaxSpawnDurationNew = 100000	
};

/// No StopTrigger 
if (isNull _SpawnStopTrigger) then {
	while {
			sleep (_ChecksDelay/2);true
	} do {
		private _NewTime = time;
		private _TimeDelta = _NewTime-_StartTime;
		if (isNil "_SpawnModule") exitWith {true};
		if (isNull _SpawnModule) exitWith {true};
		if (_TimeDelta > _MaxSpawnDurationNew) exitWith {_TimeDepleted = true};
		if (_SpawnModule GetVariable "HBQ_SpawnsTerminated" == true) exitWith {true};
		if ((_SpawnModule getVariable "HBQ_WaveBudget")<= 0 and (_SpawnModule getVariable "HBQ_WaveBudget")!= -100) exitWith {_BudgetDepleted = true};
	};

} else {
	// Stop Trigger Check
	while { 
		sleep (_ChecksDelay/2);
		not triggerActivated _SpawnStopTrigger 
	} do {
		private _NewTime = time;
		private _TimeDelta = _NewTime-_StartTime;
		if (isNil "_SpawnModule") exitWith {true};
		if (isNull _SpawnModule) exitWith {true};
		if (triggerActivated _SpawnStopTrigger) exitWith{true};
		if (_TimeDelta > _MaxSpawnDurationNew) exitWith {_TimeDepleted = true};
		if (_SpawnModule GetVariable "HBQ_SpawnsTerminated" == true) exitWith {true};
		if ((_SpawnModule getVariable "HBQ_WaveBudget")<= 0 and (_SpawnModule getVariable "HBQ_WaveBudget")!= -100) exitWith {_BudgetDepleted = true};
	};	
};

_SpawnModule setVariable ["HBQ_SpawnsTerminated", true,true]; // PUBLIC ??

/// DEBUG
sleep 0.5;
if (_debug) then {
	"FD_Finish_F" remoteExec ["playSound", 0];
	format ["%1: Spawn Stopped", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
	if (_TimeDepleted) then {format ["%1: Max Spawnduration reached.", _SpawnModule] remoteExec ["systemchat", 0]};
	if (_BudgetDepleted) then {format ["%1: Unit Budget depleted.", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};
};

diag_log format ["INFO HBQ: %1: Spawn Stopped", _SpawnModule];