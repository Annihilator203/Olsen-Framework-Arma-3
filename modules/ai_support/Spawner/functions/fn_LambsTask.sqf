params ["_LambsTask","_group","_TargetPosition","_TaskRadius"];
private _Leader = leader _group;

if (_LambsTask == "GARRISON") then {
	[_group, _TargetPosition, _TaskRadius] call lambs_wp_fnc_taskGarrison
};
if (_LambsTask == "CQB") then {
	[_group, _TargetPosition, _TaskRadius] spawn lambs_wp_fnc_taskCQB
};
if (_LambsTask == "RUSH") then {
	[_group, _TaskRadius] spawn lambs_wp_fnc_taskRush
};
if (_LambsTask == "HUNT") then {
	[_group, _TaskRadius] spawn lambs_wp_fnc_taskHunt
};
if (_LambsTask == "PATROL") then {
	[_group, _TargetPosition, _TaskRadius] call lambs_wp_fnc_taskPatrol
};
if (_LambsTask == "CAMP") then {
	[_group, _TargetPosition, 0,[],false,false] spawn lambs_wp_fnc_taskCamp
};
if (_LambsTask == "ASSAULT") then {
	private _groupPosition = position (leader _group);
	private _playerList = allPlayers apply {
		[_groupPosition distanceSqr _x, _x]
	};
	_playerList sort true;
	private _closestPlayer = (_playerList select 0) param [1, objNull];
	[_Leader, getPos _closestPlayer, false, 30, 2, false] spawn lambs_wp_fnc_taskAssault;
};
if (_LambsTask == "CREEP") then {
	[_group, _TaskRadius] spawn lambs_wp_fnc_taskCreep
};