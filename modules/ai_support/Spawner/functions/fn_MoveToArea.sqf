#include "script_component.hpp"
params ["_unit","_TargetPos","_isCrew","_debug","_SpawnModule","_Behaviour","_ActiveArea","_ActiveTargetObj","_AreasAreObjects","_AreaIsGroup","_SpawnModule","_ChecksDelay","_SpawnType"];
if (_unit getVariable "HBQ_IsForcedToMove") exitWith {true};
private _Delaymultiplier = 1;
if (_isCrew) then {_Delaymultiplier = 0.5};

if (_debug && _unit == leader group _unit) then {
	if (_AreasAreObjects) then {
		format ["%1: Group moves to %2.", _SpawnModule,_ActiveTargetObj] remoteExec ["systemchat", 0]
		} else {
		format ["%1: Group moves to %2.", _SpawnModule,_ActiveArea] remoteExec ["systemchat", 0]
		};
};
if ((group _unit) getVariable "HBQ_IsEngaging") exitWith {true};
if ((group _unit) getVariable "HBQ_IsExecutingTask") exitWith{true};
if ((group _unit) getVariable "HBQ_IsFleeing") exitWith {true};
if (_unit getVariable ["HBQ_IsForcedToMove",false]) exitWith {true};
_unit setVariable ["HBQ_IsForcedToMove",true];
_unit setUnitPos "UP";
(group _unit) setBehaviourStrong "AWARE";

if (_SpawnModule getVariable "StaticAI") then {_unit enableAI "PATH"};


//// Pack StaticWeapons

if (_SpawnType == "TURRETS" or ((group _unit) getVariable ["HBQ_isArtillery",false]) or _SpawnModule getVariable ["DeployStaticWeapons",false]) then {
		
	if (count (units group _unit) >= 3 ) then {
		sleep 5;
		if ( (objectparent _unit) isKindOf "StaticWeapon") then {
			[(group _unit),_SpawnModule] spawn HBQSS_fnc_PackStaticWeapon;
			
			sleep 5;
		
		
		};

	};
};




if (_unit == leader group _unit) then {
	_unit doMove getpos _unit;
	_unit doMove _TargetPos;
	(group _unit) setVariable ["HBQ_TargetPos", _TargetPos];
} else {
	_unit doFollow (leader group _unit);
};

///// CARGO TRANSPORT
if ((_SpawnType == "AIRCARGOTRANSPORT" or _SpawnType == "CARGOTRANSPORT") && _isCrew) then {
	(driver vehicle _unit) disableAI "TARGET";
	(driver vehicle _unit) disableAI "AUTOCOMBAT";
	(driver vehicle _unit) disableAI "AUTOTARGET";
	//(driver vehicle _unit) enableAI "MOVE";
	(driver vehicle _unit) enableAI "PATH";
	(driver vehicle _unit) setBehaviour "CARELESS";
	(vehicle _unit) allowCrewInImmobile true;
	(vehicle _unit) setUnloadInCombat [false, false];
};


//////////////  DELETE  AND ADD NEW WAYPOINTS  ////////////////////
if (_unit == leader group _unit) then {
	
	if(count waypoints (leader group _unit) > 0) then {
		{deleteWaypoint((waypoints (leader group _unit))select 0);}forEach waypoints (leader group _unit);
	};

	_wp1 = (group _unit) addWaypoint [[_TargetPos select 0,_TargetPos select 1,0],0];
	_wp2 = (group _unit) addWaypoint [[_TargetPos select 0,_TargetPos select 1,0],0];
	_wp2 setWaypointStatements ["true", "(group this) setVariable ['HBQ_ReachedTargetPos',true,true];"];
	if (!(_SpawnType == "AIRCARGOTRANSPORT" or _SpawnType == "CARGOTRANSPORT") && !(_AreasAreObjects or _AreaIsGroup)) then {_wp2 setWaypointType "SAD"};
};

private _distance = (getpos _unit) distance2d _TargetPos;
switch (true) do
{
	case (_distance < 30) : { sleep (_ChecksDelay*_Delaymultiplier);};
	case (_distance >= 30 && _distance < 60) : { sleep (_ChecksDelay*2*_Delaymultiplier); };
	case (_distance >= 60 && _distance < 200) : { sleep (_ChecksDelay*3*_Delaymultiplier); };
	case (_distance >= 200 && _distance < 500) : { sleep (_ChecksDelay*4*_Delaymultiplier); };
	case (_distance >= 500 ) : { sleep (_ChecksDelay*6*_Delaymultiplier);};
	default { sleep 10; };
};
if (isNull _unit) exitWith {};
if !(Alive _unit) exitWith {};

if (_unit != leader group _unit) then {[_unit] joinSilent group _unit;_unit doFollow (leader group _unit)};
_unit setUnitPos "AUTO";
_unit setVariable ["HBQ_IsForcedToMove",false];



/// DEPLOY STATIC WEAPON
if (_SpawnModule getVariable ["DeployStaticWeapons",false] ) then {
	if (_unit == leader group _unit) then {
		sleep (_ChecksDelay*2);
		private _cancel = false;
		private _time = time;
		waituntil {
			sleep 1;
			
			private _newtime = time;
			if (_unit getVariable ["HBQ_IsForcedToMove",false] == true ) exitWith {_cancel = true; true};
			(_newtime - _time) > 20
		};
		
		
		
		if ((group _unit) getVariable ["HBQ_ReachedTargetPos", false] && _cancel == false) then {
			[group _unit,_SpawnModule, getDir _unit] spawn HBQSS_fnc_DelpoyStaticWeapons;
		};
	};
};


