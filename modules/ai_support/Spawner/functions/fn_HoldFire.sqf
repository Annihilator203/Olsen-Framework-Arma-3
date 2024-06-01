params ["_group","_HoldFireAttackTime","_Combatmode","_debug","_HoldFireEnemyDistance","_SpawnModule"];

_group setVariable ["HBQ_HoldFire", true];
private _ChecksDelay = _SpawnModule getVariable ["ChecksDelay",5];
if(_ChecksDelay == -1) then {_ChecksDelay = HBQSS_ChecksDelay;};

/// DISABLE AI
{
	waitUntil {sleep 1;_x getVariable "HBQ_SpwnFin"};
	_x disableAI "AUTOTARGET";
	_x disableAI "WEAPONAIM";
	_x disableAI "TARGET";
}forEach units _group;

_group setCombatMode "BLUE";


waitUntil {
	sleep (_ChecksDelay/2);
	private _EnemyInRange = false;
	if (isNull _group) exitWith {true};
	if (_HoldFireEnemyDistance > 0) then {
		if ((((leader _group) findNearestEnemy (leader _group)) distance leader _group) < _HoldFireEnemyDistance) then {_EnemyInRange = true;};
	} else {
	_EnemyInRange = true;
	};
	combatBehaviour _group == "COMBAT" and _EnemyInRange
};

_group setCombatMode "GREEN";

if (_debug)then {format ["%2: Target in Range. Hold Fire!!! Wait %1 seconds before attacking", _HoldFireAttackTime,_SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};

//////// SLEEP 
sleep _HoldFireAttackTime;

/// ENABLE AI
{
_x enableAI "WEAPONAIM";
_x enableAI "TARGET";
_x enableAI "AUTOTARGET";
_x setUnitPos "AUTO";

}forEach units _group;


_group setVariable ["HBQ_HoldFire", false];
_group setCombatMode _Combatmode;

if (_debug)then {format ["%1: Weapons free!!", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};