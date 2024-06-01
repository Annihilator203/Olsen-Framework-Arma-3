params["_PlayerSecurityRadius","_SpawnPosition","_Side","_RebelWeapon","_RebelMagazine","_RushTargetPosition","_MinSpawnAmount","_MaxSpawnAmount",
"_Vcom","_Lambs","_DCO_SFSM","_RandomGroupData","_VehicleData","_SpawnModule","_debug","_LambsTask","_SyncedMovePositions","_SpawnType",
"_DeleteAtTargetposition","_ReturntoBase","_TaskCancelDelay","_patrol","_DynamicSimulation","_Reinforcments","_IgnoreHCTransfer","_VehicleSpeed","_VehicleLocked",
"_SpawnDirection","_HideChance","_RebelChance","_HotZone","_MaxFriendliesInZone","_MinEnemiesInZone","_ForcesBalancing","_MaxUnconscious",
"_deleteTime","_TakeCover","_SpawnAngle","_EnableBalancing","_AI_FeatureActivationDelay","_SpawnPosObj","_StaticAI","_StaticResetDelay","_TaskRadius",
"_EngagmentKnowledge","_ExitStatic","_FinalEngageTactic","_StealthEngagement","_AllowFleeing","_HoldFireAttackTime",
"_VehicleCrewed","_HoldFireEnemyDistance","_CamouflageCoef","_UseOptimizedSpawnMethod","_LambsRadio","_ShutUp","_SuppressionThreshold",
"_CheckWatchDirection","_TCL","_Guard","_DCOVehicleFSM","_FlyHight","_Paradrop","_ParachuteOpenAltitude","_StartAirOnGround","_FastDisembark",
"_CustomVehicleLoadout","_CargoItemData","_VehicleFuelConsumeRate","_TriggerRadius","_SpawnProbability","_Raycasting","_SetFormationPosition",
"_LoiterRadius","_DespawnSecurityRadius","_ChecksDelay","_RetreatGroupsize","_JoinNearGroups","_LeaderDistance","_CustomLoadout","_ACE_unconscious",
"_SecondaryTargetPosObj","_TaskResetTriggerObj","_ExitStaticShotsNear","_EngageWhenEnemyNear","_StayInAreas","_SafeSpawnPositionRadius","_SyncedArtyModule",
"_SyncedSpotterModule","_SyncedCASmodule","_MasterGroup","_MasterCrewGroup","_LastSpawn","_FirstSpawn"];

if (!isServer && hasinterface) exitWith {true}; // Not sure if necessary

private _SingleGroup = _SpawnModule getVariable ["SpawnOneGroup",false];


if (isNil "_SpawnModule") exitWith {true};
if (isNull _SpawnModule) exitWith {true};
if ((_SpawnModule getVariable "HBQ_WaveBudget")<= 0 and (_SpawnModule getVariable "HBQ_WaveBudget")!= -100) exitWith {true};
private _ConvoyMode = false;

if ((_SpawnModule getVariable ["ConvoySeparation",0]) > 0 ) then {_ConvoyMode = true};

if (_ConvoyMode) then {_SingleGroup = true};

private _KillTrigger = _SpawnModule getVariable ["KillTrigger",""];
private _KillTriggerObj = missionNamespace getVariable [_KillTrigger, objNull];
if ((_SpawnPosition select 0) == 0) exitWith {if(_debug)then { format ["%1: Found no Spawnposition", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS]}; true};

if (_SingleGroup && !_FirstSpawn) then {
	waitUntil {
	sleep 0.5;
	_SpawnModule getVariable ["HBQ_IsSpawning",false] == false
	};
};

_SpawnModule setVariable ["HBQ_IsSpawning",true];





/////// SPAWN PROBABILITY  /////////////

private _FinalProbability = _SpawnProbability;
if (HBQSS_ProbabilityScalingEnabled) then {
	private _playerCount = count allPlayers;
	_FinalProbability = (_playerCount/HBQSS_DefaultPlayerCount)*_SpawnProbability;
} else {
	if (_SpawnProbability > 1) then {_FinalProbability = 1};
};

If (random 1 >= _FinalProbability) exitWith {};

_SpawnModule setVariable ["HBQ_GroupsSpawned", (_SpawnModule GetVariable "HBQ_GroupsSpawned")+1,true];// PUBLIC ??

/// Variables
private _GroupSizeRound = round (_MinSpawnAmount + random ((_MaxSpawnAmount-_MinSpawnAmount)+0.1));
private _GroupSizeFinal = _GroupSizeRound;
private _VehiclePosition =_SpawnPosition;
private _RandomMoveposition = selectRandom _SyncedMovePositions;
private _SpawnedVehicle = ObjNull;
private _SpawnedCargoItem = ObjNull;
private _AI_NewFeatureActivationDelay = 0;
private _unit = ObjNull;
//private _Crewgroup = GrpNull;

///////////////////////  WAIT FOR SPAWN CONDITIONS  ///////////////////////////////////

_SpawnPosObj setVariable ["HBQ_TriggerCheck",false];
_SpawnPosObj setVariable ["HBQ_PlayerNearCheck",false];
_SpawnPosObj setVariable ["HBQ_BalancingCheck",false];

if (_TriggerRadius > 0) then {
[_SpawnPosObj, _SpawnPosition,_Side,_TriggerRadius,_SpawnModule,_ChecksDelay] spawn HBQSS_fnc_TriggerRadiusCheckUpdate;
} else {
_SpawnPosObj setVariable ["HBQ_TriggerCheck",true];
};

if (_PlayerSecurityRadius > 0) then {
[_PlayerSecurityRadius,_SpawnPosObj,_SpawnPosition,_SpawnModule,_ChecksDelay,_debug,_CheckWatchDirection] spawn HBQSS_fnc_PlayerNearCheckUpdate;
} else {
_SpawnPosObj setVariable ["HBQ_PlayerNearCheck",true];
};


if (_EnableBalancing) then {
[_SpawnPosObj,_Side,_SpawnModule,_ChecksDelay,_HotZone,_MaxUnconscious,_MinEnemiesInZone,_MaxFriendliesInZone,_ForcesBalancing,_debug] spawn HBQSS_fnc_BalancingChecksUpate;
} else {
_SpawnPosObj setVariable ["HBQ_BalancingCheck",true];
};


////// WAIT TIL ALL CONDITIONS ARE MET
waitUntil {
if (_TriggerRadius > 0) then {sleep (_ChecksDelay/2) ; sleep random _ChecksDelay };
if (_PlayerSecurityRadius > 0) then {sleep (_ChecksDelay/2);sleep random _ChecksDelay};
if (_EnableBalancing) then {sleep (_ChecksDelay/2);sleep random _ChecksDelay};
if (isNull _SpawnPosObj) exitWith {true};
_SpawnPosObj getVariable "HBQ_TriggerCheck" && _SpawnPosObj getVariable "HBQ_PlayerNearCheck" && _SpawnPosObj getVariable "HBQ_BalancingCheck"
};

if (isNull _SpawnPosObj) exitWith {true};

_SpawnPosObj setVariable ["HBQ_TriggerCheck",false];
_SpawnPosObj setVariable ["HBQ_PlayerNearCheck",false];
_SpawnPosObj setVariable ["HBQ_BalancingCheck",false];

/// IF TERMINATED  EXIT
if (_SpawnModule getVariable "HBQ_SpawnsTerminated") exitWith {true};


////////////////////////////////////       GROUP INITIALIZATION       ////////////////////////////////////
private _group = grpNull;

if (_SingleGroup && _ConvoyMode == false && _SpawnType != "VEHICLES" &&  _SpawnType != "AIRVEHICLES"  &&  _SpawnType != "NAVAL") then {
_group = _MasterGroup;
} else {
_group = createGroup [_Side,true];
[_group]call HBQSS_fnc_deleteGroupWhenEmpty;

};
_group setFormDir _SpawnDirection;


private _Crewgroup = grpNull;

if (_SingleGroup) then {
_Crewgroup = _MasterCrewGroup;
} else {
_Crewgroup = createGroup [_Side,true];
[_Crewgroup]call HBQSS_fnc_deleteGroupWhenEmpty;

};

_Crewgroup setFormDir _SpawnDirection;



///////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////       VEHICLES        ////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////


if (_SpawnType != "INFANTRY") then {

	if (isNil "_SpawnModule") exitWith {true};
	if (isNull _SpawnModule) exitWith {true};
	private _CombatmodeCrewgroup = _VehicleData select 0 select 3;
	private _CallSignCrew  = "";
	private _AllowDamageVehicle = true;
	private _VehicleAmmo = 1;
	private _VehicleDamage = 0;
	private _VehicleFuel = 1;
	private _VehicleAceSupply = -1;
	private _VehicleAceFuelSupply = -1;
	private _VehicleAceMedic = false;
	private _VehicleAceRepair = false;
	private _CrewFormation = "COLUMN";
	private _Behaviour = _VehicleData select 0 select 0 select 0 select 4;
	_CrewFormation = _VehicleData select 0 select 0 select 0 select 6;
	private _Speed = _VehicleData select 0 select 4;
	if (_SingleGroup && _FirstSpawn) then {
	_SpawnModule setVariable ["HBQ_CrewFormation", _VehicleData select 0 select 0 select 0 select 6] ;
	_SpawnModule setVariable ["HBQ_Speed", _VehicleData select 0 select 4] ;
	_SpawnModule setVariable ["HBQ_Behaviour", _VehicleData select 0 select 0 select 0 select 4] ;
	};
	
	if (_SingleGroup && _LastSpawn) then {
		_CrewFormation = _SpawnModule getVariable ["HBQ_CrewFormation",""];
		_Speed =_SpawnModule getVariable ["HBQ_Speed","NOMRAL"];
		_Behaviour =_SpawnModule getVariable ["HBQ_Behaviour","AWARE"];
	};
	
	if (_ConvoyMode) then {_CrewFormation = "COLUMN"};
	
	
	if (_SpawnType == "AIRVEHICLES" or _SpawnType == "AIRTRANSPORT" or _SpawnType == "AIRCARGOTRANSPORT") then {
	_VehicleFuel = _VehicleData select 0 select 10;
	_CallSignCrew = _VehicleData select 0 select 12;
	_AllowDamageVehicle = _VehicleData select 0 select 13;
	_VehicleAmmo = _VehicleData select 0 select 14;
	_VehicleDamage = _VehicleData select 0 select 15;
	
	_VehicleAceSupply = _VehicleData select 0 select 16;
	_VehicleAceFuelSupply = _VehicleData select 0 select 17;
	_VehicleAceMedic = _VehicleData select 0 select 18;
	_VehicleAceRepair = _VehicleData select 0 select 19;

	} else {
	_VehicleFuel = _VehicleData select 0 select 10;
	_CallSignCrew = _VehicleData select 0 select 11;
	_AllowDamageVehicle = _VehicleData select 0 select 12;
	_VehicleAmmo = _VehicleData select 0 select 13;
	_VehicleDamage = _VehicleData select 0 select 14;
	_VehicleAceSupply = _VehicleData select 0 select 15;
	_VehicleAceFuelSupply = _VehicleData select 0 select 16;
	_VehicleAceMedic = _VehicleData select 0 select 17;
	_VehicleAceRepair = _VehicleData select 0 select 18;
	
	};
	
	

	
	// SPAWNPOSITION
	if (_SpawnType == "NAVALTRANSPORT" or _SpawnType == "NAVAL") then {
		private _TempVehiclePosition = [_SpawnPosition, 0, 5, 3, 2, 20, 0] call BIS_fnc_findSafePos;
		_VehiclePosition = [_TempVehiclePosition select 0,_TempVehiclePosition select 1, -1];
	};
	if (_SpawnType == "TRANSPORT" or _SpawnType == "VEHICLES" or _SpawnType == "CARGOTRANSPORT") then {
		if (_SafeSpawnPositionRadius != 0) then {
		_TempVehiclePosition = [_SpawnPosition, 0, _SafeSpawnPositionRadius, 5, 0, 20, 0] call BIS_fnc_findSafePos;
		_VehiclePosition = [_TempVehiclePosition select 0,_TempVehiclePosition select 1, 0];
		} else {
		_VehiclePosition = [_SpawnPosition select 0,_SpawnPosition select 1, 0];
		};
		
	};

	if (_SpawnType == "AIRVEHICLES" or _SpawnType == "AIRTRANSPORT"  or _SpawnType == "AIRCARGOTRANSPORT") then {
		if !(_StartAirOnGround) then {
			_VehiclePosition = [_SpawnPosition select 0,_SpawnPosition select 1,(_SpawnPosition select 2)+_FlyHight];
			
		} else {
			_VehiclePosition = [_SpawnPosition select 0,_SpawnPosition select 1,0];
			
		};
	};

	// SPAWN VEHICLE
	private _PlacementRadius = 0;
	private _Special = "CAN_COLLIDE";
	if (_SpawnType == "TRANSPORT" or _SpawnType == "VEHICLES" or _SpawnType == "NAVALTRANSPORT" or _SpawnType == "NAVAL" or _SpawnType == "CARGOTRANSPORT" ) then {_Special = "NONE";_PlacementRadius = 0;};
	if ((_SpawnType == "AIRVEHICLES" or _SpawnType == "AIRTRANSPORT" or _SpawnType == "AIRCARGOTRANSPORT") and ((not _StartAirOnGround) or (_SpawnPosition select 2)> 5)) then {_Special = "FLY";};
	
	_SpawnedVehicle = createVehicle [_VehicleData select 0 select 5, _VehiclePosition, [], _PlacementRadius, _Special];
	_SpawnedVehicle setDir _SpawnDirection;
	
	
	// CREATE CREW
	
	if (_VehicleCrewed) then {
	
		[_Crewgroup,_Speed,_TCL,_DespawnSecurityRadius,_debug,_deleteTime,_CheckWatchDirection,_DynamicSimulation,_SpawnDirection,_AllowFleeing,_IgnoreHCTransfer,
		_Reinforcments,_Vcom,_Lambs,_ChecksDelay,_SpawnModule,_ACE_unconscious,_SpawnType,true,"AUTO",_SpawnPosition,_RushTargetPosition,_SyncedArtyModule,
		_SyncedCASmodule,_SyncedSpotterModule,_ExitStaticShotsNear,_KillTriggerObj,_CrewFormation] call HBQSS_fnc_GroupSettings;
		
		
		[_VehicleData,_SpawnPosition,_Crewgroup,_LambsRadio,_UseOptimizedSpawnMethod,_SpawnModule,
		_AI_FeatureActivationDelay,_StaticAI,_ShutUp,_SpawnedVehicle,_Raycasting,_SpawnType,_RushTargetPosition,
		_CustomLoadout,_AllowDamageVehicle,_SyncedArtyModule,_SpawnDirection,_Lambs,_DCO_SFSM,_Behaviour] call HBQSS_fnc_CreateVehicleCrew;	
		
		
		/////////////// AI MODS GROUP SETTINGS
		
		if !(_RushTargetPosition) then {
		_Crewgroup setVariable ["TCL_Disabled", not _TCL];
		if (_Reinforcments) then {_Crewgroup setVariable ["lambs_danger_enableGroupReinforce", _Reinforcments,true];};// PUBLIC 
		_Crewgroup setVariable ["lambs_danger_disableGroupAI", not _Lambs];	
		if (_Lambs) then {_Crewgroup setVariable ["lambs_danger_dangerFormation", "LINE"]};
		};
		_Crewgroup setVariable ["Vcm_Disable",not _Vcom];


		//////////// CALL SIGN 
		
		private _IterativeCallSign = _CallSignCrew + "-" + str (_SpawnModule getVariable "HBQ_GroupsSpawned");
		_Crewgroup setGroupId [_IterativeCallSign];
		
		///////////// IS CAS
		
		if (! isNull _SyncedCASmodule) then {
		_Crewgroup setVariable ["HBQ_IsCas",true,true]; // PUBLIC
		};
	
	};
	
	diag_log format ["INFO HBQ: %1: Spawned Vehicle.", _SpawnModule];
	
	
	//////  DEBUG
	
	if (_debug) then {
		[_VehiclePosition, "","ICON","mil_start_noShadow",[0.5,0.5],120,"ColorRed",1,0,"Solid",false] spawn HBQSS_fnc_CreateDebugMarker;
		"FD_CP_Clear_F" remoteExec ["playSound", 0];
		format ["%1: Vehicle Spawned", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
	};

	// Fuel Settings
	
	if (_VehicleFuelConsumeRate > 0) then {[_SpawnedVehicle,_VehicleFuelConsumeRate]spawn HBQSS_fnc_SetFuelConsume};
	
	if (_SpawnType != "TURRETS") then {_SpawnedVehicle setFuel (_VehicleData select 0 select 10)};
	
	// Plane Initial Speed
	
	if ((_SpawnType == "AIRVEHICLES" or _SpawnType == "AIRTRANSPORT" or _SpawnType == "AIRCARGOTRANSPORT") and (not _StartAirOnGround) and _SpawnedVehicle isKindOf "Plane") then {
		//_SpawnedVehicle setDir _SpawnDirection;
		_SpawnedVehicle setPos [_VehiclePosition select 0,_VehiclePosition select 1,(_VehiclePosition select 2)+200];
		
		private _speedProportion = 1; // 1 = Full Speed 0.5 = Half Speed
		private _planeClass = typeOf  _SpawnedVehicle;
		private _landingSpeed = getNumber (configFile >> "CfgVehicles" >> _planeClass >> "landingSpeed");
		private _maxSpeed = getNumber (configFile >>"CfgVehicles" >> _planeClass >> "maxSpeed");
		private _Planespeed = _speedProportion * (2 * _landingSpeed + _maxSpeed);
		_SpawnedVehicle setVelocity ([sin _SpawnDirection, cos _SpawnDirection, 0] vectorMultiply (_Planespeed / 3.6));
	};
	
	// SPAWN CARGOITEM

	if ((_SpawnType == "CARGOTRANSPORT" or _SpawnType == "AIRCARGOTRANSPORT") and !_Paradrop ) then {
		
		_SpawnedCargoItem = createVehicle [_CargoItemData select 0 select 0, [0,0,0], []];
		_SpawnedCargoItem setPos (getPos _SpawnedVehicle);
		
		// SET VEHICLE LOADOUT
		
		if (_CustomVehicleLoadout) then {
			[_SpawnedCargoItem,_CargoItemData]spawn HBQSS_fnc_CreateCustomLoadout;
		};
		
		// CUSTOM INIT CODE CARGITEM
		
		_CustomInitCodeItem = [_SpawnModule getVariable ["CustomInitCodeCargo",""],"spawnedItem","(_this select 0)"]call HBQSS_fnc_stringReplace;

		// RUN CUSTOM INIT CODE
		
		if (_CustomInitCodeItem != "") then {
		private _code = compile _CustomInitCodeItem;  
		[_SpawnedCargoItem] spawn _code; 
		};
		
	};

	// SET VEHICLE LOADOUT
	
	if (_CustomVehicleLoadout and _SpawnType != "TURRETS") then {
		[_SpawnedVehicle,_VehicleData]spawn HBQSS_fnc_CreateCustomLoadout;
	};

	// CONFIGURE AIRVEHICLES
	
	if (_SpawnType == "AIRVEHICLES" or _SpawnType == "AIRTRANSPORT" or _SpawnType == "AIRCARGOTRANSPORT") then {
		if (_FlyHight != -1) then {_SpawnedVehicle flyInHeight _FlyHight};
		if (_FlyHight <= _ParachuteOpenAltitude) then {_ParachuteOpenAltitude = _FlyHight - 10};
		private _pylons = _VehicleData select 0 select 11;
		private _pylonPaths = (configProperties [configFile >> "CfgVehicles" >> typeOf _SpawnedVehicle >> "Components" >> "TransportPylonsComponent" >> "Pylons", "isClass _x"]) apply { getArray (_x >> "turret")};
		{ _SpawnedVehicle removeWeaponGlobal getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon") } forEach getPylonMagazines _SpawnedVehicle;
		{ _SpawnedVehicle setPylonLoadout [_forEachIndex + 1, _x, true, _pylonPaths select _forEachIndex] } forEach _pylons;
	};

	// VEHICLE SETTINGS
	
	_SpawnedVehicle setVariable ["ACE_mortar",false,true]; // PUBLIC
	_SpawnedVehicle setVariable ["HBQ_SpawnType", _SpawnType];
	_SpawnedVehicle setVariable ["HBQ_SpawnedBy", _SpawnModule,true];
	_SpawnedVehicle allowDamage _AllowDamageVehicle;
	
	if !(_DCOVehicleFSM) then {
	_SpawnedVehicle setVariable ["noPush", true, true]; 
	_SpawnedVehicle setVariable ["noFlank", true, true]; 
	_SpawnedVehicle setVariable ["noHide", true, true];
	};
	if (_VehicleAmmo != -1) then {_SpawnedVehicle setVehicleAmmo _VehicleAmmo};
	if (_VehicleDamage != 0) then {_SpawnedVehicle setDamage _VehicleDamage};
	if (_VehicleFuel != 1) then {_SpawnedVehicle setFuel  _VehicleFuel};
	if (_VehicleAceSupply != -1 && HBQSS_ACE_Loaded) then {
	[_SpawnedVehicle, _VehicleAceSupply] call ace_rearm_fnc_makeSource;
	};
	if (_VehicleAceFuelSupply != -1 && HBQSS_ACE_Loaded) then {[_SpawnedVehicle, _VehicleAceFuelSupply] call ace_refuel_fnc_makeSource};
	_SpawnedVehicle SetVariable ["ace_medical_isMedicalVehicle",_VehicleAceMedic,true];
	_SpawnedVehicle SetVariable ["ace_repair_canRepair",_VehicleAceRepair,true];
	
	//CONVOYSEPARATION
	
	if (_ConvoyMode) then {_SpawnedVehicle setConvoySeparation (_SpawnModule getVariable ["ConvoySeparation",0])};
	
	
	
	if ((_SpawnType == "CARGOTRANSPORT" or  _SpawnType == "AIRCARGOTRANSPORT") and HBQSS_ACE_Loaded and !_Paradrop) then {
	[_SpawnedCargoItem, _SpawnedVehicle] call ace_cargo_fnc_loadItem;
	};
	
	
	// LIMIT SPEED TO 9999 TO PREVENT BUG OF ARMA WHERE -1 DOES NOT WORK AS EXSPECTED
	
	if (_VehicleSpeed > 0) then {
		if (_FirstSpawn && _ConvoyMode) then {_SpawnedVehicle limitSpeed _VehicleSpeed * 0.8} else {_SpawnedVehicle limitSpeed _VehicleSpeed }; // First Vehicle of Convoy is a little slower
	} else {
		_SpawnedVehicle limitSpeed 9999;
	};

	// Vehicle Locked
	
	if (_VehicleLocked) then {
		_SpawnedVehicle lock true;
		_SpawnedVehicle setUnloadInCombat [false, false];
		_SpawnedVehicle allowCrewInImmobile true;
    
	};
	
	// Setup Driver AI of Transports
	
	waituntil {sleep 0.2; !isNil{driver _SpawnedVehicle} and simulationEnabled driver _SpawnedVehicle};
	private _driver = driver _SpawnedVehicle;
	[_driver,_ExitStatic,_ExitStaticShotsNear,true] call HBQSS_fnc_AddResetAiEventhandlers;
	private _commander = commander _SpawnedVehicle;
	if (_SpawnType == "TRANSPORT" or _SpawnType == "NAVALTRANSPORT"  or _SpawnType == "AIRTRANSPORT"  or _SpawnType == "CARGOTRANSPORT" or _SpawnType == "AIRCARGOTRANSPORT") then {

		_Crewgroup setVariable ["lambs_danger_disableGroupAI", true];
		_Crewgroup setVariable ["TCL_Disabled", true];
		_driver setVariable ["lambs_danger_disableAI", true];
		_driver setVariable ["SFSM_excluded",true];
		_driver disableAI "AUTOCOMBAT";
		_driver disableAI "AUTOTARGET";
		_driver disableAI "TARGET";
		_driver disableAI "COVER";
	};
	

	///////////////// RUSH TARGETPOSITION  /////////////////
	
	if (_RushTargetPosition) then {
		{[_x,"AUTO"] spawn HBQSS_fnc_RushTargetPos;} forEach units _Crewgroup;
	};
	
	///////////////// Get Cargoseats Capacity of Vehicle and Change Groups size acordingly  /////////////////
	if (_SpawnType == "TRANSPORT" or _SpawnType == "NAVALTRANSPORT" or _SpawnType == "AIRTRANSPORT") then {
		private _VehicleCargoSeats = (_SpawnedVehicle emptyPositions "cargo");
		_GroupSizeFinal = _GroupSizeRound min _VehicleCargoSeats;
	};
	
	///////////////// VEHICLE EVENTHANDLER  /////////////////
	
	if ((_SpawnType != "NAVALTRANSPORT" and _SpawnType != "AIRTRANSPORT") and _VehicleSpeed > 0) then {
 	_SpawnedVehicle addEventHandler ["Dammaged", {
		params ["_unit", "_selection", "_damage", "_hitIndex", "_hitPoint", "_shooter", "_projectile"];
		_unit limitSpeed 9999;
		//_unit removeEventHandler [_thisEvent, _thisEventHandler];
	}]; 
	};
	
	
	//if (_SingleGroup == false) then {_LastSpawn = true}; 
	if (_ConvoyMode == false && _SingleGroup == false) then {_LastSpawn = true}; 
	
	if (_LastSpawn) then {
	
		/////////////////   HOLD FIRE   /////////////////

		if (_HoldFireAttackTime > 0 or _HoldFireEnemyDistance > 0) then {
			[_Crewgroup,_HoldFireAttackTime,_CombatmodeCrewgroup,_debug,_HoldFireEnemyDistance,_SpawnModule]spawn HBQSS_fnc_HoldFire;
		} else {
			_Crewgroup setCombatMode _CombatmodeCrewgroup;
		};
		
		/////////////////////////    ENGAGE WHEN ENEMY NEAR    /////////////////////////
		
		if (_EngageWhenEnemyNear > 0) then {
		[_Crewgroup,_SpawnModule,_debug,_Side,_EngageWhenEnemyNear,true,_ChecksDelay,_SpawnType,_FinalEngageTactic,_StealthEngagement,
		_FastDisembark,_EngagmentKnowledge,_ReturnToBase,_DespawnSecurityRadius,_SpawnPosition,_CheckWatchDirection] spawn HBQSS_fnc_EngageWhenEnemyNear;
		};
		
		//////////////////////////////  STAY IN AREAS   ////////////////////////////////////
		
		if (count _StayInAreas != 0) then {
		[_Crewgroup,_StayInAreas,_TaskCancelDelay,_TaskResetTriggerObj,_ChecksDelay,_debug,_SpawnModule,_SpawnType,_StaticAI,true]spawn HBQSS_fnc_StayInAreas;
		};
		
		/////////////////////////    SECONDARY TARGETPOSITION   /////////////////////////

		if !(isNull _SecondaryTargetPosObj) then {

			[_TaskCancelDelay,_TaskResetTriggerObj,_SpawnModule,_Crewgroup,_SecondaryTargetPosObj,_debug,true] spawn HBQSS_fnc_WaitforCancelTrigger;

		};
		
		/////////////////////////   SPOTTER    /////////////////////////
		if (! isNull _SyncedSpotterModule) then {
		[_crewgroup,_SyncedSpotterModule] spawn HBQSS_fnc_SpotterChecks;
		
		};
	
	};

	
	
	
	
}; // VEHICLES SETUP FINISH




/////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////      INFANTRY       ////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////




private _CombatmodeInfantry = "";
private _StanceInfrantry = "";
private _UnittoSpawn ="";
private _UnitLoadout =[];
private _Skill = 0;
private _Formation = "";
private _Behaviour = "";
private _CallSign = "";
private _AllowDamage = true;
private _TempInfPos = [];
private _InfSpawnPosition = [];


if (_SpawnType == "TRANSPORT" or _SpawnType == "INFANTRY" or _SpawnType == "NAVALTRANSPORT" or _SpawnType == "AIRTRANSPORT" and _GroupSizeFinal != 0 ) then {
	_Behaviour = _RandomGroupData select 0 select 0 select 0 select 4;
	_CombatmodeInfantry = _RandomGroupData select 0 select 3;
	_StanceInfrantry = _RandomGroupData select 0 select 0 select 0 select 3;
	_Formation = _RandomGroupData select 0 select 1;
	_CallSign = _RandomGroupData select 0 select 5;
	
	private _IterativeCallSign = _CallSign + "-" + str (_SpawnModule getVariable "HBQ_GroupsSpawned");
	_group setGroupId [_IterativeCallSign];
	_group setVariable ["HBQ_SpawnFinished",false];


if (_SafeSpawnPositionRadius != 0) then {
		_TempInfPos = [_SpawnPosition, 0, _SafeSpawnPositionRadius, 5, 0, 20, 0] call BIS_fnc_findSafePos;
		_InfSpawnPosition = [_TempInfPos select 0, _TempInfPos select 1, 0];
	} else {
	_InfSpawnPosition = _SpawnPosition;
	};



	
	
	
///////////////// DEBUG
	if (_debug && _SpawnType == "INFANTRY") then {
	[_InfSpawnPosition, "","ICON","mil_start_noShadow",[0.5,0.5],120,"ColorRed",1,0,"Solid",false] spawn HBQSS_fnc_CreateDebugMarker;
	"FD_CP_Clear_F" remoteExec ["playSound", 0];
	format ["%1: Group Spawned", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
	};
	
////////////////////////////////       SPAWN INFRANTRY GROUP    ////////////////////////////////
	for "_i" from 1 to _GroupSizeFinal do {

		// If Groupsize is Bigger than Synced Group select random Units to fill up the Team
		if ((_i - 1) >= (count (_RandomGroupData  select 0 select 0))) then {
			_UnittoSpawn = (selectRandom (_RandomGroupData  select 0 select 0))select 0;
			_UnitLoadout = (selectRandom (_RandomGroupData  select 0 select 0))select 1;
			_Skill = (selectRandom (_RandomGroupData select 0 select 0))select 2;
			_AllowDamage = (selectRandom (_RandomGroupData select 0 select 0))select 5;
		} else {
			_UnittoSpawn = _RandomGroupData  select 0 select 0 select (_i-1) select 0 ;
			_UnitLoadout = _RandomGroupData  select 0 select 0 select (_i-1) select 1 ;
			_Skill = _RandomGroupData select 0 select 0 select (_i-1) select 2;
			_AllowDamage = _RandomGroupData select 0 select 0 select (_i-1) select 5;
		};
		
		
		if (isNil "_SpawnModule") exitWith {true};
		if (isNull _SpawnModule) exitWith {true};
		
		if ((_SpawnModule getVariable "HBQ_WaveBudget") <= 0 and (_SpawnModule getVariable "HBQ_WaveBudget") != -100) exitWith {true};
		if ((_SpawnModule getVariable "HBQ_SpawnsCheck") == false && _i > (_RetreatGroupsize + 1)) exitWith {true};

		
		// CREATE UNIT
		
		if (_SpawnType == "AIRTRANSPORT" and not _StartAirOnGround) then {
			_unit = _group createUnit [_UnittoSpawn,[_InfSpawnPosition select 0,_InfSpawnPosition select 1,-5-_FlyHight], [], 0, "CAN_COLLIDE"];
		} else {
			_unit = _group createUnit [_UnittoSpawn,[_InfSpawnPosition select 0,_InfSpawnPosition select 1,-5], [], 0, "CAN_COLLIDE"];
		};
		

		
		

		// Reduce Unit Budget by 1
		if ((_SpawnModule getVariable "HBQ_WaveBudget") > 0) then {
			_SpawnModule setVariable ["HBQ_WaveBudget",((_SpawnModule getVariable "HBQ_WaveBudget")-1),true];// PUBLIC ??
		};
		

		_unit setVariable ["HBQ_SpwnFin", false];
		
		// DISABLE AI AND SIMULATION (OPTIMIZED SPAWN METHOD)
		if (_UseOptimizedSpawnMethod) then {
			[_unit] call HBQSS_fnc_DisableAI;
			_AI_NewFeatureActivationDelay = (_AI_FeatureActivationDelay/6);
			
		} else {
			_AI_NewFeatureActivationDelay = 0;
		};	
		
		/////// ENABLE AI FEATURES
		
		sleep _AI_NewFeatureActivationDelay;
		_unit enableAI "FSM";
		sleep _AI_NewFeatureActivationDelay;
		_unit enableAI "ANIM";
		sleep _AI_NewFeatureActivationDelay;
		_unit enableAI "ALL";
		
		if (_ShutUp) then {
			_unit disableConversation true;
			_unit disableAI "RADIOPROTOCOL";
		} else {
			_unit disableConversation false;
			_unit enableAI "RADIOPROTOCOL";

		};
		
		sleep _AI_NewFeatureActivationDelay;
		if (_UseOptimizedSpawnMethod) then {_unit enableSimulationGlobal true;};
		
		// AI MOD VARIABLES
		_unit setVariable ["lambs_danger_disableAI", not _Lambs];
		_unit setVariable ["SFSM_excluded", not _DCO_SFSM];
		
		/// ARTY AI
		

		if (!isNull _SyncedArtyModule) then {
			if (_SyncedArtyModule getVariable ["DisableArtyAI",false]) then {
			_unit enableAI "AUTOTARGET";
			_unit setVariable ["SFSM_excluded", true];
			_unit setVariable ["lambs_danger_disableAI", true];
			_unit disableAI "AUTOCOMBAT";
			_unit disableAI "TARGET";
			};
		};



		if (_SpawnType == "TRANSPORT" or _SpawnType == "NAVALTRANSPORT" or _SpawnType == "AIRTRANSPORT") then {
			_unit assignasCargo _SpawnedVehicle; 
			_unit moveInCargo _SpawnedVehicle;
		} else {

			_unit setDir _SpawnDirection;
			_unit setFormDir _SpawnDirection;
			
			if (_SetFormationPosition && _i != 1) then {
				_unit setPos (formationPosition _unit);
			} else {
				_unit setPos _InfSpawnPosition;
			};
		};
		
		

		
		
		sleep _AI_NewFeatureActivationDelay;
		if (_UseOptimizedSpawnMethod) then {_unit hideObjectGlobal false};
		sleep _AI_NewFeatureActivationDelay;
		
		if (_StaticAI) then {_unit disableAI "PATH"} else {_unit enableAI "PATH";};


		
		///////////////    SET VARIABLES     //////////////////////////

		// UNIT SETTINGS
		
		_unit allowDamage _AllowDamage;
		_unit setFormation _Formation;
		_unit setBehaviour _Behaviour;
		_unit setUnitPos _StanceInfrantry;
		[_unit,_Skill,_SpawnModule] spawn HBQSS_fnc_SetSkills;
		_unit setUnitTrait ["CamouflageCoef", _CamouflageCoef];
		_unit setVariable ["lambs_danger_dangerRadio", _LambsRadio];
		if (_Raycasting) then {_unit enableAI "CHECKVISIBLE"} else {_unit disableAI "CHECKVISIBLE"};
		_unit setVariable ["HBQ_IsForcedToMove",false];
		_unit setVariable ["HBQ_SpwnFin", true];
		
		///////////////// CIVILIAN EVENTHANDLER
		if (_Side == civilian) then {
		
			_group setVariable ["HBQ_DespawnSecurityRadius", _DespawnSecurityRadius];
			_group setVariable ["HBQ_CheckWatchDirection", _CheckWatchDirection];
			_group setVariable ["HBQ_RebelWeapon", _RebelWeapon];
			_group setVariable ["HBQ_RebelMagazine", _RebelMagazine];
			[_unit,_HideChance,_RebelChance,_debug]spawn HBQSS_fnc_CivilianEventhandler;
		};
		
		///////////////// KEEP STANCE EVENTHANDLER

		if (_SpawnModule getVariable ["KeepStance",false]) then {
			//AnimStateChanged
			_unit addEventHandler ["AnimChanged",
			{
				params ["_unit", "_anim"];
				private _DefaultStance = (group _unit) getVariable ["HBQ_Stance","AUTO"];
				if (canStand _unit && (behaviour _unit in ["AWARE","COMBAT"])) then {
				_unit setUnitPos _DefaultStance;
				};
			}];
		};

		



	
		///////////////////////   FLEE HIDE RETREAT    ///////////////////////
		
		if (_RetreatGroupsize > 0 && _GroupSizeFinal > 1) then {
			[_unit,_RetreatGroupsize,_DespawnSecurityRadius,_CheckWatchDirection,_debug,_JoinNearGroups,_ChecksDelay,_SpawnModule] spawn HBQSS_fnc_FleeHideCheck;
		};
		
		/////////////////////// RUSH TARGETPOSITION  ///////////////////////
		if (_RushTargetPosition) then {[_unit,_StanceInfrantry] spawn HBQSS_fnc_RushTargetPos;};
		
		/////////////////////// EVENTHANDLERS TO RESET AI  ///////////////////////
		[_unit,_ExitStatic,_ExitStaticShotsNear,false] call HBQSS_fnc_AddResetAiEventhandlers;
	
		/////////////////////// RESET STATIC AI ( Units will continue with Waypoints if they have any)
		if (_StaticResetDelay > 0 or !(isNull  _TaskResetTriggerObj)) then {
			[_unit,_StaticResetDelay,_TaskResetTriggerObj,_SpawnModule] spawn HBQSS_fnc_ResetStaticAI;
		};
		
		sleep (_ChecksDelay/10);
		if (_CustomLoadout) then {_unit setUnitLoadout _UnitLoadout;};
		
	}; // Forloop End (All Units in Group are spawned)
	
	///////////////////////  DEBUG  ///////////////////////

	diag_log format ["INFO HBQ: %1: Spawned %2 units.", _SpawnModule,_GroupSizeFinal];
	
	//// GROUP FINAL SETTINGS
	//_group setFormation _Formation;
	_group setBehaviourStrong _Behaviour;
	private _InfSpeed = _RandomGroupData select 0 select 4;
	[_group,_InfSpeed,_TCL,_DespawnSecurityRadius,_debug,_deleteTime,_CheckWatchDirection,
	_DynamicSimulation,_SpawnDirection,_AllowFleeing,_IgnoreHCTransfer,_Reinforcments,_Vcom,_Lambs,_ChecksDelay,_SpawnModule,
	_ACE_unconscious,_SpawnType,false,_StanceInfrantry,_InfSpawnPosition,_RushTargetPosition,_SyncedArtyModule,_SyncedCASmodule,_SyncedSpotterModule,
	_ExitStaticShotsNear,_KillTriggerObj,_Formation]call HBQSS_fnc_GroupSettings;
	
	///////////////////////  EXIT IF SINGLE GROUP ENABLED  ///////////////////////
	if (_SingleGroup && !_LastSpawn && _ConvoyMode == false) exitWith {_SpawnModule setVariable ["HBQ_IsSpawning",false]}; 


	/////////////////////// KEEP LEADER DISTANCE ///////////////////////
	if (_LeaderDistance > 0 && !_SingleGroup) then {

	[_group,_LeaderDistance,_ChecksDelay] spawn HBQSS_fnc_KeepLeaderDistance;

	};

	/////////////////   HOLD FIRE   /////////////////

	if (_HoldFireAttackTime > 0 or _HoldFireEnemyDistance > 0) then {
		[_group,_HoldFireAttackTime,_CombatmodeInfantry,_debug,_HoldFireEnemyDistance,_SpawnModule]spawn HBQSS_fnc_HoldFire;
	} else {
		_group setCombatMode _CombatmodeInfantry;
	};
	
	/////////////////////////    ENGAGE WHEN ENEMY NEAR    /////////////////////////
	
	if (_EngageWhenEnemyNear > 0) then {
	[_group,_SpawnModule,_debug,_Side,_EngageWhenEnemyNear,false,_ChecksDelay,_SpawnType,_FinalEngageTactic,_StealthEngagement,_FastDisembark,
	_EngagmentKnowledge,_ReturnToBase,_DespawnSecurityRadius,_InfSpawnPosition,_CheckWatchDirection] spawn HBQSS_fnc_EngageWhenEnemyNear;
	};
	
	//////////////////////////////  STAY IN AREAS   ////////////////////////////////////
	
	if (count _StayInAreas != 0) then {
	[_group,_StayInAreas,_TaskCancelDelay,_TaskResetTriggerObj,_ChecksDelay,_debug,_SpawnModule,_SpawnType,_StaticAI,false]spawn HBQSS_fnc_StayInAreas;
	};
	
	/////////////////////////    SECONDARY TARGETPOSITION   /////////////////////////

	if !(isNull _SecondaryTargetPosObj) then {
		[_TaskCancelDelay,_TaskResetTriggerObj,_SpawnModule,_group,_SecondaryTargetPosObj,_debug,false] spawn HBQSS_fnc_WaitforCancelTrigger;
	};
	
	
	/////////////////////////    SPOTTER    /////////////////////////
	if (! isNull _SyncedSpotterModule) then {
	[_group,_SyncedSpotterModule] spawn HBQSS_fnc_SpotterChecks;
	
	};
	


}; ////////////////////////  INFRANTRY SPAWN FINISHED





///////////////////////  EXIT IF SINGLE GROUP ENABLED  ///////////////////////

/* if ((_SpawnModule getVariable ["SpawnOneGroup",false]) && !_LastSpawn) exitWith {
_SpawnModule setVariable ["HBQ_IsSpawning",false];
};  */


_group setVariable ["HBQ_SpawnFinished", true];
_Crewgroup setVariable ["HBQ_SpawnFinished", true];

{
	_x setVariable ["lambs_danger_disableAI", not _Lambs];	
} forEach ((units _group)+(units _Crewgroup));



///////////////////////////////////             WAYPOINTS             ///////////////////////////////////


private _LastWaypoint = objNull;

if (_SpawnType == "INFANTRY") then {
	_LastWaypoint = [_group, _RandomMoveposition, _patrol, _TaskRadius,_SpawnType,_debug,_HotZone,_SpawnDirection,_SpawnAngle,_SpawnPosObj,_Paradrop,_GroupSizeFinal,_LoiterRadius,_SpawnModule,_Vcom,true] call HBQSS_fnc_CreateWaypoints;
} else {
	if (_LastSpawn) then {
		_LastWaypoint = [_Crewgroup, _RandomMoveposition, _patrol, _TaskRadius,_SpawnType,_debug,_HotZone,_SpawnDirection,_SpawnAngle,_SpawnPosObj,_Paradrop,_GroupSizeFinal,_LoiterRadius,_SpawnModule,_Vcom,true] call HBQSS_fnc_CreateWaypoints;
	} else {
	_LastWaypoint = [_Crewgroup, _RandomMoveposition, _patrol, _TaskRadius,_SpawnType,_debug,_HotZone,_SpawnDirection,_SpawnAngle,_SpawnPosObj,_Paradrop,_GroupSizeFinal,_LoiterRadius,_SpawnModule,_Vcom,false] call HBQSS_fnc_CreateWaypoints; 
	
	};
};

///////////////////////////////////         TARGETPOSITION          ///////////////////////////////////


private _TargetReachThreshold = 10;
if (_SpawnType == "TRANSPORT" or _SpawnType == "VEHICLES" or _SpawnType == "CARGOTRANSPORT") then {_TargetReachThreshold = 40};
if (_SpawnType == "NAVALTRANSPORT") then {_TargetReachThreshold = 50};
if (_SpawnType == "AIRTRANSPORT" or _SpawnType == "AIRCARGOTRANSPORT" or _SpawnType == "AIRVEHICLES") then {
	_TargetReachThreshold = 130; 
	if (_LoiterRadius > _TargetReachThreshold) then {_TargetReachThreshold = _LoiterRadius *1.1};
};


[_group,_Crewgroup,_LastWaypoint,_SpawnType,_TargetReachThreshold,_deleteTime,_DespawnSecurityRadius,_debug,_ReturntoBase,
_TaskRadius,_EngagmentKnowledge,_LambsTask,_TaskCancelDelay,_DeleteAtTargetposition,_SpawnModule,_SpawnPosition,_TakeCover,
_FinalEngageTactic,_StealthEngagement,_debug,_Lambs,_Vcom,_DCO_SFSM,_CheckWatchDirection,_Guard,_TCL,_Paradrop,
_ParachuteOpenAltitude,_StartAirOnGround,_patrol,_FastDisembark,_SpawnedCargoItem,_CargoItemData,_CustomVehicleLoadout,_ChecksDelay,
_RushTargetPosition,_StaticResetDelay,_SecondaryTargetPosObj,_TaskResetTriggerObj,_LoiterRadius] spawn HBQSS_fnc_TargetPositionReached;


_SpawnModule setVariable ["HBQ_IsSpawning",false];