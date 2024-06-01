params["_group","_Crewgroup","_TargetPositionObj","_SpawnType","_threshold","_deleteTime","_DespawnSecurityRadius","_debug","_ReturnToBase",
"_TaskRadius","_EngagmentKnowledge","_LambsTask","_TaskCancelDelay","_DeleteAtTargetposition","_SpawnModule","_SpawnPosition","_TakeCover",
"_FinalEngageTactic","_StealthEngagement","_debug","_Lambs","_Vcom","_DCO_SFSM","_CheckWatchDirection","_Guard","_TCL",
"_Paradrop","_ParachuteOpenAltitude","_StartAirOnGround","_patrol","_FastDisembark","_SpawnedCargoItem","_CargoItemData",
"_CustomVehicleLoadout","_ChecksDelay","_RushTargetPosition","_StaticResetDelay","_SecondaryTargetPosObj","_TaskResetTriggerObj","_LoiterRadius"];

//private _TargetPositionATL = getPosATL _TargetPositionObj;
private _TargetPosition = getPosATL _TargetPositionObj;
private _TargetPosDir = getDir _TargetPositionObj;
private _DeployStaticWeapons = _SpawnModule getVariable ["DeployStaticWeapons",false];
private _EngageWhenEnemyNear = _SpawnModule getVariable ["EngageWhenNearRadius",0];
if (_patrol == "SIMPLE PATROL") then {_TargetPosition = [0,0,0]}; // Simple Patrols should never be able to reach TargetPosition. Only if Areas get active...than groups get new Targetpos.


_group setVariable ["HBQ_TargetPos", _TargetPosition];
_Crewgroup setVariable ["HBQ_TargetPos", _TargetPosition];
////////////    WAIT    ///////////////

// WAIT UNTIL DISTANCE TO TARGETPOSITION IS SMALL EGNOUGH

if (_SpawnType != "INFANTRY") then {
	waitUntil {
		sleep (_ChecksDelay/5);
		if (_SpawnType == "NAVALTRANSPORT")then {sleep 0.1} else {sleep 1};
		if (isNull _Crewgroup) exitWith {true};
		if !(alive (leader _Crewgroup)) exitWith {true};
		if (_Crewgroup getVariable "HBQ_IsEngaging") exitWith {true}; 
		(((leader _Crewgroup) distance2d _TargetPosition) < _threshold) or (_Crewgroup getVariable "HBQ_ReachedTargetPos")

	};

_TargetPosition = _Crewgroup getVariable "HBQ_TargetPos";
if (_patrol != "NONE" && _FinalEngageTactic != "NONE") then {_Crewgroup setVariable ["HBQ_IsExecutingTask",true]};
};

if (isNull _Crewgroup && _SpawnType != "INFANTRY") exitWith {true};

if (_SpawnType == "INFANTRY") then {
	waitUntil {
		sleep (_ChecksDelay/5);
		if (isNull _group) exitWith {true};
		if (isNull (leader _group)) exitWith {true};
		if (_group getVariable "HBQ_IsEngaging") exitWith {true}; 
		(((leader _group) distance2d _TargetPosition) < _threshold) or (_group getVariable "HBQ_ReachedTargetPos")

	};
	
	if (isNull _group && _SpawnType == "INFANTRY") exitWith {true};
	if (_patrol != "NONE" && _FinalEngageTactic != "NONE") then {_group setVariable ["HBQ_IsExecutingTask",true];};
	waitUntil {
		sleep (_ChecksDelay/10);
		if (isNil "_group") exitWith {true};
		if (isNull _group) exitWith {true};
		if (isNull (leader _group)) exitWith {true};
		if (_group getVariable "HBQ_IsEngaging") exitWith {true}; 
		_AllReady = [];	
		{
		_AllReady = _AllReady + [unitReady _x];
		} foreach units _group;
		(false in _AllReady) == false
	};
	
	_TargetPosition = _group getVariable "HBQ_TargetPos";
};

if (isNull _group && _SpawnType == "INFANTRY") exitWith {true};
if (_group getVariable "HBQ_IsEngaging") exitWith {true}; 
if (_Crewgroup getVariable "HBQ_IsEngaging") exitWith {true}; 




////////////////////// IF RUSH TARGETPOS CHANGE AI SETTINGS BACK   ///////////////////////////////////////////////////

if (_RushTargetPosition) then {
	
	[_group,_TakeCover]spawn HBQSS_fnc_ResetRush;
	[_Crewgroup,_TakeCover]spawn HBQSS_fnc_ResetRush;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

_group setFormDir _TargetPosDir;
(vehicle leader _Crewgroup) setUnloadInCombat [true, false];

if (_debug) then {format ["%1: TargetPosition Reached! ", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};



////////////// LAND IF TARGETPOSITION IS ON GROUND  //////////////
if (((vehicle (leader _Crewgroup)) isKindOf "Helicopter") and !_Paradrop and (_TargetPosition select 2) < 5 && _LoiterRadius <= 0) then {
	
	[_TargetPosition,_Crewgroup] spawn HBQSS_fnc_CreateLandingZone;
	
	
	vehicle (leader _Crewgroup) land "LAND";

};


	




if ((_SpawnType == "AIRTRANSPORT" or _SpawnType == "AIRCARGOTRANSPORT") and !_Paradrop and (_TargetPosition select 2) < 5) then {
	waitUntil {
		sleep (_ChecksDelay/5);
		if (isNull _Crewgroup) exitWith {true};
		[vehicle (leader _Crewgroup)]call HBQSS_fnc_CheckIsAirborne == false
	};
};

//////////////  DISEMBARK  ////////////////////
if (!_Paradrop && (_TargetPosition select 2) < 5 && !((vehicle (leader _Crewgroup)) isKindOf "Plane") && _patrol != "SIMPLE PATROL") then {
	if (_SpawnType == "NAVALTRANSPORT") then {
	sleep 7;// Wait for Ships to get closer to Shore
	};
	
	
	waitUntil {
	sleep 0.5;
	(speed vehicle (leader _Crewgroup)) < 5
	};
	sleep 2;


	{
		if (_FastDisembark or _SpawnModule getVariable ["SpawnOneGroup",false]) then {
			sleep 0.3;
			unassignvehicle _x;
			moveout _x;

		} else {
		_x leaveVehicle  vehicle (leader _Crewgroup);
		};
	} foreach units _group;
};

////////////// KNOWLEDGE REVEAL ENEMIES  ////////////////////

if (_EngagmentKnowledge != 0) then {
	private _NearUnits = [(leader _group),side (leader _group),_TaskRadius,false,_SpawnModule]call HBQSS_fnc_getNearUnits;
	private _nearestOtherSide = _NearUnits select 0;
	private _nearestSameSide = _NearUnits select 1;
	{
		(leader _group) reveal [_x, _EngagmentKnowledge];
		(leader _Crewgroup) reveal [_x, _EngagmentKnowledge];
	} foreach _nearestOtherSide;
};

//////////////    DELETE at TargetPosition     ////////////////////

if (_DeleteAtTargetposition) then {
	if (_SpawnType != "INFANTRY") then {
		[_Crewgroup,_SpawnModule] spawn HBQSS_fnc_DeleteOnDestination;
	} else {
		[_group,_SpawnModule] spawn HBQSS_fnc_DeleteOnDestination;
	};
};


//////////////     LAMBS TASK     //////////////

if (_LambsTask != "NONE" && _TakeCover == false ) then {
if !(isNull _group) then {[_group, _TargetPosition, _LambsTask,_TaskRadius,_SpawnType,_TaskCancelDelay,_TaskResetTriggerObj,_SecondaryTargetPosObj,_debug,_DeleteAtTargetposition,_DespawnSecurityRadius,
	_SpawnModule,_CheckWatchDirection,_SpawnPosition,_ReturntoBase,_ChecksDelay] spawn HBQSS_fnc_LambsTaskOnDestination;};

	if (_SpawnType == "VEHICLES") then {
		[_Crewgroup, _TargetPosition, _LambsTask,_TaskRadius,_SpawnType,_TaskCancelDelay,_TaskResetTriggerObj,_SecondaryTargetPosObj,_debug,_DeleteAtTargetposition,_DespawnSecurityRadius,
		_SpawnModule,_CheckWatchDirection,_SpawnPosition,_ReturntoBase,_ChecksDelay] spawn HBQSS_fnc_LambsTaskOnDestination;
	};
};

//////////////     DEPLOY STATIC WEAPON       //////////////     
if (_DeployStaticWeapons && ! (isNull _group)) then {

[_group,_SpawnModule,_TargetPosDir] spawn HBQSS_fnc_DelpoyStaticWeapons;
};



//////////////     RANDOM PATROL       //////////////     

if (_patrol == "RANDOM PATROL") then {
	if(_SpawnType == "VEHICLES" or _SpawnType == "AIRVEHICLES" or _SpawnType == "NAVAL") then {
		[_Crewgroup,_TargetPosition,_TaskRadius,_TaskCancelDelay,_TaskResetTriggerObj,_SecondaryTargetPosObj,_debug,_SpawnModule] spawn HBQSS_fnc_RandomPatrol;
	} else {
		[_group,_TargetPosition,_TaskRadius,_TaskCancelDelay,_TaskResetTriggerObj,_SecondaryTargetPosObj,_debug,_SpawnModule] spawn HBQSS_fnc_RandomPatrol;
	};
};


//////////////     Take Cover    //////////////
if (_TakeCover) then {
	if ((_SpawnType == "INFANTRY" or _SpawnType == "TRANSPORT" or _SpawnType == "AIRTRANSPORT" or _SpawnType == "NAVALTRANSPORT") && !(isNull _group)) then {
		[_group,_TargetPosition,_TargetPosDir,_Vcom,_Lambs,_LambsTask,_DCO_SFSM,_TaskRadius,_SpawnType,_TaskCancelDelay,_TaskResetTriggerObj,_SecondaryTargetPosObj,_debug,_DeleteAtTargetposition,_DespawnSecurityRadius,
		_SpawnModule,_CheckWatchDirection,_SpawnPosition,_ReturntoBase,_TCL,_ChecksDelay] spawn HBQSS_fnc_TakeCover;
	};
	if (_SpawnType == "VEHICLES" or _SpawnType == "NAVAL" or _SpawnType == "AIRVEHICLES") then {
		[_Crewgroup,_TargetPosition,_TargetPosDir,_Vcom,_Lambs,_LambsTask,_DCO_SFSM,_TaskRadius,_SpawnType,_TaskCancelDelay,_TaskResetTriggerObj,_SecondaryTargetPosObj,_debug,_DeleteAtTargetposition,_DespawnSecurityRadius,
		_SpawnModule,_CheckWatchDirection,_SpawnPosition,_ReturntoBase,_TCL,_ChecksDelay] spawn HBQSS_fnc_TakeCover;
	};
};

////////////////////////////    GUARD    ////////////////////////////

if (_Guard) then {
	if (!(isNull _group) &&  (count (units _group) > 0)) then {
	[_group,_TaskCancelDelay,_TaskResetTriggerObj,_SecondaryTargetPosObj,_debug,_TargetPosition,_TaskRadius,false,_SpawnModule] spawn HBQSS_fnc_Guard;
	};
	if (_SpawnType != "INFANTRY" &&  (count (units _Crewgroup) > 0)) then {[_Crewgroup,_TaskCancelDelay,_TaskResetTriggerObj,_SecondaryTargetPosObj,_debug,_TargetPosition,_TaskRadius,true,_SpawnModule] spawn HBQSS_fnc_Guard;};
	if (_debug) then {
		[_TargetPosition vectorAdd [-55,_TaskRadius*0.5], "Guard Zone","ICON","EmptyIcon",[0.5,0.5],600,"ColorBlack",1,0,"DiagGrid",false] spawn HBQSS_fnc_CreateDebugMarker;
		[_TargetPosition, "","ELLIPSE","mil_objective_noShadow",[_TaskRadius,_TaskRadius],_TaskCancelDelay,"ColorBlack",1,0,"Border",false] spawn HBQSS_fnc_CreateDebugMarker;
	};
};


//////////////     PARA DROP       //////////////     

if ((_SpawnType == "AIRTRANSPORT" or _SpawnType == "AIRCARGOTRANSPORT") and _Paradrop) then {
	[vehicle (leader _Crewgroup),_ParachuteOpenAltitude,_CargoItemData,_CustomVehicleLoadout,_group,_SpawnModule] spawn HBQSS_fnc_Paradrop;
};
	

/////////////////////////    ENGAGE   /////////////////////////

if (_FinalEngageTactic != "NONE" && _EngageWhenEnemyNear <= 0) then {

	if ((_SpawnType == "INFANTRY" or _SpawnType == "TRANSPORT" or _SpawnType == "AIRTRANSPORT" or _SpawnType == "NAVALTRANSPORT") && !(isNull _group) && (count (units _group) > 0)) then {
		[_group,_TaskRadius,_debug,false,_FinalEngageTactic,_StealthEngagement,_SpawnType,_SpawnModule] spawn HBQSS_fnc_Engage;
	};
	if (_SpawnType == "VEHICLES" or _SpawnType == "NAVAL" or _SpawnType == "AIRVEHICLES" && (count (units _Crewgroup) > 0)) then {
		[_Crewgroup,_TaskRadius,_debug,false,_FinalEngageTactic,_StealthEngagement,_SpawnType,_SpawnModule] spawn HBQSS_fnc_Engage;
	};

};


/////////////////// FOLLOW GROUP   ///////////////

private _FollowGroup = _SpawnModule getVariable ["FollowGroup",""];
private _FollowGroupObj = missionNamespace getVariable [_FollowGroup , objNull];

if !(isNull _FollowGroupObj) then {
	if (_debug) then {format ["%1: Following Group.", _SpawnModule]remoteExec ["systemchat", TO_ALL_PLAYERS];};
	
	
	/// TRANSPORT OR VEHICLES? DEFINE GROUP
	private _myGroup = grpnull;
	if (_SpawnType == "INFANTRY" or _SpawnType == "TRANSPORT" or _SpawnType == "AIRTRANSPORT" or _SpawnType == "NAVALTRANSPORT") then {
		_myGroup = _group;
	};
	if (_SpawnType == "VEHICLES" or _SpawnType == "NAVAL" or _SpawnType == "AIRVEHICLES") then {
		_myGroup = _Crewgroup;
	};
	
	
	if (typeName _SecondaryTargetPosObj == "GROUP") then {
	[_myGroup,_FollowGroupObj,30,15,_debug,false,_TaskCancelDelay,_TaskResetTriggerObj]spawn HBQSS_fnc_Follow;
	};

	// Object is HBQ_Spawner Modul
	if (typeOf _FollowGroupObj == "HBQ_Spawner") then {
		
		// Get nearest Group that is spawned by the Spawner that is choosen
		private _NearUnitsSpawnedby = (entities [["Man"], [], true, true]) select {(group _x) GetVariable ["HBQ_SpawnedBy",objnull] == _FollowGroupObj};
		if (count _NearUnitsSpawnedby == 0) exitWith {true};

		
		
		// Sort by Distance
		_NearUnitsSpawnedby = _NearUnitsSpawnedby apply { [_x distance (leader _myGroup), _x] };
		_NearUnitsSpawnedby sort true;
		private _NearestUnitSpawnedby = _NearUnitsSpawnedby select 0 select 1;
		
		
		private _GrouptoFollow = group _NearestUnitSpawnedby;
		if !(isNull _GrouptoFollow) then {
			[_myGroup,_GrouptoFollow,30,15,_debug,false,_TaskCancelDelay,_TaskResetTriggerObj]spawn HBQSS_fnc_Follow;
		};
	};
};

//////////////     TROOP/CARGO TRANSPORT   //////////////

// SPAWNTYPE TRANSPORT (Split Driver and Gunner to extra Driver Group)
if (_SpawnType != "INFANTRY") then {
	private _Vehicle = vehicle (leader _Crewgroup);
	private _Driver = driver _Vehicle;
	private _VehicleIsArmed = [_Vehicle]call HBQSS_fnc_IsVehicleArmed;

	// Wait for Troops to unload
	if ((_SpawnType == "TRANSPORT" or  _SpawnType == "NAVALTRANSPORT" or _SpawnType == "AIRTRANSPORT") && _patrol != "SIMPLE PATROL")  then {
		_Driver disableAI "AUTOCOMBAT";
		_Driver disableAI "AUTOTARGET";
		if((_TargetPosition select 2) < 5) then {
			waitUntil {
				sleep (_ChecksDelay/10);
				if (isNil{_Vehicle}) exitWith{};
				[_Vehicle] call HBQSS_fnc_CheckTroopsDisembarked
			};
		};
	sleep 10;
	};

	// Cargo unloading
	if ((_SpawnType == "CARGOTRANSPORT" or (_SpawnType == "AIRCARGOTRANSPORT" && !_Paradrop)) && (_TargetPosition select 2) < 5 && _patrol != "SIMPLE PATROL") then {
		_Driver disableAI "AUTOCOMBAT";
		_Driver disableAI "AUTOTARGET";
		sleep 5;
		
		// Wait till Airvehicle is landed
		if (_SpawnType == "AIRCARGOTRANSPORT") then {
			waitUntil {
				sleep (_ChecksDelay/5);
				[_Vehicle]call HBQSS_fnc_CheckIsAirborne == false
			};
			sleep 5;
		};
		sleep 4;
		if (_debug) then {
		format ["%1: Unloading Cargo", _SpawnModule]remoteExec ["systemchat", TO_ALL_PLAYERS];
		};
		if (HBQSS_ACE_Loaded)then {
			if (_ReturnToBase) then {
			[_SpawnedCargoItem,_Vehicle,objNull] call ace_cargo_fnc_unloadItem;
			"SmokeShellBlue" createVehicle position _SpawnedCargoItem;
			_group setVariable ["HBQ_CargoUnloaded",true];
			
			}; // Dont unload when Return to base is disabled
			
		} else {
			[_CargoItemData,_CustomVehicleLoadout,getpos _Vehicle,_SpawnModule]spawn HBQSS_fnc_UnloadCargo;
			_group setVariable ["HBQ_CargoUnloaded",true];
		};
	};

	// UnArmedVehicle Disable Driver FSM
	if (not _VehicleIsArmed and _ReturntoBase && _patrol != "SIMPLE PATROL") then {
		//_Driver disableAI "FSM";
		_Driver setVariable ["SFSM_excluded", true];
		_Driver setVariable ["lambs_danger_disableAI", true];
		_Driver setVariable ["lambs_danger_dangerRadio", false];
		_Crewgroup setVariable ["lambs_danger_disableGroupAI", true];
		_Crewgroup setVariable ["Vcm_Disable",true];
		_Crewgroup setVariable ["lambs_danger_enableGroupReinforce", false,true];
		(leader _Crewgroup) setCombatMode "GREEN";
		_Crewgroup setCombatMode "YELLOW";
	};

	if (_patrol != "SIMPLE PATROL") then {_Crewgroup setVariable ["HBQ_ReachedTargetPos", true,true]};
	
	// APC ENGAGMENT
	// ENGAGE Enemy (if Vehicle is Armed than Do Follow the other Team)
	if (_FinalEngageTactic != "NONE" && _patrol != "SIMPLE PATROL") then {

		if (_debug) then {
			[_TargetPosition vectorAdd [-55,_TaskRadius*0.5], "Engage Radius","ICON","EmptyIcon",[0.5,0.5],600,"ColorBlack",0.6,0,"DiagGrid",false] spawn HBQSS_fnc_CreateDebugMarker;
			[_TargetPosition, "","ELLIPSE","mil_objective_noShadow",[_TaskRadius,_TaskRadius],_TaskCancelDelay,"ColorRed",0.4,0,"Border",false] spawn HBQSS_fnc_CreateDebugMarker;
		};

		if (_VehicleIsArmed and _SpawnType == "TRANSPORT" and !_ReturnToBase  && (count (units _Crewgroup) > 0)) then {
			
			_Crewgroup setVariable ["VCM_NOFLANK",true];
			_Crewgroup setVariable ["lambs_danger_enableGroupReinforce", false,true];
			
			if (_StealthEngagement) then {
				_Crewgroup setBehaviourStrong "STEALTH";
				_Crewgroup setCombatMode "GREEN";
			};
			
			if (_debug)then {
				format ["Engagement Started. Tactic: %1", _FinalEngageTactic]remoteExec ["systemchat", TO_ALL_PLAYERS];
			};
			
			[_Crewgroup,_TaskRadius,_debug,true,_FinalEngageTactic,_StealthEngagement,_SpawnType,_SpawnModule] spawn HBQSS_fnc_Engage; // Do Follow TRUE
		}; 
	};

	if (_ReturntoBase && (_SpawnType == "TRANSPORT" or _SpawnType == "AIRTRANSPORT") && (count (units _Crewgroup) > 0) )  then {
		sleep 5; // Wait a bit so troops can unmount and get safe distance to vehicle.
		[_Crewgroup,_debug,_SpawnModule,false] spawn HBQSS_fnc_ReturnToBase;
	};
	
}; // End Troop Transport


//////////////     RETURN TO BASE       //////////////     

if (_ReturntoBase && ( _SpawnType != "INFANTRY" && (_SpawnType != "TRANSPORT" && _SpawnType != "AIRTRANSPORT")) && _LambsTask == "NONE" && _Guard == false && (count (units _Crewgroup) > 0)) then {
	[_Crewgroup,_debug,_SpawnModule,true] spawn HBQSS_fnc_ReturnToBase;
};

if ((_ReturntoBase && _SpawnType == "INFANTRY" && _LambsTask == "NONE" && _FinalEngageTactic == "NONE" && _Guard == false) && !(isnull _group) && (count (units _group) > 0)) then {
	[_group, _debug,_SpawnModule,true] spawn HBQSS_fnc_ReturnToBase;
};



// Set Reached Target Position Variable to True
if (_patrol != "SIMPLE PATROL") then {_group setVariable ["HBQ_ReachedTargetPos", true,true]};


