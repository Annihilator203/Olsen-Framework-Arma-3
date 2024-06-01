params ["_MinServerFPS","_SpawnModule","_debug","_ChecksDelay"];
if (!isServer) exitWith {};
_SpawnModule setVariable ["HBQ_FpsCheck", false,true]; // PUBLIC ??
sleep random 3;
while {true} do {
	
	if (isNull _SpawnModule) exitWith {true};
	if (diag_fps < _MinServerFPS) then {
	if (isNull _SpawnModule) exitWith {true};
		_SpawnModule setVariable ["HBQ_FpsCheck", false,true]; // PUBLIC ??
		diag_log format ["INFO HBQ: %1: FPS to Low for Spawning", _SpawnModule];
		if (_debug) then {
			format ["%1: FPS to Low for Spawning", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];	
		};
	} else {
		if (isNull _SpawnModule) exitWith {true};
		_SpawnModule setVariable ["HBQ_FpsCheck", true,true];// PUBLIC ??
	};
	sleep (_ChecksDelay*2);
};