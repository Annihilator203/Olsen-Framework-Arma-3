// Check if Players  near the position and if any Player is watching in the direction of Spawn/Deletion
params ["_CheckPosition", "_PlayerSecurityRadius", "_debug","_CheckWatchDirection","_SpawnModule"];
private _PlayersNear = false;
private _AllPlayersInRange = allPlayers select {_x distance _CheckPosition < _PlayerSecurityRadius};
if (isNil {_AllPlayersInRange})exitWith {true};

{
	private _PlayerDistance = _x distance _CheckPosition;
	if (_CheckWatchDirection) then {
	private _PlayerDirection = getDir  _x;
	private _xlen =  ((getPos _x) select 0) +(sin _PlayerDirection) *_PlayerDistance;
	private _ylen = ((getPos _x) select 1) +(cos _PlayerDirection) *_PlayerDistance;
	if ((_CheckPosition distance [_xlen,_ylen]) > (_PlayerSecurityRadius*0.7)) exitWith {if (_debug) then {format ["%1: Player is not Watching.", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};_PlayerSecurityRadius=_PlayerSecurityRadius*0.5};
	};

	if (_PlayerDistance < _PlayerSecurityRadius) exitWith {if (_debug) then {format ["%1: Player too Near for Spawning / Deletion.", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};_PlayersNear = true};
} forEach _AllPlayersInRange;

_PlayersNear


