#include "script_component.hpp"
params ["_heli","_tPos","_obs","_CASDst","_range","_onlyKnownTargets"];

if (not local _heli) exitWith {};
if not ([_heli] call HBQSS_fnc_isGunship) exitWith {};
private _hG = group _heli;
private _pylon = (group _heli) getVariable ["HBQ_UsePylon",-2];
private _LambsUsed = !((group _heli) getVariable ["lambs_danger_disableGroupAI",false]);
private _VcomUsed = !((group _heli) getVariable ["Vcm_Disable",false]);

/// DISABLE AI MODS

{
_x setVariable ["lambs_danger_disableAI",true];
}foreach (units _hG);
_hG setVariable ["lambs_danger_disableGroupAI",true];
_hG setVariable ["Vcm_Disable",true];

//_HeliSpawnmodule = _hg getVariable ["HBQ_Spawnedby",objnull];	
_hg allowFleeing 0;
{
	_x enableAI "PATH";
} foreach (units _hg);


// DELETE WAYPOINTS
if(count waypoints (leader _hg) > 0) then {
	{deleteWaypoint((waypoints (leader _hg))select 0);}forEach waypoints (leader _hg);
};

private _FlyHight = _hg getVariable ["HBQ_FlyHight",50];
_heli flyInHeight _FlyHight;


//if (_debug or _Rmesg) then {format ["%1: Airsupport is on the Way.", _module] remoteExec ["systemchat", TO_ALL_PLAYERS];};

{_x setVariable ["HBQ_IsForcedToMove",true];} forEach units _hg;


_hg setVariable ["HBQ_arty_availForMission",false,true]; //PUBLIC


private _i = "CASMark_" + (str _tPos);
if (_debug or _Rmesg) then {
_i = createMarker [_i,_tPos];
_i setMarkerColor "ColorRed";
_i setMarkerShape "ICON";
_i setMarkerType "mil_destroy";
_i setMarkerSize [1,1];
};

private _alive = true;

_heli setVariable ["HBQ_canceled",false,true];
private _ldr = leader _hG;
private _sPos = getPosATL _heli;

_heli setVariable ["HBQ_wasHit",false];
_heli setVariable ["HBQ_oldBeh",behaviour (leader _hG)];
_heli setVariable ["HBQ_oldCM",combatMode _hG];
_heli setVariable ["HBQ_done",false];
_heli setVariable ["HBQ_ReachedPos",false];
_hG setBehaviour "CARELESS";
_hG setCombatMode "BLUE";

{
	_x disableAI "AutoTarget";
	_x disableAI "Target";
	_x disableAI "AutoCombat";
}forEach (units _hg);

private _CASPos = [];
_CASPos = _tPos getPos [((_CASDst min ((getObjectViewDistance select 0) - _range)) max (_CASDst * 0.6)),(_tPos getDir _sPos)];
/* 
if (_pylon != -2) then {

_CASPos = _tPos getPos [(_CASDst - _range) max (_CASDst * 0.6),(_tPos getDir _sPos)];

} else {
_CASPos = _tPos getPos [((_CASDst min ((getObjectViewDistance select 0) - _range)) max (_CASDst * 0.6)),(_tPos getDir _sPos)];
}; */




private _wp = _hG addWaypoint [_CASPos,0];	
_wp setWaypointType "MOVE";
_wp setWaypointStatements ["true", "(vehicle this) setVariable ['HBQ_ReachedPos',true]; deleteWaypoint [(group this), 0];"];	
//_wp setWaypointStatements ["true", "(vehicle this) setVariable ['HBQ_ReachedPos',true]; deleteWaypoint [(group this), 0];"];	

if (_heli isKindOf "Plane") then {
private _wp2 = _hG addWaypoint [_tPos,0];	
_wp2 setWaypointType "MOVE";
_wp2 setWaypointBehaviour "COMBAT";

}; 




/// WAIT TO REACH CAS POSITION
waitUntil
	{
	sleep 1;
	if ((isNull _heli) or  (!alive _heli) or (isNull driver _heli) or (!alive driver _heli)) exitwith {true};
	if ((_heli getVariable ["HBQ_wasHit",false]) and {(({_x > 0.5} count ((getAllHitPointsDamage _heli) select 2)) > 0)}) exitWith {_heli setVariable ["HBQ_cancelled",true],true};
	_heli getVariable ["HBQ_ReachedPos",false]
	};

private _lvl = (getPos _heli) select 2 ;
private _initial_lvl = (getPos _heli) select 2 ;
if ((isNull _heli) or  (!alive _heli) or (isNull driver _heli) or (!alive driver _heli) or (_heli getVariable ["HBQ_cancelled",false])) exitWith {deleteMarker _i};
{
_x enableAI "AutoTarget";
_x enableAI "Target";
_x enableAI "AutoCombat";
}forEach (units _hg);


_heli limitSpeed 9999;	

//if (_debug or _Rmesg) then {format ["%1: CAS on FirePosition.", _module] remoteExec ["systemchat", TO_ALL_PLAYERS];};

private _MaxMissionTime = (group _heli) getVariable ["HBQ_MaxMissionTime",180];
[_heli,_MaxMissionTime] spawn {
sleep (_this select 1);
if (isNull (_this select 0)) exitWith {true};
(_this select 0) setVariable ["HBQ_done",true];
};

_tPos set [2,5];	
private _tB = terrainIntersect [(getPosATL _heli),_tPos];

//// INCREASE FLY HIGHT UNTIL NO TERRAIN IS BLOCKING VIEW
while {_tB} do {

	_lvl = _lvl + 20;
	_heli flyInHeight _lvl;
	_cPos = getPosATL _heli;
	_cPos set [2,(_cPos select 2) - 10];
	_tB = terrainIntersect [_cPos,_tPos];
	_cLvl = _cPos select 2;
	_tme = time;
	
	waitUntil {
		sleep 0.1;
		if ((isNull _heli) or  (!alive _heli) or (isNull driver _heli) or (!alive driver _heli)) exitwith {true};
		//if ((_heli getVariable ["HBQ_wasHit",false]) and {(({_x > 0.5} count ((getAllHitPointsDamage _heli) select 2)) > 0)}) exitWith {_heli setVariable ["HBQ_canceled",true,true]}; //PUBLIC
		if ((_heli getVariable ["HBQ_wasHit",false]) or  (getDammage _heli) > 0.5) exitWith {_heli setVariable ["HBQ_canceled",true,true],true}; //PUBLIC
		(((((getPosATL _heli) select 2) - _cLvl) > 15) or (((time - _tme) > 5)))
	};
		
	if ((isNull _heli) or  (!alive _heli) or (isNull driver _heli) or (!alive driver _heli) or (_heli getVariable ["HBQ_canceled",false])) exitWith {true};
};


if ((isNull _heli) or  (!alive _heli) or (isNull driver _heli) or (!alive driver _heli)) exitWith {deleteMarker _i};

if not (_heli getVariable ["HBQ_canceled",false]) then {
	_heli flyInHeight ((getPosATL _heli) select 2);
	private _inf = (_tPos nearEntities [["CAManBase"],_range]) select {side _x != side _hg};
	private _air = (_tPos nearEntities [["Air"],_range])select {side _x != side _hg};
	private _soft = (_tPos nearEntities [["Car"],_range])select {side _x != side _hg};
	private _arm = (_tPos nearEntities [["Tank"],_range])select {side _x != side _hg};
	
	if (_onlyKnownTargets) then {
			{
			if ((((_ldr knowsAbout _x) max (_obs knowsAbout _x)) < 0.01) or {not (((side _ldr) getFriend (side _x)) < 0.6)}) then
				{
				_inf set [_foreachIndex,objNull]
				}
			}
		foreach _inf;
		_inf = _inf - [objNull];
			
			{
			if ((((_ldr knowsAbout _x) max (_obs knowsAbout _x)) < 0.01) or {not (((side _ldr) getFriend (side _x)) < 0.6)}) then
				{
				_air set [_foreachIndex,objNull]
				}
			}
		foreach _air;
		_air = _air - [objNull];				
				
			{
			if ((((_ldr knowsAbout _x) max (_obs knowsAbout _x)) < 0.01) or {not (((side _ldr) getFriend (side _x)) < 0.6)}) then
				{
				_soft set [_foreachIndex,objNull]
				}
			}
		foreach _soft;
		_soft = _soft - [objNull];				
				
			{
			if ((((_ldr knowsAbout _x) max (_obs knowsAbout _x)) < 0.01) or {not (((side _ldr) getFriend (side _x)) < 0.6)}) then
				{
				_arm set [_foreachIndex,objNull]
				}
			}
		foreach _arm;
		_arm = _arm - [objNull];	
	};

	private _homing = [];
	private _targets = [];

	_homing appEnd _arm;
	_homing appEnd _air;
	_homing appEnd _soft;
	
	{
		_inf appEnd (crew _x)
	} foreach _homing;

	_targets appEnd _inf;
	_targets appEnd _air;
	_targets appEnd _soft;
	_heli SetVariable ["HBQ_myDamage",[_heli] call HBQSS_fnc_ActDamageSum];

	if (count _targets == 0 && count _homing == 0) exitWith {
	//if (_debug or _Rmesg) then {format ["%1: No Targets. Mission Canceled.", _module] remoteExec ["systemchat", TO_ALL_PLAYERS];};
	deleteMarker _i;
	_heli setVariable ["HBQ_canceled",true,true];
	_hg setVariable ["HBQ_arty_availForMission",true,true]; // PUBLIC
	};



	private _hEH = _heli addEventHandler ["Hit",
	{
	params ["_unit", "_source", "_damage", "_instigator"];
	//_unit setVariable ["HBQ_wasHit",(((([_unit] call HBQSS_fnc_ActDamageSum) - (_unit GetVariable ["HBQ_myDamage",0])) > 0.2) or ((({_x == 1} count ((getAllHitPointsDamage (_unit)) select 2)) > 0) or (not (canMove (_unit)))))];
	_unit setVariable ["HBQ_wasHit",(((([_unit] call HBQSS_fnc_ActDamageSum) - (_unit GetVariable ["HBQ_myDamage",0])) > 0.2) or ((getDammage _unit) > 0.5) or (not (canMove (_unit))))];
	
	}];

	private _weaponsAll = [_heli] call HBQSS_fnc_TakeWeapons;

	systemChat "about to fire!";
	TRACE_5("doFire values",_heli,_weaponsAll,_targets,_homing,_tPos);

	

	[_heli,_weaponsAll,10,_targets,_homing,_tPos] call HBQSS_fnc_doFire;


	systemChat "survived the DOFire! it worked!";
	
	//// CAS MISSION END
	
	_heli removeEventHandler ["Hit",_hEH];
	if ((isNull _heli) or  (!alive _heli) or (isNull driver _heli) or (!alive driver _heli) or (not (canMove _heli))) exitWith {true};

	
	
	//if (_debug or _Rmesg) then {format ["%1: Airsupport Returns.", _module] remoteExec ["systemchat", TO_ALL_PLAYERS];};
	deleteMarker _i;
	
	_heli flyInHeight _initial_lvl;
	private _tme = time;

	waitUntil {
		sleep 1;
		if ((isNull _heli) or  (!alive _heli) or (isNull driver _heli) or (!alive driver _heli)) exitwith {true};
		//if ((_heli getVariable ["HBQ_wasHit",false]) and (({_x > 0.5} count ((getAllHitPointsDamage _heli) select 2)) > 0)) exitWith {_heli setVariable ["HBQ_canceled",true];true};
		if ((_heli getVariable ["HBQ_wasHit",false])) exitWith {_heli setVariable ["HBQ_canceled",true];true};
		((((getPosATL _heli) select 2) < (_initial_lvl + 20)) or ((time - _tme) > 10))
	};
};
	
deleteMarker _i;
	
if ((isNull _heli) or  (!alive _heli) or (isNull driver _heli) or (!alive driver _heli) or (not (canMove _heli))) exitWith {true};


//(leader _hg) doWatch objNull;
private _MyTargets = _hg targets [true,5000];
{_hg forgetTarget _x}foreach _MyTargets;



//_hg setBehaviourStrong "SAFE";

// DELETE WAYPOINTS
if(count waypoints (leader _hg) > 0) then {
	{deleteWaypoint((waypoints (leader _hg))select 0);}forEach waypoints (leader _hg);
};

{
	_x disableAI "AutoTarget";
	_x disableAI "Target";
	_x disableAI "AutoCombat";
	_x doWatch objNull;
	_x domove getpos _x;
} forEach (units _hg);


sleep 1;


private _wpr = (group _heli) addWaypoint [_sPos, 0];
_wpr setWaypointType "MOVE";
_wpr setWaypointBehaviour "CARELESS";
_wpr setWaypointStatements ["true", "(vehicle this) land 'land';(group this) setBehaviour 'AWARE';(group this) setCombatMode 'RED';"];

_heli limitSpeed 9999;
 

/*if (_HeliSpawnmodule getVariable ["StartAirOnGround",false] or (_sPos select 2) < 5) then {
	[_hg,5,_module,_sPos] spawn HBQSS_fnc_Land;
	[_spos,_hg] spawn HBQSS_fnc_createLandingZone;
};*/

_heli flyInHeight _initial_lvl;
sleep 60;

{
	_x enableAI "AutoTarget";
	_x enableAI "Target";
	_x enableAI "AutoCombat";
}forEach (units _hg);

{_x setVariable ["HBQ_IsForcedToMove",false]} forEach units _hg;

if (_LambsUsed) then {
{
_x setVariable ["lambs_danger_disableAI",false];
}foreach (units _hG);
_hG setVariable ["lambs_danger_disableGroupAI",false];
};

if (_VcomUsed) then {
_hG setVariable ["Vcm_Disable",false];
};



	