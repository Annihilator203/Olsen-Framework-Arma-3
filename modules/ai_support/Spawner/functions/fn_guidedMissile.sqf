#include "script_component.hpp"
params ["_targetobj","_missileStart","_missileType","_missileSpeed","_Missileprecission","_veh"];

private _Dispersion = linearConversion [0, 4000, (_targetobj distance _veh),0,350, true];
_perSecondChecks = linearConversion [0, 1, _Missileprecission,5,30, true];
_RandomRadius = linearConversion [0, 1, _Missileprecission,_Dispersion,0.5, true];
private _defaultTargetPos = [[[getPos _targetobj, _RandomRadius]], []] call BIS_fnc_randomPos;

_veh allowDamage false;
_missile = _missileType createVehicle _missileStart;
_missile allowDamage false;

[_veh,_missile] spawn {
sleep 0.3;


(_this select 1) allowDamage true;
sleep 0.5;
(_this select 0) allowDamage true;
};


//secondary target used for random trajectory when laser designator is turned off prematurily
_secondaryTarget = "Land_HelipadEmpty_F" createVehicle _defaultTargetPos;
_secondaryTarget setPos [_defaultTargetPos select 0,_defaultTargetPos select 1, 0];



//procedure for guiding the missile

/* _posInFront = _veh getRelPos [100, 0]; // Position in front of heli
_stepdistance = ((((_missileSpeed*1.1) / 3600)* 0.1)*1000);
[_secondaryTarget,_posInFront,[_defaultTargetPos select 0,_defaultTargetPos select 1, 0],_stepdistance,0.1] spawn HBQSS_fnc_MoveObject; /// Animate Target for Smooth Trajectory.
 */

_homeMissile = {
	
private ["_velocityX", "_velocityY", "_velocityZ", "_target"];
_target = _secondaryTarget;
_targetpos = _defaultTargetPos;

//altering the direction, pitch and trajectory of the missile
if (_missile distance _target > (_missileSpeed / 20)) then {
	_travelTime = (_target distance _missile) / _missileSpeed;
	_missile setDir (_missile getDir _target);
	_relDirVer = asin ((((getPosASL _missile) select 2) - ((getPosASL _target) select 2)) / (_target distance _missile));
	_relDirVer = (_relDirVer * -1);
	[_missile, _relDirVer, 0] call BIS_fnc_setPitchBank;

	_velocityX = (((getPosASL _target) select 0) - ((getPosASL _missile) select 0)) / _travelTime;
	_velocityY = (((getPosASL _target) select 1) - ((getPosASL _missile) select 1)) / _travelTime;
	_velocityZ = (((getPosASL _target) select 2) - ((getPosASL _missile) select 2)) / _travelTime;

};

// This seems to get rid of the script errors for the 1-2 cycles after the missile is destroyed when _velocityX returns ANY
if (isNil {_velocityX}) exitWith {velocity _missile};

[_velocityX, _velocityY, _velocityZ]
};

_missile call _homeMissile;

//fuel burning should illuminate the landscape
_fireLight = "#lightpoint" createVehicle position _missile;
_fireLight setLightBrightness 0.5;
_fireLight setLightAmbient [1.0, 1.0, 1.0];
_fireLight setLightColor [1.0, 1.0, 1.0];
_fireLight lightAttachObject [_missile, [0, -0.5, 0]];

// && ((getposATL _missile) select 2) > 2

//missile flying
while {alive _missile && ((getposATL _missile) select 2) > 2} do {
	_velocityForCheck = _missile call _homeMissile;
	if (!(isNil {_velocityForCheck select 0}) && {_x isEqualType 0} count _velocityForCheck == 3) then {_missile setVelocity _velocityForCheck};
	if ({_x isEqualType 0} count _velocityForCheck == 3) then {_missile setVelocity _velocityForCheck};	
	sleep (1 / _perSecondChecks);
};

deleteVehicle _fireLight;
deleteVehicle _secondaryTarget;

