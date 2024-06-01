#include "script_component.hpp"
params ["_Spottergroup"];

if !(local (leader _Spottergroup)) exitWith {};

//// PARAMETER/VARIABLES
//private _Debug = _Module getVariable ["Debug",false];
//if !(HBQSS_DebugEnabled) then {_Debug = false};
//private _Rmesg = _Module getVariable ["Rmesg",false];
private _SpotterMaxDistance = GVAR(spotterMaxDist);
private _RadioRange = GVAR(spotterRadioRange);
private _SupportCallChance = GVAR(callChance);
private _SupportCallDelay = GVAR(callDelay);
//private _LaseDistance = GVAR(laseDist);
private _LaseDistance = GVAR(laseDist);
private _DangerCloseDistance = GVAR(dangClose);
private _SprtTimeout = GVAR(supportTimeout);
private _actionID_Art = -1;
private _actionID_CAS = -1;
private _SelectedArty = objNull;
private _SelectedAirVeh = objNull;
private _SpotterIsPlayer = false;
if (isPlayer (leader _Spottergroup)) then {_SpotterIsPlayer = true};

private _CanCallArtillery = false;
private _CanCallCAS = false;
private _SpotterAbility = GVAR(spotterAbil);
if (_SpotterAbility == 1) then {_CanCallArtillery = true; _CanCallCAS = true}; 
if (_SpotterAbility == 2) then {_CanCallCAS = true}; 
if (_SpotterAbility == 3) then {_CanCallArtillery = true}; 

private _AvailableArtilleryVehicles = [];
private _AvailableCASVehicles =[];
private _FirstRun = true;
if (_Spottergroup getVariable ["HBQ_isSpotting",false]) then {
//_Spottergroup setVariable ["HBQ_isSpotting",false,true];
_Spottergroup setVariable ["HBQ_CancelSpotter",true,true];
sleep 10; 
_Spottergroup setVariable ["HBQ_CancelSpotter",false,true];
};

_Spottergroup setVariable ["HBQ_isSpotting",true,true];


while {true} do {
	if !(_FirstRun) then {sleep 5};
	_SelectedArty = objNull;
	_SelectedAirVeh = objNull;
	if (isNull _Spottergroup) exitWith {true};
	if (count (units _Spottergroup) == 0) then { continue };
	if !(_Spottergroup getVariable ["HBQ_isSpotting",true]) then {(leader _Spottergroup) removeAction _actionID_Art;(leader _Spottergroup) removeAction _actionID_CAS;continue};
	if (_Spottergroup getVariable ["HBQ_CancelSpotter",false]) exitWith {(leader _Spottergroup) removeAction _actionID_Art;(leader _Spottergroup) removeAction _actionID_CAS};
	
	
	
	////////////  PLAYER IS SPOTTER (ARTILLERY)
	
/*
	if (_SpotterIsPlayer  && _CanCallArtillery) then {

		
		
		
		if (_actionID_Art != -1) then {(leader _Spottergroup) removeAction _actionID_Art;}; // Action already exists
		
		_actionID_Art = (leader _Spottergroup) addAction
		[
			"Call Artillery",
			{
				params ["_target", "_caller", "_actionId", "_arguments"];
				if !(local _target) exitWith {};
				private _RadioRange = _this select 3 select 0;
				private _DangerCloseDistance = _this select 3 select 1;
				private _Module = _this select 3 select 2;
				private _SupportCallDelay = _this select 3 select 3;
				private _debug = _this select 3 select 4;
				private _Rmesg = _this select 3 select 5;
				private _LaseDistance =  _this select 3 select 6;
				private _typeArray = ["",false];
				private _TargetPos = screenToWorld [0.5,0.5];
				_target removeAction _actionId;
				private _SelectedArty  = [(group _caller),_RadioRange] call HBQSS_fnc_GetAvailableArty;
				if (isNull _SelectedArty) exitWith {if (_debug or _Rmesg) then {format ["%1: No Artillery Available.", _Module] remoteExec ["systemchat", _target];}; true};
				if (_TargetPos distance (getPos _target) > _LaseDistance) exitWith {if (_debug or _Rmesg) then {format ["%1: Target out of Leasedistance", _Module] remoteExec ["systemchat", _target];};};
				if (_debug or _Rmesg) then {format ["%1: Transmitting Coordinates to Artillery unit. Waiting for Firemission.", _Module] remoteExec ["systemchat", _target];};
				
				if (isNull objectParent _SelectedArty) then {
					[(group _SelectedArty),_Module, getDir _SelectedArty] spawn HBQSS_fnc_DelpoyStaticWeapons; 
					sleep 7;
					_SelectedArty = objectParent (((units group _SelectedArty) select {!(isNull objectParent _x)}) select 0);
				} else {
					_SelectedArty = objectParent _SelectedArty;
				};
				
				if !(isNull _SelectedArty) then {_typeArray = [(group _SelectedArty)getVariable ["HBQ_TypeOfShells",""],false];};
				
				
				sleep _SupportCallDelay; // Sleep _SupportCallDelay
				if !((group _target) getVariable ["HBQ_isSpotting",true]) exitWith {_target removeAction _actionId;true};
				if ((group _target) getVariable ["HBQ_CancelSpotter",false]) exitWith {_target removeAction _actionId;true};
				if ((group _SelectedArty) getVariable ["HBQ_arty_availForMission",true] == false) exitWith {{if (_debug or _Rmesg) then {format ["%1: Artillery not available anymore.", _Module] remoteExec ["systemchat", _target];}; true};};
				if (isNull _SelectedArty) exitWith {if (_debug or _Rmesg) then {format ["%1: Artillery not available anymore.", _Module] remoteExec ["systemchat", _target];}; true};
				//if (count ((_TargetPos) nearEntities 10) == 0) exitWith {if (_debug or _Rmesg) then {format ["%1: No Targets in Area.", _Module] remoteExec ["systemchat", _target];};true};
				(group _SelectedArty) setVariable ["HBQ_arty_availForMission",false,true]; // PUBLIC
				
				[[(group _caller),(((_TargetPos) nearEntities 10) select 0),_TargetPos],_SelectedArty,_typeArray,_DangerCloseDistance,_Module,true] remoteExec  ["HBQSS_fnc_ArtilleryStrike", _SelectedArty];
				
				/// Make Artillery Unit available again after Timeout
				[group _SelectedArty] spawn {
				params ["_group"];
				private _Cooltme = _group getVariable ["HBQ_ArtyCoolDown",180];
				sleep _Cooltme;
				if (isNull _group) exitWith {true};
				_group setVariable ["HBQ_arty_availForMission",true,true]; // PUBLIC
				};
			},
			[_RadioRange,_DangerCloseDistance,_Module,_SupportCallDelay,_debug,_Rmesg,_LaseDistance],
			0,
			false	
		];
		if !(_Spottergroup getVariable ["HBQ_isSpotting",true]) then {(leader _Spottergroup) removeAction _actionID_Art;(leader _Spottergroup) removeAction _actionID_CAS;continue};
		if (_Spottergroup getVariable ["HBQ_CancelSpotter",false]) exitWith {(leader _Spottergroup) removeAction _actionID_Art;(leader _Spottergroup) removeAction _actionID_CAS;true};
		if (not _FirstRun) then {
			private _StartTime = time;
			waitUntil {
				private _Currenttime = time;
				private _Timedelta = _Currenttime-_StartTime;
				sleep 2;
				if (_Spottergroup getVariable ["HBQ_CancelSpotter",false]) exitWith {(leader _Spottergroup) removeAction _actionID_Art;(leader _Spottergroup) removeAction _actionID_CAS;true};
				_Timedelta > _SprtTimeout
			};
		};
		
	};
	*/
	
	////////////  CAS PLAYER IS SPOTTER
	
	if (_SpotterIsPlayer  && _CanCallCAS ) then {
		

		if (_actionID_CAS != -1) then {(leader _Spottergroup) removeAction _actionID_CAS}; // Action already exists
		
		_actionID_CAS = (leader _Spottergroup) addAction
		[
			"Call CAS",
			{
				params ["_target", "_caller", "_actionId", "_arguments"];
				if !(local _target) exitWith {};
				private _RadioRange = _this select 3 select 0;
				//private _debug = _this select 3 select 1;
				//private _Module = _this select 3 select 2;
				//private _Rmesg = _this select 3 select 3;
				private _SupportCallDelay = _this select 3 select 4;
				private _LaseDistance = _this select 3 select 5;
				private _TargetPos = screenToWorld [0.5,0.5];
				_target removeAction _actionId;
				private _SelectedAirVeh  = [(group _caller),_RadioRange] call HBQSS_fnc_GetAvailableCAS;
				//if (_TargetPos distance (getPos _target) > _LaseDistance) exitWith {if (_debug or _Rmesg) then {format ["%1: Target out of Leasedistance", _Module] remoteExec ["systemchat", _target];};};
				private _CasAttackDistance = 500;
				if !(isNull _SelectedAirVeh) then {_CasAttackDistance = (group _SelectedAirVeh) getVariable ["HBQ_CasAttackDistance",600]};
				private _CasSearchDistance = 150;
				if !(isNull _SelectedAirVeh) then {_CasSearchDistance = (group _SelectedAirVeh) getVariable ["HBQ_CasSearchDistance",150]};
				//if (isNull _SelectedAirVeh) exitWith {if (_debug or _Rmesg) then {format ["%1: No CAS unit Available.", _Module] remoteExec ["systemchat", _target];}; true};
				//if (_debug or _Rmesg) then {format ["%1: Transmitting Coordinates to CAS unit. Waiting for Firemission.", _Module] remoteExec ["systemchat", _target];};
				sleep _SupportCallDelay; // Sleep _SupportCallDelay
				if !((group _target) getVariable ["HBQ_isSpotting",true]) exitWith {_target removeAction _actionId;};
				if ((group _target) getVariable ["HBQ_CancelSpotter",false]) exitWith {_target removeAction _actionId};
				//if ((group _SelectedAirVeh) getVariable ["HBQ_arty_availForMission",true] == false) exitWith {{if (_debug or _Rmesg) then {format ["%1: CAS unit not available anymore.", _Module] remoteExec ["systemchat", _target];}; true};};
				//if (isNull _SelectedAirVeh) exitWith {if (_debug or _Rmesg) then {format ["%1: CAS unit not available anymore.", _Module] remoteExec ["systemchat", _target];}; true};
				(group _SelectedAirVeh) setVariable ["HBQ_arty_availForMission",false,true];// PUBLIC
				
				[_SelectedAirVeh,_TargetPos,_caller,_CasAttackDistance,_CasSearchDistance,false] remoteExec  ["HBQSS_fnc_CAS", _SelectedAirVeh];
				

				/// Make Artillery Unit available again after Timeout
				[(group _SelectedAirVeh)] spawn {
				params ["_group"];
				private _Cooltme = _group getVariable ["HBQ_ArtyCoolDown",180];
				sleep _Cooltme;
				if (isNull _group) exitWith {true};
				_group setVariable ["HBQ_arty_availForMission",true,true];// PUBLIC
				};
			},
			[_RadioRange,_SupportCallDelay,_LaseDistance],
			0,
			false
			
		];
		if !(_Spottergroup getVariable ["HBQ_isSpotting",true]) then {(leader _Spottergroup) removeAction _actionID_Art;(leader _Spottergroup) removeAction _actionID_CAS;continue};
		if (_Spottergroup getVariable ["HBQ_CancelSpotter",false]) exitWith {(leader _Spottergroup) removeAction _actionID_Art;(leader _Spottergroup) removeAction _actionID_CAS;true};
		if (not _FirstRun) then {
			private _StartTime = time;
			waitUntil {
				private _Currenttime = time;
				private _Timedelta = _Currenttime-_StartTime;
				sleep 2;
				if (_Spottergroup getVariable ["HBQ_CancelSpotter",false]) exitWith {(leader _Spottergroup) removeAction _actionID_Art;(leader _Spottergroup) removeAction _actionID_CAS;true};
				_Timedelta > _SprtTimeout
			};
		};

	};
	


	
	
	////////// AI IS SPOTTER
	
	if (!_SpotterIsPlayer) then {
		//// FIND TARGETS
		
		private _position = getPos (leader _Spottergroup);
		private _NearEntities =[];
		private _ValidTargets = [];
		_NearEntities = ([_position,side _Spottergroup,_LaseDistance,false]call HBQSS_fnc_getNearUnits) select 0;
		
		if ((count _NearEntities) > 0) then {
			{
				if ([_Spottergroup,_x] call HBQSS_fnc_IsValidTarget) then {_ValidTargets = _ValidTargets + [_x]};
			} foreach _NearEntities;
		};
		
		/*
		
		/// ARTILLERY STRIKE
		if ((count _ValidTargets) > 0 && _CanCallArtillery) then {
			
			
			//// GET CLOSEST AVAILABLE ARTILLERY 
			private _SelectedArty  = [_Spottergroup,_RadioRange] call HBQSS_fnc_GetAvailableArty;
			
			//if (isNull _SelectedArty) exitWith {if (_debug) then {format ["%1: No Artillery Available.", _Module] remoteExec ["systemchat", TO_ALL_PLAYERS];}; true};
			//if (_Rmesg or _debug) then {format ["%1: Spotted potential Target. Try to call Artillery.", _Module] remoteExec ["systemchat", TO_ALL_PLAYERS];};
			if (isNull objectParent _SelectedArty) then {
				[(group _SelectedArty),_Module, getDir _SelectedArty] spawn HBQSS_fnc_DelpoyStaticWeapons; 
				sleep 7;
				_SelectedArty = objectParent (((units group _SelectedArty) select {!(isNull objectParent _x)}) select 0);
			} else {
				_SelectedArty = objectParent _SelectedArty;
			};
			
			

			
			sleep _SupportCallDelay;
			if !(_Spottergroup getVariable ["HBQ_isSpotting",true]) exitWith {true};
			if (_Spottergroup getVariable ["HBQ_CancelSpotter",false]) exitWith {true};
			if ((group _SelectedArty) getVariable ["HBQ_arty_availForMission",true] == false) exitWith {{if (_debug or _Rmesg) then {format ["%1: Artillery Not available anymore.", _Module] remoteExec ["systemchat", TO_ALL_PLAYERS];}; true};};
			if (random 1 <= _SupportCallChance) then {
				if (count (units _Spottergroup) == 0) exitWith {if (_debug) then {format ["%1: Spotter was killed before he could request Artillery.", _Module] remoteExec ["systemchat", TO_ALL_PLAYERS];}}; // If group dies no Strike will be called
				private _RandomTarget = selectrandom _ValidTargets;
				if (((leader _Spottergroup) distance2d _RandomTarget) > _LaseDistance ) exitWith {true}; // If target got out of lease range no Strike will be called
				if (isNull _SelectedArty) exitWith {if (_debug) then {format ["%1: Artillery Not available anymore.", _Module] remoteExec ["systemchat", TO_ALL_PLAYERS];}}; // If Artillery dies no Strike will be called
				
				private _grpArray = [_Spottergroup, _RandomTarget];
				private _typeArray = [(group _SelectedArty)getVariable ["HBQ_TypeOfShells",""],false];
				(group _SelectedArty) setVariable ["HBQ_arty_availForMission",false,true];// PUBLIC
				
				enableEngineArtillery true;
				[_grpArray,_SelectedArty,_typeArray,_DangerCloseDistance,_Module,false] remoteExec  ["HBQSS_fnc_ArtilleryStrike", owner _SelectedArty];;
				
				
				[(group _SelectedArty)] spawn {
				params ["_group"];
				private _Cooltme = _group getVariable ["HBQ_ArtyCoolDown",180];
				sleep _Cooltme;
				if (isNull _group) exitWith {true};
				_group setVariable ["HBQ_arty_availForMission",true,true];// PUBLIC
				};
			
			} else {
				if (_Rmesg or _debug) then {format ["%1: Was not able to contact Artillery. Mission canceled.", _Module] remoteExec ["systemchat", 0]}
			};
		
			private _StartTime = time;
			waitUntil {
				private _Currenttime = time;
				private _Timedelta = _Currenttime-_StartTime;
				sleep 2;
				if (_Spottergroup getVariable ["HBQ_CancelSpotter",false]) exitWith {true};
				_Timedelta > _SprtTimeout
			};
		*/
		//};
		

		
		
		/// CAS STRIKE AI
		if ((count _ValidTargets) > 0 && _CanCallCAS ) then {
			
			
		
			//// GET CLOSEST AVAILABLE PLANE/HELI 
			private _SelectedAirVeh  = [_Spottergroup,_RadioRange] call HBQSS_fnc_GetAvailableCAS;
			//if (isNull _SelectedAirVeh) exitWith {if (_debug) then {format ["%1: No CAS Available.", _Module] remoteExec ["systemchat", TO_ALL_PLAYERS];}; true};
			//if ((count _AvailableCASVehicles) == 0) exitWith { if (_debug) then {format ["%1: No CAS Available", _Module] remoteExec ["systemchat", TO_ALL_PLAYERS];};};

			//if (_debug or _Rmesg) then {format ["%1: Spotted potential Target. Try to call CAS.", _Module] remoteExec ["systemchat", TO_ALL_PLAYERS];};
			
			sleep _SupportCallDelay;
			if !(_Spottergroup getVariable ["HBQ_isSpotting",true]) exitWith {true};
			if (_Spottergroup getVariable ["HBQ_CancelSpotter",false]) exitWith {true};
			//if ((group _SelectedAirVeh) getVariable ["HBQ_arty_availForMission",true] == false) exitWith {{if (_debug or _Rmesg) then {format ["%1: Airvehicle is not available anymore.", _Module] remoteExec ["systemchat", TO_ALL_PLAYERS];}; true};};
			if (random 1 <= _SupportCallChance) then {
				//if (count (units _Spottergroup) == 0) exitWith {if (_debug) then {format ["%1: Spotter was killed before he could request CAS.", _Module] remoteExec ["systemchat", TO_ALL_PLAYERS];};true}; // If group dies no Strike will be called
				private _RandomTarget = selectrandom _ValidTargets;
				if (((leader _Spottergroup) distance2d _RandomTarget)> _LaseDistance ) exitWith {true}; // If target got out of lease range no Strike will be called
				//if (isNull _SelectedAirVeh) exitWith {if (_debug) then {format ["%1: Airvehicle is not available anymore.", _Module] remoteExec ["systemchat", TO_ALL_PLAYERS];};true};
				
				private _CasAttackDistance = (group _SelectedAirVeh) getVariable ["HBQ_CasAttackDistance",600];
				private _CasSearchDistance = (group _SelectedAirVeh) getVariable ["HBQ_CasSearchDistance",150];
				(group _SelectedAirVeh) setVariable ["HBQ_arty_availForMission",false,true];// PUBLIC
				[_SelectedAirVeh,getpos _RandomTarget,(leader _Spottergroup),_CasAttackDistance,_CasSearchDistance,false] remoteExec  ["HBQSS_fnc_CAS", owner _SelectedAirVeh]; //// RYD Complex CAS script
				[(group _SelectedAirVeh)] spawn {
				params ["_group"];
				private _Cooltme = _group getVariable ["HBQ_ArtyCoolDown",180];
				sleep _Cooltme;
				if (isNull _group)exitWith {true};
				_group setVariable ["HBQ_arty_availForMission",true,true];// PUBLIC
				};
			
			
				
				
			};
		
			private _StartTime = time;
			waitUntil {
				private _Currenttime = time;
				private _Timedelta = _Currenttime-_StartTime;
				sleep 2;
				if (_Spottergroup getVariable ["HBQ_CancelSpotter",false]) exitWith {true};
				_Timedelta > _SprtTimeout
			};
			
		};
	
	};
	_FirstRun = false;
	private _StartTime = time;
	waitUntil {
		private _Currenttime = time;
		private _Timedelta = _Currenttime-_StartTime;
		sleep 0.5;
		if (_Spottergroup getVariable ["HBQ_CancelSpotter",false]) exitWith {true};
		_Timedelta > 5
	};
};
	
	


_Spottergroup setVariable ["HBQ_CancelSpotter",true,true];
_Spottergroup setVariable ["HBQ_isSpotting",false,true];




