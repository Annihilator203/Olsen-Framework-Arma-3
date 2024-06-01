params["_unit","_RebelWeapon","_RebelMagazine","_Vcom","_Lambs","_DCO_SFSM"];

private _RebelGroup = createGroup [east,true];

_RebelGroup setVariable ["HBQ_SpawnedBy",(group _unit) getVariable ["HBQ_SpawnedBy",objnull]];
_RebelGroup setVariable ["HBQ_SpawnPos",(group _unit) getVariable ["HBQ_SpawnPos",[]]];
_unit joinAsSilent [_RebelGroup, 1];
_unit addMagazines [_RebelMagazine, 4];
_unit addWeapon _RebelWeapon;
_RebelGroup setCombatBehaviour "COMBAT";
_unit setCombatBehaviour "COMBAT";
[_RebelGroup]call HBQSS_fnc_deleteGroupWhenEmpty;

_RebelGroup setVariable ["Vcm_Disable", not _Vcom];
_unit setVariable ["lambs_danger_disableAI", not _Lambs];
_unit setVariable ["SFSM_excluded", not _DCO_SFSM];

_unit setSkill ["aimingAccuracy", HBQSS_AimingSkill];
_unit setUnitPos "UP";
_unit allowFleeing 0;
_unit setSkill ["courage", 1];
private _nearEnemies = [];
//private _nearEnemy;


private _allEnemiesUnits = allUnits select {side _x == west};

private _nearEnemies = _allEnemiesUnits select {
	_x distance2D _unit < 300
};


if (count _nearEnemies ==0) exitWith {true};
private _nearEnemy = selectRandom _nearEnemies;


_RebelGroup addWaypoint [(position _nearEnemy), 10];
_unit lookAt (position _nearEnemy);
_unit reveal _nearEnemy;
