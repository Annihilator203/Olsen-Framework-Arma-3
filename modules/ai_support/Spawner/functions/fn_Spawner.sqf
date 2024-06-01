
params ["_SpawnModule","_AllSyncedInfantryData","_AllSyncedVehicleData","_AllSyncedAirVehicleData",
"_AllSyncedShipVehicleData","_AllSyncedTurretsCrewData","_AllSyncedItemsData","_Side","_SyncedSpawnPositions","_SyncedMovePositions","_SyncedVehicles","_SyncedInfantry",
"_SpawnType","_SyncedTriggers","_InitialSpawn","_StopTriggerObj","_SyncedArtyModule","_SyncedSpotterModule","_SyncedCASmodule"];

if (!isServer && hasinterface) exitWith {true}; // Not sure if necessary
private _Startdelay = _SpawnModule getVariable ["Startdelay",0];
sleep random 3; // to improve performance when a lot of modules get triggered at once.
if (_InitialSpawn) then {sleep _Startdelay;};

/////////////////////////////    VARIABLES   /////////////////////////////

// Define Variables
private _SpawnDirection = getDir _SpawnModule;
private _SpawnPosition = [0,0,0];
private _SpawnPositionObj = objNull;
private _NewMinSpawnAmount = 0;
private _NewMaxSpawnAmount = 0;
private _WaveCount = 0;
private _RandomGroupData =[];
private _RandomVehicleData = [];
private _RandomCargoData = [];
private _SyncedSpawnPositionsCount = count _SyncedSpawnPositions;
private _GroupsCount = _SyncedSpawnPositionsCount;

/////////////////////////////    GET PARAMETERS FROM SPAWNMODULE   /////////////////////////////
private _Debug = _SpawnModule getVariable ["Debug",false];
if !(HBQSS_DebugEnabled) then {_Debug = false};

private _EnableBalancing = _SpawnModule getVariable ["EnableBalancing",false];
private _SpawnDelay = _SpawnModule getVariable ["SpawnDelay",1];
private _TakeCover = _SpawnModule getVariable ["SupportbyFire",false];
private _TaskCancelDelay = _SpawnModule getVariable ["LambsResetDelay",0];
private _MinEnemiesInZone = _SpawnModule getVariable ["MinOtherSideInZone",0];
private _MaxFriendliesInZone = _SpawnModule getVariable ["MaxSameSideInZone",0];
if(_MaxFriendliesInZone <= 0 ) then {_MaxFriendliesInZone = 999};
private _ForcesBalancing = _SpawnModule getVariable ["ForcesBalancing",0];
private _MaxUnconscious = _SpawnModule getVariable ["MaxUnconscious",-1];
if (_MaxUnconscious <= 0) then {_MaxUnconscious = 999};
private _HotZone = _SpawnModule getVariable ["HotZone",600];
private _PlayerSecurityRadius = _SpawnModule getVariable ["PlayerSecurityRadius",-1];
if (_PlayerSecurityRadius == -1) then {
	_PlayerSecurityRadius = HBQSS_SpawnSecurityRadius;
};

//private _MaxSpawnRadius = _SpawnModule getVariable ["MaxSpawnRadius",1000];

private _MaxSpawnRadiusArray = [];
private _MinRadiusAmount = 1000;
private _MaxRadiusAmount = 1000;
 _MaxSpawnRadiusArray = (_SpawnModule getVariable ["SpawnRadius","800,1000"]) splitString ",";
	if (count _MaxSpawnRadiusArray == 1) then {
		 _MinRadiusAmount = (parseNumber (_MaxSpawnRadiusArray select 0));
		 _MaxRadiusAmount = (parseNumber (_MaxSpawnRadiusArray select 0));
	} else {
		_MinRadiusAmount = (parseNumber (_MaxSpawnRadiusArray select 0));
		_MaxRadiusAmount = (parseNumber (_MaxSpawnRadiusArray select 1));
	};







private _SpawnAngle = _SpawnModule getVariable ["SpawnAngle",90];
private _PatrolRaw = _SpawnModule getVariable ["PatrolSelect",1];
_Patrol = "NONE";
if (_PatrolRaw == 1) then {_Patrol = "NONE"};
if (_PatrolRaw == 2) then {_Patrol = "SIMPLE PATROL"};
if (_PatrolRaw == 3) then {_Patrol = "RANDOM PATROL"};

private _WaveDelayMin = 0;
private _WaveDelayMid = 0;
private _WaveDelayMax = 0;
private _WaveDelayArray = [];
_WaveDelayArray = (_SpawnModule getVariable ["WaveDelay","300"]) splitString ",";
if (count _WaveDelayArray==1) then {
	 _WaveDelayMin = parseNumber (_WaveDelayArray select 0);
	 _WaveDelayMid = parseNumber (_WaveDelayArray select 0);
	 _WaveDelayMax = parseNumber (_WaveDelayArray select 0);
} else {
	 _WaveDelayMin = parseNumber (_WaveDelayArray select 0);
	 _WaveDelayMid = parseNumber (_WaveDelayArray select 1);
	 _WaveDelayMax = parseNumber (_WaveDelayArray select 2);
};





private _GroupSizeArray = [];
private _MinSpawnAmount = 0;
private _MaxSpawnAmount = 0;
if ((_SpawnModule getVariable ["GroupSize","-1"])!= "-1") then {

	_GroupSizeArray = (_SpawnModule getVariable ["GroupSize","3,5"]) splitString ",";
	if (count _GroupSizeArray == 1) then {
		 _MinSpawnAmount = (parseNumber (_GroupSizeArray select 0));
		 _MaxSpawnAmount = (parseNumber (_GroupSizeArray select 0));
	} else {
		_MinSpawnAmount = (parseNumber (_GroupSizeArray select 0));
		_MaxSpawnAmount = (parseNumber (_GroupSizeArray select 1));
	};
} else {
	_MinSpawnAmount = -1;
	_MaxSpawnAmount = -1;
};

private _GroupsPerWaveArray = [];
private _MinGroupAmount = 5;
private _MaxGroupAmount = 5;
private _GroupsPerWaveString = "";
if (typeName (_SpawnModule getVariable ["GroupsPerWave","5"])== "SCALAR") then {
	_GroupsPerWaveString = str (_SpawnModule getVariable ["GroupsPerWave",5])
} else {
_GroupsPerWaveString =_SpawnModule getVariable ["GroupsPerWave","5"];
};

_GroupsPerWaveArray = (_GroupsPerWaveString) splitString ",";
if (count _GroupsPerWaveArray == 1) then {
	 _MinGroupAmount = (parseNumber (_GroupsPerWaveArray select 0));
	 _MaxGroupAmount = (parseNumber (_GroupsPerWaveArray select 0));
} else {
	_MinGroupAmount = (parseNumber (_GroupsPerWaveArray select 0));
	_MaxGroupAmount = (parseNumber (_GroupsPerWaveArray select 1));
};


private _LambsTaskRaw = _SpawnModule getVariable ["LambsTask",1];
private _LambsTask = "NONE";
if (_LambsTaskRaw == 1) then {_LambsTask = "NONE"};
if (_LambsTaskRaw == 2) then {_LambsTask = "GARRISON"};
if (_LambsTaskRaw == 3) then {_LambsTask = "CQB"};
if (_LambsTaskRaw == 4) then {_LambsTask = "RUSH"};
if (_LambsTaskRaw == 5) then {_LambsTask = "HUNT"};
if (_LambsTaskRaw == 6) then {_LambsTask = "PATROL"};
if (_LambsTaskRaw == 7) then {_LambsTask = "CAMP"};
if (_LambsTaskRaw == 8) then {_LambsTask = "ASSAULT"};
if (_LambsTaskRaw == 9) then {_LambsTask = "CREEP"};


private _HideChance = _SpawnModule getVariable ["HideChance",1];
private _RebelChance = _SpawnModule getVariable ["RebelChance",0];
private _RebelWeapon = _SpawnModule getVariable ["RebelWeapon","arifle_AKM_F"];
private _RebelMagazine = _SpawnModule getVariable ["RebelMagazine", "30Rnd_762x39_AK12_Mag_F"];
private _VehicleSpeed = _SpawnModule getVariable ["VehicleSpeed",0];
private _Vcom = _SpawnModule getVariable ["Vcom",true];
private _SecondaryTargetPos = _SpawnModule getVariable ["SecondaryTargetPos",""];
private _SecondaryTargetPosObj = missionNamespace getVariable [_SecondaryTargetPos , objNull];
private _TaskResetTrigger = _SpawnModule getVariable ["TaskResetTrigger",""];
private _TaskResetTriggerObj = missionNamespace getVariable [_TaskResetTrigger , objNull];
private _EnableBalancing = _SpawnModule getVariable ["EnableBalancing",false];
private _SpawnCenter = _SpawnModule getVariable ["SpawnCenter",""];
private _SpawnCenterObj = missionNamespace getVariable [_SpawnCenter, objNull];


private _MaxSpawnDuration = _SpawnModule getVariable ["MaxSpawnDuration",0];
private _StayInAreasString = [_SpawnModule getVariable ["StayInAreas",""]," ",""]call HBQSS_fnc_stringReplace;
private _StayInAreas = _StayInAreasString splitString ",";
private _Lambs = _SpawnModule getVariable ["Lambs",true];
private _DCO_SFSM = _SpawnModule getVariable ["DCO_SFSM",false];
private _Reinforcments= _SpawnModule getVariable ["Reinforcments",false];
private _RushTargetPosition = _SpawnModule getVariable ["IgnoreEnemies",false];
private _DeleteAtTargetposition = _SpawnModule getVariable ["DeleteOnMoveposition",false];
private _VehicleLocked = _SpawnModule getVariable ["VehicleLocked",false];
private _AliveVirtual = _SpawnModule getVariable ["AliveVirtual",false];
private _IgnoreHCTransfer = _SpawnModule getVariable ["aceHcBlacklist",false];
private _DynamicSimulation = _SpawnModule getVariable ["DynamicSimulation",false];
private _ReturntoBase = _SpawnModule getVariable ["ReturntoBase",false];
private _deleteTime = _SpawnModule getVariable ["deleteTime",-1];
if (_deleteTime == -1) then {_deleteTime = HBQSS_LifeTime;};

private _StaticAI = _SpawnModule getVariable ["StaticAI",false];
private _StaticResetDelay = _SpawnModule getVariable ["StaticResetDelay",0];
private _TaskRadius = _SpawnModule getVariable ["LambsTaskRadius",800];
private _EngagmentKnowledge = _SpawnModule getVariable ["EngagmentKnowledge",0];
private _ExitStatic = _SpawnModule getVariable ["ExitStatic",false];
private _ExitStaticShotsNear = _SpawnModule getVariable ["ResetStaticShotsNear",0];
//if (_ExitStaticShotsNear == false) then {_ExitStaticShotsNear = 0};// For Compatibility
//if (_ExitStaticShotsNear == true) then {_ExitStaticShotsNear = 100};// For Compatibility
private _EngageTacticRaw = _SpawnModule getVariable ["EngageTactic",1];
private _EngageTactic = "DIRECT";
if (_EngageTacticRaw == 1) then {_EngageTactic = "NONE"};
if (_EngageTacticRaw == 2) then {_EngageTactic = "DIRECT"};
if (_EngageTacticRaw == 3) then {_EngageTactic = "FOREST"};
if (_EngageTacticRaw == 4) then {_EngageTactic = "LOWGROUND"};
if (_EngageTacticRaw == 5) then {_EngageTactic = "HIGHGROUND"};
if (_EngageTacticRaw == 6) then {_EngageTactic = "URBAN"};
if (_EngageTacticRaw == 7) then {_EngageTactic = "RANDOM"};
private _WavesEnabled = _SpawnModule getVariable ["WavesEnabled",false];
private _StealthEngagement = _SpawnModule getVariable ["StealthEngagement",false];
private _AllowFleeing = _SpawnModule getVariable ["AllowFleeing",0.5];
private _HoldFireAttackTime = _SpawnModule getVariable ["HoldBackAttackTime",0];

private _VehicleCrewed = _SpawnModule getVariable ["VehicleCrewed",true];
private _HoldFireEnemyDistance = _SpawnModule getVariable ["HoldBackEnemyDistance",0];
private _CamouflageCoef = _SpawnModule getVariable ["CamouflageCoef",1];
private _UseOptimizedSpawnMethod = _SpawnModule getVariable ["UseOptimizedSpawnMethod",true];
if !(HBQSS_OptimizedSpawnMethod) then {_UseOptimizedSpawnMethod = false;};
private _LambsRadio = _SpawnModule getVariable ["LambsRadio",false];
private _ShutUp = _SpawnModule getVariable ["ShutUp",false];
private _SuppressionThreshold = _SpawnModule getVariable ["SuppressionThreshold",0.5];
private _CheckWatchDirection = _SpawnModule getVariable ["CheckWatchDirection",true];
private _TCL = _SpawnModule getVariable ["TCL",true];
private _Guard = _SpawnModule getVariable ["Guard",false];
private _DCOVehicleFSM = _SpawnModule getVariable ["DCOVehicleFSM",true];
private _MaxGlobalUnits = _SpawnModule getVariable ["MaxGlobalUnits",-1];
if (_MaxGlobalUnits == -1) then {_MaxGlobalUnits = HBQSS_MaxTotalAICount;};
private _TriggerRadius = _SpawnModule getVariable ["TriggerRadius",-1];
private _FlyHight = _SpawnModule getVariable ["FlyHight",300];
private _Paradrop = _SpawnModule getVariable ["Paradrop",false];
private _ParachuteOpenAltitude = _SpawnModule getVariable ["ParachuteOpenAltitude",250];
private _StartAirOnGround = _SpawnModule getVariable ["StartAirOnGround",false];
private _FastDisembark = _SpawnModule getVariable ["FastDisembark",true];
private _CustomVehicleLoadout = _SpawnModule getVariable ["CustomVehicleLoadout",true];
private _VehicleFuelConsumeRate = _SpawnModule getVariable ["VehicleFuelConsumeRate",-1];
private _SpawnProbability = _SpawnModule getVariable ["SpawnProbability",1];
private _Raycasting = _SpawnModule getVariable ["Raycasting",true];
private _SetFormationPosition = _SpawnModule getVariable ["SetFormationPosition",true];
private _LoiterRadius = _SpawnModule getVariable ["LoiterRadius",0];
private _EngageWhenEnemyNear = _SpawnModule getVariable ["EngageWhenNearRadius",0];
private _DespawnSecurityRadius = _SpawnModule getVariable ["DespawnSecurityRadius",-1];
if (_DespawnSecurityRadius == -1) then {_DespawnSecurityRadius = HBQSS_DeSpawnSecurityRadius;};
private _MinServerFPS = _SpawnModule getVariable ["MinServerFPS",-1];
if (_MinServerFPS == -1 ) then {_MinServerFPS = HBQSS_FPSlimit;};
private _ChecksDelay = _SpawnModule getVariable ["ChecksDelay",5];
if(_ChecksDelay == -1) then {_ChecksDelay = HBQSS_ChecksDelay;};
private _RetreatGroupsize = _SpawnModule getVariable ["RetreatGroupsize",2];
if (_RetreatGroupsize == -1) then {_RetreatGroupsize = HBQSS_RetreatGroupsize;};
private _JoinNearGroups = _SpawnModule getVariable ["JoinNearGroups",true];
private _LeaderDistance = _SpawnModule getVariable ["LeaderDistance",-1];
if (_LeaderDistance == -1) then {_LeaderDistance = HBQSS_LeaderDistance;};
private _ACE_unconscious = _SpawnModule getVariable ["ACE_unconscious",false];
private _SafeSpawnPositionRadius = _SpawnModule getVariable ["SafeSpawnPositionRadius",0];
private _AI_FeatureActivationDelay = _SpawnModule getVariable ["AI_FeatureActivationDelay",-1];
if(_AI_FeatureActivationDelay == -1) then {_AI_FeatureActivationDelay = HBQSS_AIFeatureActivationDelay;};
private _CustomLoadout = _SpawnModule getVariable ["CustomLoadout",false];
private _MinRepeatDelay = _SpawnModule getVariable ["MinRepeatDelay",0];
private _ConvoySeparation = _SpawnModule getVariable ["ConvoySeparation",0];
private _SingleGroup = _SpawnModule getVariable ["SpawnOneGroup",false];



private _MasterGroup = grpNull;
if (_SingleGroup && _ConvoySeparation == 0 && _SpawnType != "VEHICLES" &&  _SpawnType != "AIRVEHICLES"  &&  _SpawnType != "NAVAL") then {
_MasterGroup = createGroup [_Side,true];
[_MasterGroup]call HBQSS_fnc_deleteGroupWhenEmpty;
};
private _MasterCrewGroup = grpNull;
if ((_SingleGroup or _ConvoySeparation > 0) &&  _SpawnType != "INFANTRY") then {
_MasterCrewGroup = createGroup [_Side,true];
[_MasterCrewGroup]call HBQSS_fnc_deleteGroupWhenEmpty;
};


////////////////// INITIAL TESTSPAWN FOR PERFORMANCE IMPROVEMENT HERE ??????? //////////////////////////////



/// function to keep checking SpawnEnable
[_SpawnModule,_StopTriggerObj,_MaxSpawnDuration,_debug,_ChecksDelay] spawn HBQSS_fnc_CheckSpawnStop;

/// DEBUG
if (_debug) then {
	format ["%1: Started spawning", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];"FD_Start_F" remoteExec ["playSound", 0];
	if (_ConvoySeparation > 0 ) then {
		format ["%1: Convoymode Active", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
	};

};
diag_log format ["INFO HBQ: %1: Started spawning", _SpawnModule];


// Wait for SpawnEnable to be true
//waitUntil {sleep 0.6; if ((isNil "_SpawnModule") or (isNull _SpawnModule)) exitWith {true};_SpawnModule getVariable "HBQ_SpawnsTerminated" == false};


if (_MaxGlobalUnits > 0) then {[_SpawnModule,_MaxGlobalUnits,_debug,_ChecksDelay]spawn HBQSS_fnc_GlobalUnitCountCheck};


/////////////////////////////        Spawn Groups        /////////////////////////////

while { _SpawnModule getVariable "HBQ_SpawnsTerminated" == false } do { /// as long as not terminated
	if (isNil "_SpawnModule") exitWith {true};
	if (isNull _SpawnModule) exitWith {true};
	_WaveCount = _WaveCount +1;
	_SpawnModule setVariable ["HBQ_GroupsSpawned", 0,true];// PUBLIC ??
	
	// if Waves is enabled set Groupcount to the Module Parameter (Groups per Wave)
	if (_WavesEnabled or _SyncedSpawnPositionsCount == 0) then {
	_GroupsCount = round (_MinGroupAmount + random ((_MaxGroupAmount-_MinGroupAmount)+0.1));
	};
	
	/// Spawn each Group 
	
	private _FirstSpawn = true;
	private _LastSpawn = false;
	
	for "_k" from 1 to _GroupsCount do {
		if (_k == _GroupsCount) then {_LastSpawn = true};
		if (isNil "_SpawnModule") exitWith {true};
		if (_SpawnModule getVariable "HBQ_SpawnsTerminated" == true) exitWith {true};
		
		if (count _SyncedInfantry > 0) then {
			_RandomGroupData = selectRandom _AllSyncedInfantryData;
			if (_MinSpawnAmount == -1) then {
				_NewMinSpawnAmount = count (_RandomGroupData select 0 select 0);
				_NewMaxSpawnAmount = count (_RandomGroupData select 0 select 0);
			} else {
			_NewMinSpawnAmount = _MinSpawnAmount;
			_NewMaxSpawnAmount = _MaxSpawnAmount;
			};
		};

		// Set Random Vehicle Data
		switch _SpawnType do
		{
			case "TRANSPORT": {if (_ConvoySeparation == 0 or (_k > count _AllSyncedVehicleData)) then {_RandomVehicleData = selectRandom _AllSyncedVehicleData} else { _RandomVehicleData = _AllSyncedVehicleData select (_k-1)}};
			case "VEHICLES": {if (_ConvoySeparation == 0 or (_k > count _AllSyncedVehicleData)) then {_RandomVehicleData = selectRandom _AllSyncedVehicleData} else { _RandomVehicleData = _AllSyncedVehicleData select (_k-1)}};
			case "AIRTRANSPORT": {if (_ConvoySeparation == 0 or (_k > count _AllSyncedAirVehicleData)) then {_RandomVehicleData = selectRandom _AllSyncedAirVehicleData} else { _RandomVehicleData = _AllSyncedAirVehicleData select (_k-1)}};
			case "AIRVEHICLES": {if (_ConvoySeparation == 0 or (_k > count _AllSyncedAirVehicleData)) then {_RandomVehicleData = selectRandom _AllSyncedAirVehicleData} else { _RandomVehicleData = _AllSyncedAirVehicleData select (_k-1)}};
			case "NAVALTRANSPORT": {if (_ConvoySeparation == 0 or (_k > count _AllSyncedShipVehicleData)) then {_RandomVehicleData = selectRandom _AllSyncedShipVehicleData} else { _RandomVehicleData = _AllSyncedShipVehicleData select (_k-1)}};
			case "NAVAL": {if (_ConvoySeparation == 0 or (_k > count _AllSyncedShipVehicleData)) then {_RandomVehicleData = selectRandom _AllSyncedShipVehicleData} else { _RandomVehicleData = _AllSyncedShipVehicleData select (_k-1)}};
			case "TURRETS": {_RandomVehicleData = selectRandom _AllSyncedTurretsCrewData;};
			case "CARGOTRANSPORT": {_RandomVehicleData = selectRandom _AllSyncedVehicleData;_RandomCargoData = selectRandom _AllSyncedItemsData;};
			case "AIRCARGOTRANSPORT": {_RandomVehicleData = selectRandom _AllSyncedAirVehicleData;_RandomCargoData = selectRandom _AllSyncedItemsData;};
		};
		
		
		//if ((count _RandomVehicleData) == 0 ) then {

		/// MovePosition when no MovePositions Synced.
		if (count _SyncedMovePositions == 0 && (isNull _SpawnCenterObj)) then { //   NO Movepositions synced
			_SyncedMovePositions=[_SpawnModule];
		}; // Module is MovePosition
		
		
		if (count _SyncedMovePositions == 0 && !(isNull _SpawnCenterObj)) then { //   NO Movepositions synced
			_SyncedMovePositions=[_SpawnCenterObj];
		}; // Object is MovePosition
		
	
		if (_WavesEnabled) then { // Waves Enabled
			if (count _SyncedSpawnPositions != 0) then { // SpawnPositions are synced with module
				_SpawnPositionObj = selectRandom _SyncedSpawnPositions; // Choose Random synced Spawnposition
		
			} else {  // No SpawnPositions are synced
				_SpawnPositionObj = _SpawnModule;
			};

		} else { // Waves is Disabled
			
			if (count _SyncedSpawnPositions != 0) then { // SpawnPositions are synced with module
				_SpawnPositionObj = _SyncedSpawnPositions select (_k -1); // Choose Next synced Spawnposition
			} else { //   NO SpawnPositions synced
				_SpawnPositionObj = _SpawnModule;
			};
		};
		// Set Direction 
		_SpawnDirection = getDir _SpawnPositionObj;
		
		///// Set Spawnposition
		_SpawnPosition = getPosATL _SpawnPositionObj;
		
		// SpawnType is TRANSPORT and Spawnpositions synced
		if ((_SpawnType == "TRANSPORT" or _SpawnType == "NAVALTRANSPORT" or _SpawnType == "AIRTRANSPORT") and (count _SyncedSpawnPositions) == 0 and _SafeSpawnPositionRadius != 0) then {
			private _TempSafePosition = [_SpawnPositionObj, 1, _SafeSpawnPositionRadius, 8, 0, 40, 0] call BIS_fnc_findSafePos; // Find a Safe position on Land (Third Parameter in Function is Searchdistance)
			_SpawnPosition = [_TempSafePosition select 0,_TempSafePosition select 1, 0]; 
		};

		// Automatic Spawnposition if No Spawnpositions Synced
		if ((count _SyncedSpawnPositions) == 0 && (isNull _SpawnCenterObj)) then {  // No SpawnPositions Synced
			_SpawnPosition = [_PlayerSecurityRadius,_debug,_SpawnModule,_MinRadiusAmount,_MaxRadiusAmount,_SpawnAngle,_CheckWatchDirection,_ChecksDelay,_SafeSpawnPositionRadius,_SpawnModule] call HBQSS_fnc_FindAutomaticSpawnPosition;

			if (_SpawnModule getVariable ["SpawnHidden",false]) then {_SpawnDirection = random 360} else {_SpawnDirection = _SpawnPosition getDir _SpawnModule;};
			
		
		};
		
		// Automatic Spawnposition with Object as Center
		if ((count _SyncedSpawnPositions) == 0 && !(isNull _SpawnCenterObj) ) then {  // No SpawnPositions Synced
		_SpawnPosition = [_PlayerSecurityRadius,_debug,_SpawnCenterObj,_MinRadiusAmount,_MaxRadiusAmount,_SpawnAngle,_CheckWatchDirection,_ChecksDelay,_SafeSpawnPositionRadius,_SpawnModule]call HBQSS_fnc_FindAutomaticSpawnPosition;

		if (_SpawnModule getVariable ["SpawnHidden",false]) then {_SpawnDirection = random 360} else {_SpawnDirection = _SpawnPosition getDir _SpawnCenterObj;};
		
		};
		
		

///////////////////////////////////////////////////////        SPAWN UNITS            /////////////////////////////////////////
		
		// Wait for Balancing Checks
		if (_EnableBalancing) then {
			if ([_SpawnModule,_HotZone,_Side,_MaxUnconscious,_MinEnemiesInZone,_MaxFriendliesInZone,_ForcesBalancing,_debug]call HBQSS_fnc_BalancingChecks) exitWith {true};
			waitUntil {
				if (isNil "_SpawnModule") exitWith {true};
				if (_HotZone >= 0 && _HotZone < 100) then {sleep (_ChecksDelay/4);}; 
				if (_HotZone >= 100 && _HotZone < 500) then {sleep _ChecksDelay/2;}; 
				if (_HotZone >= 500 && _HotZone < 1000) then {sleep _ChecksDelay;}; 
				if (_HotZone >= 1000 && _HotZone < 3000) then {sleep (_ChecksDelay*1.5);};
				if (_HotZone >= 3000) then {sleep (_ChecksDelay*2)}; 
				[_SpawnModule,_HotZone,_Side,_MaxUnconscious,_MinEnemiesInZone,_MaxFriendliesInZone,_ForcesBalancing,_debug]call HBQSS_fnc_BalancingChecks
			};
		};
		
		/// FPS Check
		
		if (_MinServerFPS != -1) then {
			waitUntil {
				sleep 0.2;
				if (isNil "_SpawnModule") exitWith {true};
				if (isNull _SpawnModule) exitWith {true};
				_SpawnModule getVariable "HBQ_FpsCheck" == true
			};
		};
		
		// Check Max units
		waitUntil {
			sleep 0.2;
			if (isNil "_SpawnModule") exitWith {true};
			if (isNull _SpawnModule) exitWith {true};
			_SpawnModule getVariable "HBQ_MaxUnits" == false
		};
		if (isNil "_SpawnModule") exitWith {true};
		if (isNull _SpawnModule) exitWith {true};
		if (_SpawnModule GetVariable "HBQ_SpawnsTerminated" == true) exitWith {true};

		
		[_PlayerSecurityRadius,_SpawnPosition,_Side,_RebelWeapon,_RebelMagazine,_RushTargetPosition,_NewMinSpawnAmount,_NewMaxSpawnAmount,
		_Vcom,_Lambs,_DCO_SFSM,_RandomGroupData,_RandomVehicleData,_SpawnModule,_debug,_LambsTask,_SyncedMovePositions,_SpawnType,_DeleteAtTargetposition,
		_ReturntoBase,_TaskCancelDelay,_Patrol,_DynamicSimulation,_Reinforcments,_IgnoreHCTransfer,_VehicleSpeed,_VehicleLocked,_SpawnDirection,_HideChance,
		_RebelChance,_HotZone,_MaxFriendliesInZone,_MinEnemiesInZone,_ForcesBalancing,_MaxUnconscious,_deleteTime,_TakeCover,_SpawnAngle,_EnableBalancing,
		_AI_FeatureActivationDelay,_SpawnPositionObj,_StaticAI,_StaticResetDelay,_TaskRadius,_EngagmentKnowledge,_ExitStatic,_EngageTactic,
		_StealthEngagement,_AllowFleeing,_HoldFireAttackTime,_VehicleCrewed,_HoldFireEnemyDistance,_CamouflageCoef,_UseOptimizedSpawnMethod,
		_LambsRadio,_ShutUp,_SuppressionThreshold,_CheckWatchDirection,_TCL,_Guard,_DCOVehicleFSM,_FlyHight,_Paradrop,_ParachuteOpenAltitude,_StartAirOnGround,
		_FastDisembark,_CustomVehicleLoadout,_RandomCargoData,_VehicleFuelConsumeRate,_TriggerRadius,_SpawnProbability,_Raycasting,_SetFormationPosition,
		_LoiterRadius,_DespawnSecurityRadius,_ChecksDelay,_RetreatGroupsize,_JoinNearGroups,_LeaderDistance,_CustomLoadout,_ACE_unconscious,
		_SecondaryTargetPosObj,_TaskResetTriggerObj,_ExitStaticShotsNear,_EngageWhenEnemyNear,_StayInAreas,_SafeSpawnPositionRadius,_SyncedArtyModule,
		_SyncedSpotterModule,_SyncedCASmodule,_MasterGroup,_MasterCrewGroup,_LastSpawn,_FirstSpawn] spawn HBQSS_fnc_SpawnGroup;
		
		_FirstSpawn = false;
		/// Wait for SpawnDelay between each Groupspawn (with some Randomisation)
		sleep ((random [_SpawnDelay*0.8, _SpawnDelay*0.9, _SpawnDelay])+0.1); // added a little delay as the delay should not be 0
	
	}; ////  END OF FORLOOP - ALL Groups Spawned.
	
	if (_ConvoySeparation > 0) then {
	sleep 60;
	};
/* 	waitUntil {
	sleep 1;
	systemchat "CHECK";
	_LastSpawn
	}; */
	
	
	// Profile all Units on Map for Alive Virtualization
	if (_AliveVirtual) then {
		[] call ALiVE_fnc_createProfilesFromUnitsRuntime;
	};
	
	// DEBUG
	if (_debug) then {
		if (_WavesEnabled) then {
			"FD_Finish_F" remoteExec ["playSound", 0];
			format ["%1: Wave %2 Finished ", _SpawnModule,_WaveCount] remoteExec ["systemchat", TO_ALL_PLAYERS];
		} else {
			format ["%1: Finished - %2 Groups spawned or delayed", _SpawnModule,_GroupsCount] remoteExec ["systemchat", TO_ALL_PLAYERS];
			};
	};

	if (_WavesEnabled) then {
		diag_log format ["INFO HBQ: %1: Wave %2 Finished ", _SpawnModule,_WaveCount]
	} else {
		diag_log format ["INFO HBQ: %1: Finished - %2 Groups spawned or delayed", _SpawnModule,_GroupsCount]
	};
	
	/// EXIT LOOP IF WAVES NOT ENABLED
	if (!_WavesEnabled) exitWith {};
	
	// SpawnDelay
	if (_WavesEnabled) then {
	private _RandomSpawnDelay = [_WaveDelayMin,_WaveDelayMid,_WaveDelayMax]call HBQSS_fnc_RandomSpawnDelay;
	sleep _RandomSpawnDelay;
	};
	
}; // End while loop  when SpawnsEnabled is false


if (_TriggerRadius > 0) then {
	_SyncedSpawnPositionsCount = count _SyncedSpawnPositions;
	waitUntil {
	sleep _ChecksDelay;	
	_PlayerChecks = _SyncedSpawnPositions select {_x getVariable ["HBQ_PlayerNearCheck",false]};
	(count _PlayerChecks) == 0
	};

};


if (_MinRepeatDelay <= 0) then {_SpawnModule setVariable ["HBQ_SpawnsTerminated", true,true];};// PUBLIC ??




// END OF ALL FUNCTIONS / Delete big Variables
_AllSyncedInfantryData = nil;
_AllSyncedItemsData = nil;
_AllSyncedVehicleData = nil;
_AllSyncedAirVehicleData = nil;
_AllSyncedShipVehicleData = nil;
_AllSyncedTurretsCrewData = nil;