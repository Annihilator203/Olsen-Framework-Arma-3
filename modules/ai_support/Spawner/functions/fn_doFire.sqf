#include "script_component.hpp"
params ["_veh","_weaponsAll","_duration","_targets","_homing","_tPos"];
private ["_tme"];
TRACE_5("doFire values",_heli,_weaponsAll,_targets,_homing,_tPos);
private _pylon = (group _veh) getVariable ["HBQ_UsePylon",-2];
//private _CasDist = (group _veh) GetVariable ["HBQ_CasAttackDistance",600];
private _CasDist = _tPos distance2d _veh;
private _MissilesDelay = (group _veh) GetVariable ["HBQ_MissilesDelay",3];
private _weaponsH = _weaponsAll select 0;
private _weapons = _weaponsAll select 1;
if (((count _weaponsH) < 1) and {((count _weapons) < 1)}) exitWith {true};
private _gunner = gunner _veh;
if (isNull _gunner) then {_gunner = driver _veh};
private _cancelled = false;
TRACE_5("doFire values",_heli,_weaponsAll,_targets,_homing,_tPos);
private _gp = group _veh;
private _vehPos = getPosATL _veh;
_veh setVariable ["HBQ_noAmmoWeapons",[]];
private _DisableArtyAI = false;
if !(_gunner checkAIFeature "TARGET") then {_gunner enableAI "TARGET"; _DisableArtyAI = true};
private _MissileClass = _gp getVariable ["HBQ_MissileClass",""];
private _Missileprecission = _gp getVariable ["HBQ_MissilePrecision",0.5];
private _MaxMissiles = _gp getVariable ["HBQ_RequestedMissiles",3];
private _MissleCounter = 0;
private _pylonWeapon = "";
TRACE_5("doFire values",_heli,_weaponsAll,_targets,_homing,_tPos);
/// NO TARGETS
if ((({(alive _x)} count _homing) == 0) and {(({(alive _x)} count _targets) == 0)}) then {
	_hasAmmo = ({not ((_x select 0) in (_veh getVariable ["HBQ_noAmmoWeapons",[]]))} count _weapons) > 0;

	if ((not (_hasAmmo)) or (_veh getVariable ["HBQ_Done",false])) exitWith {true};
	_tme = time + _duration;
	waituntil {
		// FOREACH WEAPON
		TRACE_5("NOTARGET",_heli,_weaponsAll,_targets,_homing,_tPos);
		{
			_tPos set [2,1];
			_weap = _x select 0;
			_cm = currentMuzzle _gunner;
			
			if not (_weap in (_veh getVariable ["HBQ_noAmmoWeapons",[]])) then {														
				_mags = getArray (configFile >> "CfgWeapons" >> (_x select 0) >> "magazines");
				_vehMags = magazines _veh;
				if not ((typeName _cm) isEqualTo (typeName "")) then{_cm = currentWeapon _veh};
				
				_ammo = _veh ammo _cm;
				_ihr = 1;
				
				if ((_ammo < 1) and {(({(_x in _vehMags)} count _mags) < 1)}) then {
					_veh setVariable ["HBQ_noAmmoWeapons", (_veh getVariable ["HBQ_noAmmoWeapons",[]]) pushBack _weap];	
				}
				else
				{
					if (isArray (configfile >> "CfgWeapons" >> _weap >> "magazines")) then {
						_mags = (getArray (configfile >> "CfgWeapons" >> _weap >> "magazines"));
						if ((count _mags) > 0) then {
							_mag = _mags select 0;
							
							if (isText (configfile >> "CfgMagazines" >> _mag >> "simulation")) then {
								_ammoC = getText (configfile >> "CfgMagazines" >> _mag >> "ammo");
								_sim = configFile >> "CfgAmmo" >> _ammoC >> "simulation";
								_ihrC = configFile >> "CfgAmmo" >> _ammoC >> "indirectHitRange";
								if (isNumber _ihrC) then {_ihr = (floor (getNumber _ihrC)) max 1};
								
								if not ((isText _sim) and {((toLower (getText _sim)) in ["shotmissile","shotrocket"])}) then {
									_dst = _veh distance _tPos;
									_addLvl = _dst/100;
									_ts = configFile >> "CfgAmmo" >> _ammoC >> "typicalSpeed";
									if (isNumber _ts) then
										{
										_ts = getNumber _ts;
										_elev = (aSin (9.81 * _dst/(_ts^2)))/2;
										_elev = _elev min (90 - _elev);
										_addLvl = _dst * (sin _elev);
										};
										
									_tPos set [2,((1 * 1000/_dst) + _addLvl)];
									//a2 setPosATL _tPos;
								};
							};
						};
					};		
						
					_tPos2 = +_tPos;
					_tPos2 set [2,1];
					if not (terrainIntersect [_vehPos,_tPos2]) then {							

						for "_i" from 1 to ((round(((_ammo/10) min 10)/_ihr)) max 1) do {
							_gunner fireAtTarget [_veh,_weap];
							sleep 0.1;
							if ((isNull _veh) or {not (alive _veh) or {(isNull (driver _veh)) or {not (alive (driver _veh))}}}) exitwith {_alive = false};
							if ((isNull _gunner) or {not (alive _gunner)}) exitWith {_alive = false};
							//if (((_veh getVariable ["HBQ_wasHit",false])) and {(({_x > 0.5} count ((getAllHitPointsDamage _veh) select 2)) > 0)}) exitWith {_cancelled = true;};
							if (((_veh getVariable ["HBQ_wasHit",false])) or (getDammage _veh ) > 0.5) exitWith {_cancelled = true;};
							if ((_veh ammo _cm) < 1) exitWith {(_veh setVariable ["HBQ_noAmmoWeapons", (_veh getVariable ["HBQ_noAmmoWeapons",[]]) pushBack _weap])};
						};
					};
				};
			};
			
			if (not (_alive) or {_cancelled} or (_veh getVariable ["HBQ_Done",false])) exitWith {};
			if ((_veh ammo _cm) < 1) exitWith {};
		} foreach _weapons;
		
		if (not (_alive) or {_cancelled} or (_veh getVariable ["HBQ_Done",false])) exitWith {true};
		_hasAmmo = ({not ((_x select 0) in (_veh getVariable ["HBQ_noAmmoWeapons",[]]))} count _weapons) > 0;
			
		((time > _tme) or {not (_hasAmmo)})
	};		
};


//// FIRE AT HOMING TARGETS


if (_pylon != -2) then {
	TRACE_5("HOMING TARGET",_heli,_weaponsAll,_targets,_homing,_tPos);
	// AUTOMATIC GUIDED FIRE
	
	//if ((_debug or _Rmesg) && (count _homing) > 0 ) then {format ["%1: Engage %2 high threat Targets.", _module, (count _homing )] remoteExec ["systemchat", TO_ALL_PLAYERS];};
	//if ((_debug or _Rmesg) && (count _homing) == 0 ) then {format ["%1: Engage Infantry.", _module] remoteExec ["systemchat", TO_ALL_PLAYERS];};
	
	private _AllTargets = _homing + _targets; // Make Array with first Homingtargets and than Softtargets.
	if (count _AllTargets == 0) exitWith {
	//if (_debug or _Rmesg) then {format ["%1: No Targets. Mission Canceled.", _module] remoteExec ["systemchat", TO_ALL_PLAYERS];};
	_gp setVariable ["HBQ_arty_availForMission",true,true]; // PUBLIC
	_veh setVariable ["HBQ_canceled",true,true];
	};

	
	/// FOREACH TARGET
	{
		if (isNull _x or !Alive _x) then {continue};
		if (isNull _veh) exitWith {true};
		if (!Alive _veh) exitWith {true};
		if (_MissleCounter >= _MaxMissiles) exitWith {true};
		
		/// SPAWN CUSTOM MISSILE
		if (_pylon == -1) then {
		_pylonWeapon = selectRandom (getPylonMagazines _veh) ;
		} else {
		_pylonWeapon = (getPylonMagazines _veh) select _pylon;
		};
		
		private _pylonAmmo = getText (configfile >> "CfgMagazines" >> _pylonWeapon >> "ammo");
		private _MissileSpeed = getNumber (configfile >> "CfgAmmo" >> _pylonAmmo >>  "maxSpeed");
		if (_MissileSpeed <= 0) then {continue};
		_gp setCombatMode "RED";
		_gp setBehaviourStrong "COMBAT";
		(units _gp) lookAt _x;
		
		/// Wait Till Distance and Bankangle of Plane/Heli is ok to fire
		waitUntil {

			sleep (_MissilesDelay/2);
			if (isNull _x) exitWith {true};
			if (isNull _veh) exitWith {true};
			if (!Alive _veh) exitWith {true};
			private _InFrontofVeh = false;
			private _VehDir = getDir  _veh;
			private _xlen =  ((getPos _veh) select 0) +(sin _VehDir) * (_CasDist*0.5);
			private _ylen = ((getPos _veh) select 1) +(cos _VehDir) * (_CasDist*0.5);
			private _Factor = 1;
			if (_veh isKindOf "Plane") then {_Factor = 1};
			
			if (((getposASL _x) distance2d [_xlen,_ylen]) < (((getposASL _veh) distance2d [_xlen,_ylen]) * _Factor)) then {_InFrontofVeh = true};
			
			/* private _markername = str (random 999);
			_marker = createMarker [_markername,[_xlen,_ylen]];
			_marker setMarkerColor "ColorBlue";
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_destroy";
			_marker setMarkerSize [0.5,0.5];
			  */

			private _bankangle = (_veh call BIS_fnc_getPitchBank) select 1;
			private _Pitchangle = (_veh call BIS_fnc_getPitchBank) select 0;
			private _PlaneIsLevel = (_bankangle < 35) && (_bankangle > -35) && (_Pitchangle < 25) && (_Pitchangle > -25);
			(((_veh distance2d _x) > ((speed  _veh)*1.2)) && _InFrontofVeh && _PlaneIsLevel)
		};
		if (isNull _x or !Alive _x) then {continue};
		if (isNull _veh) exitWith {true};
		if (!Alive _veh) exitWith {true};
		private _VectorAdd = [];
	
		if (_veh isKindOf "Plane") then {
			private _randomValue = selectRandom [-6, 6];
			_VectorAdd = [_randomValue,11,-2];
		} else {
			private _randomValue = selectRandom [-3, 3];
			_VectorAdd = [_randomValue,11,-2];
		}; // Add Vector to prevent Missile Coliding
		
		
		private _AbsMissilePos = _veh modelToWorld _VectorAdd;

		[_x,_AbsMissilePos,_pylonAmmo,_MissileSpeed,_Missileprecission,_veh] spawn HBQSS_fnc_guidedMissile;

		_MissleCounter = _MissleCounter + 1;
		private _akVehPos = getPos _veh;
		sleep (_MissilesDelay/2);

		
	} foreach _AllTargets;

} else {

	// AUTOMATIC VANILA FIRE
	TRACE_5("AUTOMATIC VANILLA",_heli,_weaponsAll,_targets,_homing,_tPos);
	if ((({(alive _x)} count _homing) > 0) and {((count _weaponsH) > 0)}) then {
		_gp setCombatMode "RED";
		_gp setBehaviourStrong "COMBAT";
		private _fEH = _veh addEventHandler ["Fired",{(_this select 0) setVariable ["HBQ_fired",true];(_this select 0) setVariable ["HBQ_Proj",(_this select 6)];}];
		
		//if (_debug or _Rmesg) then {format ["%1: Engage %2 high threat Targets.", _module, (count _homing )] remoteExec ["systemchat", TO_ALL_PLAYERS];};


		while {({!(isNull _x) and (alive _x) and (side _x != CIVILIAN)} count _homing) > 0 && _MissleCounter < _MaxMissiles} do {

			_hasAmmo = ({not ((_x select 0) in (_veh getVariable ["HBQ_noAmmoWeapons",[]]))} count _weapons) > 0;
			if not (_hasAmmo) exitWith {true};
			/// FOREACH WEAPONH
			
			TRACE_5("CYCLING WEAPONS",_heli,_weaponsAll,_targets,_homing,_tPos);
			
			
			{
				_wh = _x;
				_weap = _wh select 0;

				if not (_weap in (_veh getVariable ["HBQ_noAmmoWeapons",[]])) then {
					_mags = getArray (configFile >> "CfgWeapons" >> _weap >> "magazines");
					_vehMags = magazines _veh;
					_ammo = _veh ammo (currentMuzzle _gunner);
					if ((_ammo < 1) and {(({(_x in _vehMags)} count _mags) < 1)}) then {
						_veh setVariable ["HBQ_noAmmoWeapons", (_veh getVariable ["HBQ_noAmmoWeapons",[]]) pushBack _weap]
					}
					else
					{
							// FOREACH HOMINGTARGET
							{
								_veh doWatch (getpos _x);
								_gunner doWatch (getpos _x);	
								_ix = _foreachindex;
								if (alive _x) then {
									_cw = currentWeapon _veh;
									_veh setVariable ["HBQ_Proj",objNull];
									_tPos = getPosATL _x;
									_tPos set [2,1.5];
									
									_tPos2 = +_tPos;
									_tPos2 set [2,1];
									if not (terrainIntersect [_vehPos,_tPos2]) then {
										_gp setCombatMode "YELLOW";
										_veh reveal _x;
										_gunner reveal _x;
										_veh doTarget _x;
										_gunner doTarget _x;
										_veh setVariable ["HBQ_fired", false];
										_tme = time;

										_targetType = if (((side _veh) getFriend west) > 0.6) then {"LaserTargetW"} else {"LaserTargetE"};
										_target = createvehicle [_targetType,_tPos,[],0,"CAN_COLLIDE"];
										private _MissileprecissionScalled = linearConversion [0, 1, _Missileprecission, 50, 0, true];
										
										_target attachTo [_x, [random [-_MissileprecissionScalled, 0, _MissileprecissionScalled], random [-_MissileprecissionScalled, 0, _MissileprecissionScalled], 0]];
										sleep 0.1;
										waitUntil
											{															
											_mags = getArray (configFile >> "CfgWeapons" >> _weap >> "magazines");
											_vehMags = magazines _veh;
											_ammo = _veh ammo (currentMuzzle _gunner);
											//_currentMag = currentMagazine _veh;
											if ((_ammo < 1) and {(({(_x in _vehMags)} count _mags) < 1)}) then
												{
												_veh setVariable ["HBQ_noAmmoWeapons", (_veh getVariable ["HBQ_noAmmoWeapons",[]]) pushBack _weap]
												}
											else
												{
												
												if (_MissleCounter >= _MaxMissiles ) exitWith {true};
												
												
												_gunner fireAtTarget [_target,_weap];
												//sleep 2;

												if ((isNull _veh) or {not (alive _veh) or {(isNull (driver _veh)) or {not (alive (driver _veh))}}}) exitwith {_alive = false};
												if ((isNull _gunner) or {not (alive _gunner)}) exitWith {_alive = false};
												//if (((_veh getVariable ["HBQ_wasHit",false])) and {(({_x > 0.5} count ((getAllHitPointsDamage _veh) select 2)) > 0)}) exitWith {_cancelled = true;};
												if (((_veh getVariable ["HBQ_wasHit",false])) or (getDammage _veh ) > 0.5) exitWith {_cancelled = true;};
												
												};
											if (_MissleCounter >= _MaxMissiles ) exitWith {true};
											
											if (not (_alive) or _cancelled or (_veh getVariable ["HBQ_Done",false]) or (!Alive _veh)) exitWith {true};
											_hasAmmo = ({not ((_x select 0) in (_veh getVariable ["HBQ_noAmmoWeapons",[]]))} count _weapons) > 0;
											
											((_veh getVariable ["HBQ_fired", false]) or {((time - _tme) > 15) or {not (_hasAmmo)}})
											};
										
										if (not (_alive) or _cancelled or (_veh getVariable ["HBQ_Done",false])) exitWith {true};
										_gp setCombatMode "BLUE";
										
										waitUntil
											{
											sleep 0.1;
											
											if ((isNull _veh) or {not (alive _veh) or {(isNull (driver _veh)) or {not (alive (driver _veh))}}}) exitwith {_alive = false;true};
											//if (((_veh getVariable ["HBQ_wasHit",false])) and {(({_x > 0.5} count ((getAllHitPointsDamage _veh) select 2)) > 0)}) exitWith {_cancelled = true;true};
											if (((_veh getVariable ["HBQ_wasHit",false])) or (getDammage _veh ) > 0.5) exitWith {_cancelled = true;true};
											if (_MissleCounter >= _MaxMissiles ) exitWith {true};
											(isNull(_veh getVariable ["HBQ_Proj",objNull]))
									
											};
										
										deleteVehicle _target;
										if (not (_alive) or _cancelled or (_veh getVariable ["HBQ_Done",false])) exitWith {} 
									}
									else
									{
										_homing set [_ix,objNull];
									};
								};
							if (_MissleCounter >= _MaxMissiles ) exitWith {true};
							_MissleCounter = _MissleCounter + 1;
							
							
							} foreach _homing;
						if (not (_alive) or _cancelled or (_veh getVariable ["HBQ_Done",false])) exitWith {};
						
						_homing = _homing - [objNull];
					};
				};
					
				if (not (_alive) or _cancelled or (_veh getVariable ["HBQ_Done",false])) exitWith {};
				if (_MissleCounter >= _MaxMissiles ) exitWith {true};
			} foreach _weaponsH;
			
			if (not (_alive) or _cancelled or (_veh getVariable ["HBQ_Done",false])) exitWith {};
		};
		
		_veh removeEventHandler ["Fired",_fEH];

		if (not (_alive) or _cancelled or (_veh getVariable ["HBQ_Done",false])) exitWith {};
		_veh doWatch objNull;
		_gunner doWatch objNull;		
	};
};


//// SHOOT AT SOFT TARGETS


if ((({(alive _x) } count _targets) > 0) and {((count _weapons) > 0)}) then {

	//if (_debug or _Rmesg) then {format ["%1: Engaging soft Targets.", _module] remoteExec ["systemchat", TO_ALL_PLAYERS];};
	private _wp2 = _gp addWaypoint [_tPos,0];	
	_wp2 setWaypointType "SAD";
	TRACE_5("SOFT TARGET",_heli,_weaponsAll,_targets,_homing,_tPos);

	_gp setBehaviourStrong "COMBAT";
	
	{
	_x setUnitCombatMode "RED";
	_x setBehaviour "COMBAT";
	} foreach units _gp;
	sleep 1;
	_gp setCombatMode "RED";
	
	
	{
	_veh reveal _x;
	_gunner reveal _x;
	_veh doTarget _x;
	_gunner doTarget _x;
	} foreach _targets;
	[crew _heli] doSuppressiveFire [_targets];
	
	
	while {true} do {
		_gp setCombatMode "RED";
		sleep 1;
		_hasAmmo = ({not ((_x select 0) in (_veh getVariable ["HBQ_noAmmoWeapons",[]]))} count _weapons) > 0;
		if (not (_hasAmmo)) exitWith {if (_DisableArtyAI) then {_gunner disableAI "TARGET"};true};
		if (not (_alive)) exitWith {true};
		if (isNull _veh) exitWith {true};
		if  ((({(not(isNull _x) and (alive _x) and (side _x != CIVILIAN))} count _targets) < 4)) exitWith {if (_debug or _Rmesg) then {format ["%1: CAS mission over. No More Targets.", _module] remoteExec ["systemchat", TO_ALL_PLAYERS];};if (_DisableArtyAI) then {_gunner disableAI "TARGET"};true};
		//if ((_veh getVariable ["HBQ_wasHit",false]) && (({_x > 0.5} count ((getAllHitPointsDamage _veh) select 2)) > 0)) then {_cancelled = true};
		if ((_veh getVariable ["HBQ_wasHit",false]) or (getDammage _veh ) > 0.5) then {_cancelled = true};
		if (not (_alive)) exitWith {true};
		if (_cancelled) exitWith {true};
		if (_veh getVariable ["HBQ_Done",true]) exitWith {true};
		

	};
};
