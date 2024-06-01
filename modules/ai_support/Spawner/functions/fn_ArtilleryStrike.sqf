#include "script_component.hpp"
 params [
    ["_grpArray",[]],
    ["_arty",objNull],
    ["_typeArray",[]],
    ["_dangerCloseDist",0],
    ["_SpawnModule",objNull],
	["_SpotterIsPlayer",false]
];

if (not local _arty) exitWith {};

private _Debug = _SpawnModule getVariable ["Debug",false];
if !(HBQSS_DebugEnabled) then {_Debug = false};


if (isNull _arty) exitWith {if(_Debug)then { format ["%1: No Artillery Available", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};};

private _hitTarget = true;
private _kaFriendly = 1;
private _Spread = (group _arty) getVariable ["HBQ_ArtillerySpread",200];
private _zeroRounds = 1;
private _sleep = (((group _arty) getVariable ["HBQ_RoundsDelay",5])); // 2 seconds subtracted because later it will be added to wait for each shot 
private _random = (_sleep/4);
private _zeroedSleep = _sleep*5;
private _requestedRounds = ((group _arty) getVariable ["HBQ_RequestedRounds",5]) - _zeroRounds;
private _CanMove = (leader group _arty)checkAIFeature "PATH";
private _VanillaArty = (group _arty) getVariable ["HBQ_VanillaArty",false];

if (_CanMove) then {
{
_x disableAI "PATH";
} forEach units (group _arty);
};

// PARAM-PARAMS
_grpArray       params [["_spotterGroup",grpNull],["_Target",objNull],["_TargetPos",[]]];
_typeArray      params [["_typeShell",""],["_unlimited",false]];
private _tpos = [];
if (_SpotterIsPlayer) then {_tpos = _TargetPos} else {_tpos = getPosATL (_Target)};


private _maxRounds =  (group _arty) getVariable ["HBQ_Maxrounds",32];

private _Rmesg = _SpawnModule getVariable ["Rmesg",false];

//// DEBUG POLYLINE MARKER FIRST LINE
if (_Debug) then {
	
	_Polyline_x1=(getPos _arty) select 0;
	_Polyline_y1=(getPos _arty) select 1;
	_Polyline_x2=(_tpos) select 0;
	_Polyline_y2=(_tpos) select 1;
	[_SpawnModule,[0.2,0.2],120,"ColorRed",0.5,[_Polyline_x1,_Polyline_y1],[_Polyline_x2,_Polyline_y2]] spawn HBQSS_fnc_CreateDebugLine;
	[_tpos, "","ICON","mil_objective_noShadow",[0.5,0.5],120,"ColorRed",1,0,"SolidBorder",false] spawn HBQSS_fnc_CreateDebugMarker;
};

if (_Debug or _Rmesg ) then {
format ["%1: FireMission Started.", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
};

private _type = "";
private _spotter = leader _spotterGroup;
if (count (getArtilleryAmmo [_arty]) > 0 ) then {_type = getArtilleryAmmo [_arty] select 0};
if (_type == "") then {_type = "8Rnd_82mm_Mo_shells"}; 
if !(_typeShell == "") then { _type = _typeShell; };

(group _arty) setVariable ["HBQ_arty_availForMission",false,true];
private _ka = 0;

(gunner _arty) setCombatMode "RED";
(gunner _arty) setBehaviour "COMBAT";
if (isNil { (group _arty) getVariable "HBQ_artySpot_roundsFired" }) then { (group _arty) setVariable ["HBQ_artySpot_roundsFired",0,true]; };

private _c = 0;
private _artySleep = 0;
private _artyCount = 0;
private _artyFired = 0;
private _roundCount = 0;
private _timeStart = floor (serverTime);
private _exitScript = false;
private _KnowAbout = 0;


///// WHILE LOOP
while { (
    (alive _arty)
    && { (count units _spotterGroup > 0) }
    && { (alive gunner _arty) }
    && { !(_exitScript) }
    && { ((group _arty) getVariable ["HBQ_artySpot_roundsFired",0] < _maxRounds) }
) } do {

	// Passes on the spotter to next in command
	if !(alive _spotter) then { _c = 1 };
	if (_c == 1) then {
		_spotter = leader _spotterGroup;
		_c = 0;
	};


	if ( (alive gunner _arty) && { (alive _arty) } ) then {
		
		if (isNull _spotter) exitWith {true};
		if(isNull _arty) exitWith {true};
		if (_SpotterIsPlayer) then {_KnowAbout = 1} else { 
			if (isNull _Target) exitWith {_KnowAbout = 0.1};
			_KnowAbout = (_spotter knowsabout _Target)+0.1
		};
		private _error = (_Spread /_KnowAbout);
		
		if ((_roundCount < _zeroRounds) && !_VanillaArty) then {_error = _error + ((random 50)max 10);};

		
		if ((_tpos distance _spotter > _error + 20) && (_tpos distance _arty > _error + 20)) then {
			private _px = random (2 * _error) - _error;
			private _py = random (2 * _error) - _error;
			private _hitpos = [(_tpos select 0) + _px, (_tpos select 1) + _py, _tpos select 2];

			if !(_hitTarget) then {
				while { ({ _arty distance _hitpos < 100 } count [_Target]) != 0 } do {
					_px = random (3 * _error) - 1.5 * _error;
					_py = random (3 * _error) - 1.5 * _error;
					_hitpos = [(_tpos select 0) + _px, (_tpos select 1) + _py, _tpos select 2];
				};
			};

			// ABORT MISSION IF DANGERCLOSE TO KNOWN ALLIES
			private _firemission = true;
			if (isNull _spotter) exitWith {true};
			if(isNull _arty) exitWith {true};
			if (_dangerCloseDist > 0) then {
				private _UnitsSideSpotter = [([_hitpos,side _spotter ,_dangerCloseDist,false,_SpawnModule]call HBQSS_fnc_getNearUnits) select 1,[]];
				if ((count _UnitsSideSpotter) != 0) then {
				_firemission = false;
				if (_debug or _Rmesg) then {format ["%1: Friendly Units in Dangerclose range. Artillery Strike Canceled.", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};	
				};
				

			};

			if (_unlimited) then { _arty setVehicleAmmo 1; };
			if (_fireMission) then {
				
				_arty addMagazineTurret [_type, [0],1];
				if (_VanillaArty) then {
					_arty doArtilleryFire  [_hitpos, _type, _requestedRounds];
				} else {
					_arty doArtilleryFire  [_hitpos, _type, 1];
				};
				
				
				// WAIT a Bit for Vehicle to stop
				
				if (_roundCount < _zeroRounds) then {
				sleep 2;
				};
				
				if (_debug or _Rmesg) then {
					if (_roundCount < _zeroRounds) then {
						private _ETA = 0;
						private _Inrange = true;
						if (isnull _arty) exitWith {true};
						_Inrange = _hitpos inRangeOfArtillery [[_arty], _type];
						_ETA = _arty getArtilleryETA [_hitpos, _type];
						if (_ETA <= 0 or _Inrange == false) exitWith {format ["%1:Target out of Range.", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];_exitScript = true};
						format ["%1: Zeroing Round shot", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
						format ["%1: ETA: %2 Seconds.", _SpawnModule,_ETA toFixed 0] remoteExec ["systemchat", TO_ALL_PLAYERS];
						
						
					};
					

					
				};
				if (_VanillaArty) then {
				_roundCount = _roundCount + _requestedRounds;
				(group _arty) setVariable ["HBQ_artySpot_roundsFired",((group _arty) getVariable "HBQ_artySpot_roundsFired") + _requestedRounds,true]; //public
				} else {
				_roundCount = _roundCount + 1;
				(group _arty) setVariable ["HBQ_artySpot_roundsFired",((group _arty) getVariable "HBQ_artySpot_roundsFired")+1,true]; //public
				};
				
				
				_artySleep = (_sleep + (random _random));
			};
			if (_roundCount <= _zeroRounds) then { _artySleep = _zeroedSleep; };

			sleep (_artySleep max 5);
		};
		
	};


	if (((group _arty) getVariable "HBQ_artySpot_roundsFired" >= _maxRounds) ||  _roundCount > _requestedRounds ) then {
		_exitScript = true;
	};
};

if ((group _arty) getVariable "HBQ_artySpot_roundsFired" >= _maxRounds) then {_arty setVehicleAmmo 0};
if(isNull _arty) exitWith {true};
if (_CanMove) then {
{
_X enableAI "PATH";
} forEach units (group _arty);
};


if (_debug or _Rmesg) then {
format ["%1: Artillery mission finished", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
private _ShellsLeft = _maxRounds - ((group _arty) getVariable ["HBQ_artySpot_roundsFired",0]);
format ["%1: %2 Shells left", _SpawnModule,_ShellsLeft] remoteExec ["systemchat", TO_ALL_PLAYERS];
};
	
