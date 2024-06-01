if (!isServer) exitWith {}; 

_this spawn { 
params["_SpawnModule"];
private _SyncedTriggers = [];
private _AllSyncedInfantryData = [];
private _AllSyncedVehicleData = [];
private _AllSyncedAirVehicleData = [];
private _AllSyncedShipVehicleData = [];
private _AllSyncedTurretsCrewData = [];
private _AllSyncedItemsData = [];
private _SyncedVehicles = [];
private _SyncedAirVehicles = [];
private _SyncedTurrets = [];
private _SyncedShips = [];
private _SyncedItems = [];
private _SyncedInfantry = [];
private _SyncedObjs = synchronizedObjects _SpawnModule;
private _SyncedInfantryGroups = [];
private _SyncedSpawnPositions = [];
private _SyncedMovePositions = [];
private _StopTrigger = _SpawnModule getVariable ["StopTrigger",""];
private _StopTriggerObj = missionNamespace getVariable [_StopTrigger , objNull];
private _SpawnType = "";
private _NoCrewinSyncedVehicle = false;
private _CustomLoadout = _SpawnModule getVariable ["CustomLoadout",false];
private _SyncedArtyModule = objNull;
private _SyncedArtyModules = [];
private _SyncedSpotterModule = objNull;
private _SyncedSpotterModules = [];
private _SyncedCASmodule = objNull;
private _SyncedCASmodules = [];
private	_VehicleAceSupply = -1;
private	_VehicleAceFuelSupply = -1;




// Set Module Variables
_SpawnModule setVariable ["HBQ_SpawnsTerminated", false,true];// PUBLIC ??
_SpawnModule setVariable ["HBQ_SpawnsCheck", true,true];// PUBLIC ??
_SpawnModule setVariable ["HBQ_MaxUnits", false,true];// PUBLIC ??
_SpawnModule setVariable ["HBQ_FpsCheck", true,true];// PUBLIC ??
_SpawnModule setVariable ["HBQ_SyncedMovePositions", [],true];// PUBLIC ??
_SpawnModule setVariable ["HBQ_GroupsSpawned", 0,true];// PUBLIC ??

// Define all Synced Objects
_SyncedTriggers =_SyncedObjs select {_x isKindOf "EmptyDetector" and _x != _StopTriggerObj;};
_SyncedSpawnPositions =_SyncedObjs select {typeOf _x == "HBQ_SpawnPosition";};
_SyncedMovePositions =_SyncedObjs select {typeOf _x == "HBQ_MovePosition";};
_SyncedVehicles = _SyncedObjs select {_x isKindOf "Car" or _x isKindOf "Tank" or _x isKindOf "Truck";};
_SyncedAirVehicles = _SyncedObjs select {_x isKindOf "Plane" or _x isKindOf "Helicopter";};
_SyncedShips = _SyncedObjs select {_x isKindOf "Ship";};
_SyncedTurrets = _SyncedObjs select {_x isKindOf "StaticWeapon"};
_SyncedInfantry = _SyncedObjs select {_x isKindOf "Man" && isNull objectParent _x;};

_SyncedArtyModules = _SyncedObjs select {typeOf _x == "HBQ_Artillery"};
if (count _SyncedArtyModules > 0) then {_SyncedArtyModule = _SyncedArtyModules select 0};

_SyncedSpotterModules = _SyncedObjs select {typeOf _x == "HBQ_Spotter"} ;
if (count _SyncedSpotterModules > 0) then {_SyncedSpotterModule = _SyncedSpotterModules select 0};


_SyncedCASmodules = _SyncedObjs select {typeOf _x == "HBQ_CAS"} ;
if (count _SyncedCASmodules > 0) then {_SyncedCASmodule = _SyncedCASmodules select 0};

// If Driver or Pilot is synced the Vehicle will get added to the Vehicles Variables
{
if ((objectParent _x) isKindOf "Car" or (objectParent _x) isKindOf "Tank" or (objectParent _x) isKindOf "Truck") then {_SyncedVehicles = _SyncedVehicles +[objectParent _x]};
if ((objectParent _x) isKindOf "Plane" or (objectParent _x) isKindOf "Helicopter") then {_SyncedAirVehicles = _SyncedAirVehicles +[objectParent _x]};
if ((objectParent _x) isKindOf "Ship") then {_SyncedShips = _SyncedShips +[objectParent _x]};
if ((objectParent _x) isKindOf "StaticWeapon") then {_SyncedTurrets = _SyncedTurrets +[objectParent _x]};
} forEach (_SyncedObjs select {_x isKindOf "Man"});

_SyncedItems = _SyncedObjs select {_x isKindOf "Thing";};
{_SyncedInfantryGroups = _SyncedInfantryGroups + [group _x];} forEach _SyncedInfantry;

/// Disable Simulation
{
	{
		_x hideObjectGlobal true;
		_x enableSimulation false;
	} forEach units _x;
} forEach _SyncedInfantryGroups;

{
	_x hideObjectGlobal true;
} forEach (_SyncedVehicles + _SyncedAirVehicles + _SyncedTurrets + _SyncedShips + _SyncedItems);

// Define Side
private _Side = side group((_SyncedObjs select {!(_x isKindOf "EmptyDetector" or _x isKindOf "Logic" or _x isKindOf "Thing")}) select 0);

sleep 0.5; // Wait for Group Data to load (for Callsign necessary)

///////////////////////////////////////////// STORE SYNCED OBJECTS DATA   /////////////////////////////////////////////
{
	private _unitsData = [];
	{
	private _InfLoadout = [];
	if (_CustomLoadout) then {_InfLoadout = getUnitLoadout _x};
	_unitsData = _unitsData + [[typeOf _x,_InfLoadout,skill _x, unitPos  _x,behaviour _x,isDamageAllowed _x]];
	} forEach units _x;
	private _Combatbehaviour = combatBehaviour _x;
	if (_Combatbehaviour ==  "COMBAT") then {_Combatbehaviour = "AWARE"};
	_AllSyncedInfantryData = _AllSyncedInfantryData + [[[_unitsData,formation _x ,_Combatbehaviour, combatMode _x,speedMode _x,groupId _x]]];
	 
} forEach _SyncedInfantryGroups;

{
	private _crewData = [];
	{
	private _InfLoadout = [];
	if (_CustomLoadout) then {_InfLoadout = getUnitLoadout _x};
	_crewData = _crewData + [[typeOf _x,_InfLoadout,skill _x, unitPos  _x,behaviour _x,assignedVehicleRole _x,formation (group _x)]];
	} forEach crew _x;
	if (HBQSS_ACE_Loaded) then {
		_VehicleAceSupply = [_x] call ace_rearm_fnc_getSupplyCount;
		_VehicleAceFuelSupply = [_x] call ace_refuel_fnc_getFuel;
		
	};
	
	private _Combatbehaviour = combatBehaviour group driver _x;
	if (_Combatbehaviour ==  "COMBAT") then {_Combatbehaviour = "AWARE"};
	
	_AllSyncedVehicleData = _AllSyncedVehicleData + [[[_crewData, formation group driver _x ,_Combatbehaviour, 
	combatMode group driver _x,speedMode group driver _x,(typeOf _x),getMagazineCargo  _x,getItemCargo _x,getWeaponCargo _x,
	getBackpackCargo _x,fuel _x,groupId group driver _x,isDamageAllowed _x,[_x] call HBQSS_fnc_getVehicleAmmo,damage _x,_VehicleAceSupply,
	_VehicleAceFuelSupply,_x getVariable ["ace_medical_isMedicalVehicle",false],_x getVariable ["ace_repair_canRepair",0]
	
	
	]]];
} forEach _SyncedVehicles;

{
	private _crewData = [];
	{
	private _InfLoadout = [];
	if (_CustomLoadout) then {_InfLoadout = getUnitLoadout _x};
	_crewData = _crewData + [[typeOf _x,_InfLoadout,skill _x, unitPos  _x,behaviour _x,assignedVehicleRole _x,formation (group _x)]];
	} forEach crew _x;
	
	if (HBQSS_ACE_Loaded) then {
		_VehicleAceSupply = [_x] call ace_rearm_fnc_getSupplyCount;
		_VehicleAceFuelSupply = [_x] call ace_refuel_fnc_getFuel;
		
	};
	
	private _Combatbehaviour = combatBehaviour group driver _x;
	if (_Combatbehaviour ==  "COMBAT") then {_Combatbehaviour = "AWARE"};
	

	_AllSyncedAirVehicleData = _AllSyncedAirVehicleData + [[[_crewData, formation group driver _x ,
	_Combatbehaviour, combatMode group driver _x,speedMode group driver _x,(typeOf _x),
	getMagazineCargo  _x,getItemCargo _x,getWeaponCargo _x,getBackpackCargo _x,fuel _x,
	getPylonMagazines _x,groupId group driver _x,isDamageAllowed _x,getAmmoCargo _x,damage _x,_VehicleAceSupply,
	_VehicleAceFuelSupply,_x getVariable ["ace_medical_isMedicalVehicle",false],_x getVariable ["ace_repair_canRepair",0]
	
	

	
	
	]]];
} forEach _SyncedAirVehicles;

{
	private _crewData = [];
	{
	private _InfLoadout = [];
	if (_CustomLoadout) then {_InfLoadout = getUnitLoadout _x};
	_crewData = _crewData + [[typeOf _x,_InfLoadout,skill _x, unitPos  _x,behaviour _x,assignedVehicleRole _x,formation (group _x)]];
	} forEach crew _x;
	
	if (HBQSS_ACE_Loaded) then {
		_VehicleAceSupply = [_x] call ace_rearm_fnc_getSupplyCount;
		_VehicleAceFuelSupply = [_x] call ace_refuel_fnc_getFuel;
		
	};
	private _Combatbehaviour = combatBehaviour group driver _x;
	if (_Combatbehaviour ==  "COMBAT") then {_Combatbehaviour = "AWARE"};
	
	_AllSyncedShipVehicleData = _AllSyncedShipVehicleData + [[[_crewData, formation group driver _x ,
	_Combatbehaviour, combatMode group driver _x,speedMode group driver _x,(typeOf _x),
	getMagazineCargo  _x,getItemCargo _x,getWeaponCargo _x,getBackpackCargo _x,fuel _x,
	groupId group driver _x,isDamageAllowed _x,[_x] call HBQSS_fnc_getVehicleAmmo,damage _x,_VehicleAceSupply,
	_VehicleAceFuelSupply,_x getVariable ["ace_medical_isMedicalVehicle",false],_x getVariable ["ace_repair_canRepair",0]
	
	
	
	
	]]];
} forEach _SyncedShips;

{
	private _crewData = [];
	{
	private _InfLoadout = [];
	if (_CustomLoadout) then {_InfLoadout = getUnitLoadout _x};
	_crewData = _crewData + [[typeOf _x,_InfLoadout,skill _x, unitPos  _x,behaviour _x,assignedVehicleRole _x,formation (group _x)]];
	} forEach crew _x;
	
	private _Combatbehaviour = combatBehaviour group driver _x;
	if (_Combatbehaviour ==  "COMBAT") then {_Combatbehaviour = "AWARE"};
	
	
	
	_AllSyncedTurretsCrewData= _AllSyncedTurretsCrewData + [[[_crewData, formation group gunner _x ,
	_Combatbehaviour, combatMode group driver _x,speedMode group driver _x,(typeOf _x),
	getMagazineCargo  _x,getItemCargo _x,getWeaponCargo _x,getBackpackCargo _x,fuel _x,
	groupId group driver _x,isDamageAllowed _x,[_x] call HBQSS_fnc_getVehicleAmmo,damage _x,_VehicleAceSupply,
	_VehicleAceFuelSupply,_x getVariable ["ace_medical_isMedicalVehicle",false],_x getVariable ["ace_repair_canRepair",0]
	
	]]];
} forEach _SyncedTurrets;

{
_AllSyncedItemsData= _AllSyncedItemsData + [[[(typeOf _x),[],[],[],[],[],getMagazineCargo _x,getItemCargo _x,getWeaponCargo _x,getBackpackCargo _x]]];
} forEach _SyncedItems;

////////////  DEFINE SPAWNTYPE   ///////////////////////////////////////////

if (count _SyncedVehicles > 0 and count _SyncedInfantry == 0 and count _SyncedItems == 0) then {_SpawnType = "VEHICLES";};
if (count _SyncedAirVehicles > 0 and count _SyncedInfantry == 0) then {_SpawnType = "AIRVEHICLES";};
if (count _SyncedVehicles > 0 and count _SyncedInfantry > 0 and count _SyncedItems == 0) then {_SpawnType = "TRANSPORT";};
if (count _SyncedAirVehicles > 0 and count _SyncedInfantry > 0 and count _SyncedItems == 0) then {_SpawnType = "AIRTRANSPORT";};
if (count _SyncedVehicles == 0 and count _SyncedInfantry == 0 and count _SyncedTurrets >0) then {_SpawnType = "TURRETS";};
if (count _SyncedVehicles == 0 and count _SyncedInfantry > 0 and count _SyncedAirVehicles == 0) then {_SpawnType = "INFANTRY";};
if (count _SyncedShips > 0 and count _SyncedInfantry > 0 and count _SyncedItems == 0) then {_SpawnType = "NAVALTRANSPORT";};
if (count _SyncedShips > 0 and count _SyncedInfantry == 0 and count _SyncedItems == 0) then {_SpawnType = "NAVAL";};
if (count _SyncedItems > 0 and count _SyncedVehicles > 0) then {_SpawnType = "CARGOTRANSPORT";};
if (count _SyncedItems > 0 and count _SyncedAirVehicles > 0) then {_SpawnType = "AIRCARGOTRANSPORT";};

_SpawnModule setVariable ["HBQ_SpawnType", _SpawnType,true];
sleep 2; // Sleep to let other Modules share Synced Units Data

///////////////////         DELETE SYNCED OBJECTS          ////////////////////////////
if (count _SyncedInfantry > 0) then {
	{
		[group _x]call HBQSS_fnc_deleteGroupWhenEmpty;
		{
		deleteVehicle _x;
		} forEach units group _x;
	} forEach _SyncedInfantry;	
};

if (count _SyncedVehicles > 0) then {
	{
		if (isNil {group ((crew _x)select 0)}) exitWith {_NoCrewinSyncedVehicle = true};
		[group ((crew _x)select 0)]call HBQSS_fnc_deleteGroupWhenEmpty;
		deleteVehicleCrew _x;
		deleteVehicle _x;
	} forEach _SyncedVehicles;	
};

if (count _SyncedShips > 0) then {
	{
		if (isNil {group ((crew _x)select 0)}) exitWith {_NoCrewinSyncedVehicle = true};
		[group ((crew _x)select 0)]call HBQSS_fnc_deleteGroupWhenEmpty;
		deleteVehicleCrew _x;
		deleteVehicle _x;
	} forEach _SyncedShips;	
};


if (count _SyncedAirVehicles > 0) then {
	{
		if (isNil {group ((crew _x)select 0)}) exitWith {_NoCrewinSyncedVehicle = true};
		[group ((crew _x)select 0)]call HBQSS_fnc_deleteGroupWhenEmpty;
		deleteVehicleCrew _x;
		deleteVehicle _x;
	} forEach _SyncedAirVehicles;	
};


if (count _SyncedTurrets > 0) then {
	{
		if (isNil {group ((crew _x)select 0)}) exitWith {_NoCrewinSyncedVehicle = true};
		[group ((crew _x)select 0)]call HBQSS_fnc_deleteGroupWhenEmpty;
		deleteVehicleCrew _x;
		deleteVehicle _x;
		
	} forEach _SyncedTurrets;	
};

if (count _SyncedItems > 0) then {
	{
		deleteVehicle _x;
	} forEach _SyncedItems;	
};

// CHECKS
private _EnableSpawns = _SpawnModule getVariable ["EnableSpawns",false];
if (not _EnableSpawns) exitWith {
	/// Delete Big Variables
	_AllSyncedItemsData = nil;
	_AllSyncedVehicleData = nil;
	_AllSyncedAirVehicleData = nil;
	_AllSyncedShipVehicleData = nil;
	_AllSyncedTurretsCrewData = nil;
}; 

if (count _SyncedVehicles == 0 and count _SyncedInfantry == 0  and count _SyncedTurrets == 0 and count _SyncedAirVehicles == 0  and count _SyncedShips == 0) exitWith {
	format ["ERROR: No Units Synced to %1!",_SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
	diag_log format ["ERROR: No Units Synced to %1!",_SpawnModule];
};

// Wait for XEH_preinit to load.
if (isdedicated) then {sleep 40;};

/////////////////////////    MODULE VARIABLES    /////////////////////////////////

private _WavesBudget = _SpawnModule getVariable ["WavesBudget",50];
if (_WavesBudget <= 0) then {_SpawnModule setVariable ["HBQ_WaveBudget", -100,true];} else {_SpawnModule setVariable ["HBQ_WaveBudget", _WavesBudget,true];};// PUBLIC ??
private _MinRepeatDelay = _SpawnModule getVariable ["MinRepeatDelay",0];




private _HotZone = _SpawnModule getVariable ["HotZone",600];
private _PlayerSecurityRadius = _SpawnModule getVariable ["PlayerSecurityRadius",-1];
if (_PlayerSecurityRadius == -1) then {
	_PlayerSecurityRadius = HBQSS_SpawnSecurityRadius;
};
private _MaxSpawnRadius = _SpawnModule getVariable ["MaxSpawnRadius",1000];
private _SpawnAngle = _SpawnModule getVariable ["SpawnAngle",90];




private _Debug = _SpawnModule getVariable ["Debug",false];
if !(HBQSS_DebugEnabled) then {_Debug = false};

private _AI_FeatureActivationDelay = _SpawnModule getVariable ["AI_FeatureActivationDelay",-1];
if(_AI_FeatureActivationDelay == -1) then {_AI_FeatureActivationDelay = HBQSS_AIFeatureActivationDelay;};
private _EnableBalancing = _SpawnModule getVariable ["EnableBalancing",false];
private _WavesEnabled = _SpawnModule getVariable ["WavesEnabled",false];
private _GarbageCollection = _SpawnModule getVariable ["DeleteMovePositions",true];
private _TriggerRadius = _SpawnModule getVariable ["TriggerRadius",-1];
private _MinServerFPS = _SpawnModule getVariable ["MinServerFPS",-1];
if (_MinServerFPS == -1 ) then {_MinServerFPS = HBQSS_FPSlimit;};
private _ChecksDelay = _SpawnModule getVariable ["ChecksDelay",5];
if(_ChecksDelay == -1) then {_ChecksDelay = HBQSS_ChecksDelay;};


if (_NoCrewinSyncedVehicle) exitWith {systemchat "Spawn not executed!!! Synced Vehicles need to be crewed. ";};

//// DEBUG

if (_debug) then {
	format ["%2: SpawnType is %1", _SpawnType,_SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];
	if ((_SpawnModule getVariable ["IsArtillery",false]) && _SpawnType == "INFANTRY") then {format ["%1: Caution: ACE Amunitionhandling needs to be disabled to make Mortars work.", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};
	if not (isClass(configFile >> "CfgPatches" >> "lambs_danger"))then {"LambsDanger not Loaded!" remoteExec ["systemchat", TO_ALL_PLAYERS];};
	// Draw Debug Cirles Trigger Radius
	if (_TriggerRadius > 0 and (count _SyncedSpawnPositions) > 0)then {
		{
			[getPos _x, "","ELLIPSE","mil_objective_noShadow",[_TriggerRadius,_TriggerRadius],600,"ColorBlack",0.5,0,"Border",false] spawn HBQSS_fnc_CreateDebugMarker;
		} foreach _SyncedSpawnPositions;
	};

	if (_EnableBalancing)then {
		[(getPos _SpawnModule) vectorAdd [-55,_HotZone*0.5], "Zone","ICON","EmptyIcon",[0.5,0.5],600,"ColorBlack",1,0,"DiagGrid",false] spawn HBQSS_fnc_CreateDebugMarker;
		[getPos _SpawnModule, "","ELLIPSE","mil_objective_noShadow",[_HotZone,_HotZone],600,"ColorBlack",0.5,0,"BDiagonal",false] spawn HBQSS_fnc_CreateDebugMarker;
	};
	// Lines to show Spawn Area Cone 
	if (count _SyncedSpawnPositions == 0) then {
		[getPos _SpawnModule, "","POLYLINE","mil_objective_noShadow",[_MaxSpawnRadius,_MaxSpawnRadius],600,"ColorBlack",0.5,(getDir _SpawnModule)-(_SpawnAngle/2),"SolidBorder",true] spawn HBQSS_fnc_CreateDebugMarker;
		[getPos _SpawnModule, "","POLYLINE","mil_objective_noShadow",[_MaxSpawnRadius,_MaxSpawnRadius],600,"ColorBlack",0.5,(getDir _SpawnModule)+(_SpawnAngle/2),"SolidBorder",true] spawn HBQSS_fnc_CreateDebugMarker;
	};
	
	if (_PlayerSecurityRadius > 0) then {
		{
			[getPos _SpawnModule, "","ELLIPSE","mil_objective_noShadow",[_PlayerSecurityRadius,_PlayerSecurityRadius],600,"ColorRed",1,0,"BDiagonal",false] spawn HBQSS_fnc_CreateDebugMarker;
		
		} forEach _SyncedSpawnPositions;
	};
	
};

//////////////////////// Security Checks ////////////////////////////////////////

if (isServer && hasinterface) then {

	if(_WavesEnabled && _WavesBudget == -1) then {
		
		[_SpawnModule] spawn {
			private _CautionText = format ["%1: Potentially spawns infinite Units. Be sure you know what you are doing. Proceed anyways?", _this select 0];
			sleep 5;
			[_CautionText, "CAUTION!!!", true, false] call BIS_fnc_guiMessage;
		};
	};
	if(_WavesBudget > 300) then {
		[_SpawnModule,_WavesBudget] spawn {
			private _CautionText = format ["%1 Spawns up to %2 Units. Are you sure your Server can handle this? Proceed anyways?", _this select 0,_this select 1];
			sleep 5;
			hint _CautionText; 
			[_CautionText, "CAUTION!!!", true, false] call BIS_fnc_guiMessage;
		};
	};
};


//////////////      HEADLESS CLIENTS / SET LOCATION ID    //////////////////////////

private _GroupsLocation = _SpawnModule getVariable ["HCGroupsLocation",5];
private _GroupsLocationFinal = "Server";
if (_GroupsLocation == 1) then {_GroupsLocationFinal = "Server"};
if (_GroupsLocation == 2) then {_GroupsLocationFinal = "HC_1"};
if (_GroupsLocation == 3) then {_GroupsLocationFinal = "HC_2"};
if (_GroupsLocation == 4) then {_GroupsLocationFinal = "HC_3"};
if (_GroupsLocation == 5) then {_GroupsLocationFinal = "Random"};

// Wait a bit for Headless Clients to Start
if (_GroupsLocationFinal != "Server" and isdedicated) then {sleep 30;};

/////////////////////////////////////////                     RUN MAIN SPAWNER FUNCTION                     /////////////////////////////////////////
private _InitialSpawn = true;

while {
	sleep 0.5;
	_SpawnModule GetVariable "HBQ_SpawnsTerminated" == false
} do {
	
	/////////////      WAIT FOR TRIGGERS   (FOR REPEATING TRIGGERING)  /////////////////
	
	
	if (count _SyncedTriggers > 0) then {
		private _trgActive = false;
		while { _trgActive == false } do {
			if (isNil "_SpawnModule") exitWith {true};
			if (isNull _SpawnModule) exitWith {true};
			sleep (_ChecksDelay / 10); // Checks sleep
			{
				if (triggerActivated _x) exitWith {
					private _PlayerActivatedTrigger = objNull;
					if (count(list _x)!=0)then { _PlayerActivatedTrigger = (list _x) select 0;
					diag_log format ["INFO HBQ: %1: Triggered by %2 ", _SpawnModule,_PlayerActivatedTrigger];
					};
					diag_log format ["INFO HBQ: %1: Activated by Trigger %2", _SpawnModule,_x];
					
					
					_trgActive = true
				};
			} forEach _SyncedTriggers;
		};
	};
	
	
	/// GET VALID HC OR FALL BACK TO SERVER
	private _SpawnLocationID = 2;
	private _HC1id = if (!isNil {hc_1}) then {owner hc_1} else { 2 };
	private _HC2id = if (!isNil {hc_2}) then {owner hc_2} else { 2 };
	private _HC3id = if (!isNil {hc_3}) then {owner hc_3} else { 2 };

	if (_GroupsLocationFinal == "HC_1") then {_SpawnLocationID = _HC1id};
	if (_GroupsLocationFinal == "HC_2") then {_SpawnLocationID = _HC2id};
	if (_GroupsLocationFinal == "HC_3") then {_SpawnLocationID = _HC3id};
	private _allHCids = [_HC1id, _HC2id, _HC3id];

	if (_GroupsLocationFinal == "Random") then {_SpawnLocationID = selectRandom  _allHCids;};
	
	//////////////////////// Server FPS Checks ////////////////////////////////////////
	if (_InitialSpawn && _MinServerFPS > 0) then {
		[_MinServerFPS,_SpawnModule,_debug,_ChecksDelay] spawn HBQSS_fnc_ServerFpsCheck;
	};
	
	
	[_SpawnModule, _AllSyncedInfantryData,_AllSyncedVehicleData,_AllSyncedAirVehicleData,_AllSyncedShipVehicleData,_AllSyncedTurretsCrewData,
	_AllSyncedItemsData,_Side,_SyncedSpawnPositions,_SyncedMovePositions,_SyncedVehicles,_SyncedInfantry,_SpawnType,_SyncedTriggers,
	_InitialSpawn,_StopTriggerObj,_SyncedArtyModule,_SyncedSpotterModule,_SyncedCASmodule] remoteExec  ["HBQSS_fnc_Spawner", _SpawnLocationID];
	
	_InitialSpawn = false;
	
	if (_MinRepeatDelay <= 0) exitWith {true}; // Exit if Repeating is disabled
	sleep _MinRepeatDelay;

	
	
}; /// REPEAT SPAWNS LOOP END - End of all Functions

waitUntil   {
	sleep 1;
	if (isNil "_SpawnModule") exitWith {true};
	if (isNull _SpawnModule) exitWith {true};
	_SpawnModule getVariable ["HBQ_SpawnsTerminated",false]
}; 

sleep (_ChecksDelay + (10 * _AI_FeatureActivationDelay) + 10); // Wait until all Units have finished spawning 

/// Delete Big Variables
_AllSyncedItemsData = nil;
_AllSyncedVehicleData = nil;
_AllSyncedAirVehicleData = nil;
_AllSyncedShipVehicleData = nil;
_AllSyncedTurretsCrewData = nil;

/// DELETE SPAWN- AND MOVEPOSITIONS
if (_GarbageCollection) then {
	{
		if (_x == _SpawnModule) then {continue};
		deleteVehicle _x;
	}forEach (_SpawnModule getVariable ["HBQ_SyncedMovePositions",[]]);
	{deleteVehicle _x}forEach _SyncedSpawnPositions;
};
};