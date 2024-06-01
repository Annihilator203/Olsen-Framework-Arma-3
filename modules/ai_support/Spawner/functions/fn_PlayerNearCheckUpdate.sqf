params ["_PlayerSecurityRadius","_SpawnPosObj","_SpawnPosition","_SpawnModule","_ChecksDelay","_debug","_CheckWatchDirection"];

if (isNil "_SpawnModule") exitWith {true};
if (isNull _SpawnModule) exitWith {true};
//if ([_SpawnPosition, _PlayerSecurityRadius, _debug,_CheckWatchDirection,_SpawnModule]call HBQSS_fnc_PlayersNear == false) exitWith {_SpawnPosObj setVariable ["HBQ_PlayerNearCheck",true];};

waitUntil {
	if (isNil "_SpawnModule") exitWith {true};
	_SpawnPosObj setVariable ["HBQ_PlayerNearCheck",false];
	if (_PlayerSecurityRadius > 0 && _PlayerSecurityRadius < 100) then {sleep (_ChecksDelay/2);}; 
	if (_PlayerSecurityRadius >= 100 && _PlayerSecurityRadius < 300) then {sleep _ChecksDelay;}; 
	if (_PlayerSecurityRadius >= 300 && _PlayerSecurityRadius < 500) then {sleep (_ChecksDelay*2);}; 
	if (_PlayerSecurityRadius >= 500 && _PlayerSecurityRadius < 1000) then {sleep (_ChecksDelay*3);};
	if (_PlayerSecurityRadius >= 1000) then {sleep (_ChecksDelay*6)}; 
	[_SpawnPosition, _PlayerSecurityRadius, _debug,_CheckWatchDirection,_SpawnModule]call HBQSS_fnc_PlayersNear == false
};

_SpawnPosObj setVariable ["HBQ_PlayerNearCheck",true];