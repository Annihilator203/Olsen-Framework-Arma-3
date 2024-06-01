params ["_unit","_DespawnSecurityRadius","_debug","_CheckWatchDirection","_JoinNearGroups","_RetreatGroupsize","_SpawnModule"];

private _nearestSameSide =[];
//private _SpawnModule = (group _unit) getVariable ["HBQ_SpawnedBy",objnull];
if ((group _unit) getVariable ["HBQ_IsFleeing", false]) exitWith {true};
if (!Alive _unit) exitWith {true};

if (_JoinNearGroups) then {
	private _nearUnits = _unit nearEntities ["Man", 100];

	{
		if (side _x == side _unit && side _x != CIVILIAN  && alive _x && count (units group _x) > _RetreatGroupsize) then {
			_nearestSameSide = _nearestSameSide + [_x];
		};
	} foreach _nearUnits;
};

if (_JoinNearGroups && count _nearestSameSide > 0) exitWith {
	_unit enableAI "PATH";
	_unit joinAsSilent [group (_nearestSameSide select 0), 4];
	if (_debug) then {
	//_SpawnModule = (group _unit) getVariable "HBQ_SpawnedBy";
	format ["%1: Unit Joined near Group", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
	};

	[_unit,_RetreatGroupsize,_DespawnSecurityRadius,_CheckWatchDirection,_debug,_JoinNearGroups,_SpawnModule] spawn {
	params ["_unit","_RetreatGroupsize","_DespawnSecurityRadius","_CheckWatchDirection","_debug","_JoinNearGroups","_SpawnModule"];
	
		waituntil {
			sleep 5; 
			if (isNull _unit) exitWith {true};
			count (units (group _unit) select {alive _x}) <= _RetreatGroupsize
		};
		
		if (isNull _unit) exitWith {true};
		if (!Alive _unit) exitWith {true};
		(group _unit) allowFleeing 0;
		_unit setSkill ["courage", 1];
		[_unit, _DespawnSecurityRadius,_debug,_CheckWatchDirection,_JoinNearGroups,_RetreatGroupsize,_SpawnModule] spawn HBQSS_fnc_FleeHide;
	};		

	
};

if (!Alive _unit) exitWith {true};
(group _unit) setVariable ["Vcm_Disable",true]; 
[_unit] spawn HBQSS_fnc_KillStuckUnit;
if (_debug) then {
	if (isNull _unit) exitWith {true};
	format ["%1: Unit Flees", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
};

(group _unit) allowFleeing 0;
(group _unit) setSpeedMode "FULL";
_unit disableAI "AUTOCOMBAT";
_unit disableAI "AUTOTARGET";
_unit disableAI "CHECKVISIBLE";
_unit disableAI "TARGET";
_unit disableAI "COVER";
_unit setVariable ["lambs_danger_disableAI", true];
(group _unit) setVariable ["lambs_danger_disableGroupAI", true];
private _nearestBuildings = [];
private _BuildingMoveposition = [];
private _ValidBuildings = [];
private _RandomBuilding = [];
private _RandomBuildingPositions = [];
private _BuildingMoveposition = [];
private _CivilianGroup = createGroup [CIVILIAN,true];
_CivilianGroup setVariable ["HBQ_SpawnedBy",_SpawnModule,true];
_CivilianGroup setVariable ["HBQ_SpawPos",(group _unit) getVariable ["HBQ_SpawPos",[]],true];
_unit joinAsSilent [_CivilianGroup, 1];
_unit playMoveNow "";
_unit playActionNow "";

_CivilianGroup setVariable ["Vcm_Disable",true]; 
_CivilianGroup setVariable ["lambs_danger_disableGroupAI", true];
_CivilianGroup setSpeedMode "FULL";
_CivilianGroup allowFleeing 0;
[_CivilianGroup]call HBQSS_fnc_deleteGroupWhenEmpty;

if (random 1 < 0) then {
	[_unit] call HBQSS_fnc_Panic;
};

_unit removeWeapon (primaryWeapon _unit); 
sleep 2; 
_unit action ['SwitchWeapon', _unit, _unit, 100]; 

_nearestBuildings = nearestObjects [_unit, ["House"], 40];
_ValidBuildings =  _nearestBuildings select {count ([_x] call BIS_fnc_buildingPositions) > 2};
if (count _ValidBuildings != 0) then {

	_RandomBuilding = selectRandom _ValidBuildings;
	_RandomBuildingPositions = _RandomBuilding buildingPos -1;
	_BuildingMoveposition = selectRandom _RandomBuildingPositions;

	_unit doFollow _unit;
	sleep 0.2;
	_unit doMove _BuildingMoveposition;
	sleep 0.2;
	_unit moveTo _BuildingMoveposition;
	_CivilianGroup addWaypoint [_BuildingMoveposition, 0.5];
	[_unit,_BuildingMoveposition]spawn HBQSS_fnc_CheckMovement;

	if (_debug) then {[_BuildingMoveposition, "","ICON","Waypoint",[0.5,0.5],120,"ColorRed",1,0,"SolidBorder",false] spawn HBQSS_fnc_CreateDebugMarker;};
	
	waitUntil {
		sleep 10;
		if !(Alive _unit) exitWith {true};
		(_unit distance _BuildingMoveposition) < 8 or moveToCompleted _unit or moveToFailed _unit
	};
} else {
	if (isNull _unit) exitWith {true};
	if (!Alive _unit) exitWith {true};
	private _SpawnPosition = (group _unit) getVariable "HBQ_SpawnPos";
	if (isNil "_SpawnPosition") exitWith {true};
	doStop _unit;
	sleep 0.2;
	_unit doFollow _unit;
	sleep 0.5;
	_unit doMove _SpawnPosition;
	sleep 0.1;
    _unit moveTo _SpawnPosition;
	_CivilianGroup addWaypoint [_SpawnPosition, 0.5];

	[_unit,_SpawnPosition]spawn HBQSS_fnc_CheckMovement;
	//sleep 10;
	waitUntil {
		sleep 5;
		if !(alive _unit) exitWith {true};
		if (isNull _unit) exitWith {true};
		(_unit distance _SpawnPosition) < 15 //or moveToCompleted _unit or moveToFailed _unit
	};
};

if (isNull _unit) exitWith {true};

sleep 3;
_unit setUnitPos "DOWN";
sleep 5;
_unit disableAI "PATH";
waitUntil {
	sleep 5;
	if (isNull _unit) exitWith {true};
	[_unit, _DespawnSecurityRadius, _debug,_CheckWatchDirection,_SpawnModule] call HBQSS_fnc_PlayersNear == false
};
deleteVehicle _unit;