#include "script_component.hpp"
params ["_target","_startPos","_missileType","_missileSpeed","_Missileprecission","_direction","_veh"];

//if no target is found -> exit
if (isNull _target) exitWith {true};
if (_missileSpeed == 0) exitWith {true};

//creating missile (prevent collision with Plane/Heli)
_veh allowDamage false;
_missile = _missileType createVehicle _startPos;
//_missile enableSimulation false;
_missile allowDamage false;

[_veh,_missile] spawn {
sleep 1.5;

//(_this select 1) enableSimulation true;
(_this select 1) allowDamage true;
sleep 3;
(_this select 0) allowDamage true;
};


private _MissileprecissionScalled = linearConversion [0, 1, _Missileprecission, _target distance _missile, 0, true];

_perSecondsChecks = linearConversion [0, 1, _Missileprecission,5,30, true];
_RandomRadius = linearConversion [0, 1, _Missileprecission,150,0, true];



private _targetPos = [[[getPosASL _target, _RandomRadius]], []] call BIS_fnc_randomPos;


private _time = time;
private _dirHor = 0;
private _flyingTime = 0;
private _velocityX = 0;
private _velocityY = 0;
private _velocityZ = 0;


//ajusting missile pos while flying
while {alive _missile && (_targetPos distance2d _missile)>(random _MissileprecissionScalled) && ((getpos _missile)select 2) > 5} do {
if (_missile distance _targetPos > (_missileSpeed / 10)) then {
/// First few seconds fly in Vehicle Direction.
if ((time -_time) < 1) then {
_missile setDir (getDir _veh);
_posInFront = _veh getRelPos [200, 0];
_flyingTime = (_target distance _missile) / _missileSpeed;
_velocityX = (((_posInFront) select 0) - ((getPosASL _missile) select 0)) / _flyingTime;
_velocityY = (((_posInFront) select 1) - ((getPosASL _missile) select 1)) / _flyingTime;
_velocityZ = (((getPosASL _veh) select 2) - ((getPosASL _missile) select 2)) / _flyingTime;
_dirVer = asin ((((getPosASL _missile) select 2) - ((getPosASL _veh) select 2)) / (_target distance _missile));
_dirVer = (_dirVer * -1);
[_missile, _dirVer, 0] call BIS_fnc_setPitchBank;

} else {
_dirHor = [_missile, _target] call BIS_fnc_DirTo;
_missile setDir _dirHor;
_flyingTime = (_target distance _missile) / _missileSpeed;
_velocityX = (((_targetPos) select 0) - ((getPosASL _missile) select 0)) / _flyingTime;
_velocityY = (((_targetPos) select 1) - ((getPosASL _missile) select 1)) / _flyingTime;
_velocityZ = (((_targetPos) select 2) - ((getPosASL _missile) select 2)) / _flyingTime;
_dirVer = asin ((((getPosASL _missile) select 2) - ((_targetPos) select 2)) / (_target distance _missile));
_dirVer = (_dirVer * -1);
[_missile, _dirVer, 0] call BIS_fnc_setPitchBank;
};







_missile setVelocity [_velocityX, _velocityY, _velocityZ];


sleep (1/ _perSecondsChecks);
};
};