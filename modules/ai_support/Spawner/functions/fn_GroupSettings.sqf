params["_group","_Speed","_TCL","_DespawnSecurityRadius","_debug","_deleteTime","_CheckWatchDirection","_DynamicSimulation","_SpawnDirection","_AllowFleeing",
"_IgnoreHCTransfer","_Reinforcments","_Vcom","_Lambs","_ChecksDelay","_SpawnModule","_ACE_unconscious","_SpawnType",
"_isCrew","_StanceInfrantry","_SpawnPosition","_RushTargetPosition","_SyncedArtyModule","_SyncedCASmodule","_SyncedSpotterModule",
"_ExitStaticShotsNear","_KillTriggerObj","_Formation"];

//// VARIABLES
//private _Behaviour = _groupData select 0 select 0 select 0 select 4;



// HBQ VARIABLES
if (_ExitStaticShotsNear > 0) then {_group setVariable ["HBQ_ExitStaticShotsNear", _ExitStaticShotsNear,true]};
_group setVariable ["HBQ_SpawnedBy", _SpawnModule,true];
_group setVariable ["HBQ_ReachedTargetPos",false,true];
_group setVariable ["HBQ_IsExecutingTask",false];
_group setVariable ["HBQ_SpawnFinished",false];
_group setVariable ["HBQ_HoldFire", false];
_group setVariable ["VCM_DisableForm",true];
_group setVariable ["HBQ_IsEngaging",false];
_group setVariable ["HBQ_TargetPos", [0,0,0]];
_group setVariable ["HBQ_RushTargetPosition", _SpawnModule getVariable ["IgnoreEnemies",false]];
_group setVariable ["HBQ_suppressionThreshold", _SpawnModule getVariable ["suppressionThreshold",false]];
_group setVariable ["HBQ_Stance", _StanceInfrantry];
_group setVariable ["HBQ_IsFleeing", false];
_group setVariable ["HBQ_TakeCover", _SpawnModule getVariable ["SupportbyFire",false]];
_group setVariable ["HBQ_SpawnPos", _SpawnPosition];
_group setVariable ["HBQ_Lambs", _Lambs];
_group setVariable ["HBQ_Vcom", _Vcom];
_group setVariable ["HBQ_SkillAiming", HBQSS_AimingSkill];
_group setVariable ["HBQ_DCO_SFSM", _SpawnModule getVariable ["DCO_SFSM",false]];
_group setVariable ["HBQ_debug", _debug];
_group setVariable ["HBQ_Static",  _SpawnModule getVariable ["StaticAI",false]];
_group setVariable ["HBQ_Shutup", _SpawnModule getVariable ["ShutUp",false]];
_group setVariable ["HBQ_Raycast", _SpawnModule getVariable ["Raycasting",false]];



private _CustomInitCodeReplaced  = "";

if (! isNull _SyncedSpotterModule) then {
_group setVariable ["HBQ_isSpotting",false,true];// PUBLIC 
};


if (! isNull _SyncedArtyModule) then {
	_group setVariable ["HBQ_ArtyCoolDown",_SyncedArtyModule getVariable ["cooldown",180],true]; // PUBLIC 
	_group setVariable ["HBQ_TypeOfShells",_SyncedArtyModule getVariable ["TypeOfShells",""],true]; // PUBLIC 
	_group setVariable ["HBQ_RequestedRounds",_SyncedArtyModule getVariable ["RequestedRounds",5],true];// PUBLIC 
	_group setVariable ["HBQ_RoundsDelay",_SyncedArtyModule getVariable ["RoundsDelay",5],true];// PUBLIC 
	_group setVariable ["HBQ_ArtillerySpread",_SyncedArtyModule getVariable ["ArtillerySpread",200],true];// PUBLIC 
	_group setVariable ["HBQ_isArtillery",true,true];// PUBLIC 
	_group setVariable ["HBQ_arty_availForMission",true,true];// PUBLIC 
	_group setVariable ["HBQ_artySpot_roundsFired", 0, true];// PUBLIC 
	_group setVariable ["HBQ_Maxrounds",_SyncedArtyModule getVariable ["MaxRounds",32],true];// PUBLIC 
	_group setVariable ["HBQ_VanillaArty",_SyncedArtyModule getVariable ["VanillaArty",false],true];//PUBLIC
	if (_SyncedArtyModule getVariable ["DisableArtyAI",false]) then {
		_group setVariable ["TCL_Disabled", true];
		_group setVariable ["lambs_danger_enableGroupReinforce", false,true];// PUBLIC
		_group setVariable ["Vcm_Disable",true];
		_group setVariable ["lambs_danger_disableGroupAI", true];

	};

};

if ((!isNull _SyncedCASmodule) && _isCrew) then {
	_group setVariable ["HBQ_UsePylon",_SyncedCASmodule getVariable ["UsePylon",-2],true];// PUBLIC 
	_group setVariable ["HBQ_ArtyCoolDown",_SyncedCASmodule getVariable ["cooldown",180],true];// PUBLIC 
	_group setVariable ["HBQ_MaxMissionTime",_SyncedCASmodule getVariable ["MaxMissionTime",180],true];// PUBLIC 
	_group setVariable ["HBQ_FlyHight",_SyncedCASmodule getVariable ["FlyHight",150],true];
	_group setVariable ["HBQ_RequestedMissiles",_SyncedCASmodule getVariable ["RequestedMissiles",3],true];// PUBLIC
	_group setVariable ["HBQ_MissilesDelay",_SyncedCASmodule getVariable ["MissilesDelay",3],true];// PUBLIC
	_group setVariable ["HBQ_IsCas",true,true];// PUBLIC 
	_group setVariable ["HBQ_MissilePrecision",_SyncedCASmodule getVariable ["MissilePrecision",0.5],true];// PUBLIC 
	_group setVariable ["HBQ_arty_availForMission",true,true];// PUBLIC 
	_group setVariable ["HBQ_CasAttackDistance",_SyncedCASmodule getVariable ["CasAttackDistance",600],true];// PUBLIC 
	_group setVariable ["HBQ_CasSearchDistance",_SyncedCASmodule getVariable ["CasSearchDistance",150],true];// PUBLIC 
	if (_SyncedCASmodule getVariable ["DisableArtyAI",false]) then {
			_group setVariable ["TCL_Disabled", true];
			_group setVariable ["lambs_danger_enableGroupReinforce", false,true];// PUBLIC 
			_group setVariable ["Vcm_Disable",true];
			_group setVariable ["lambs_danger_disableGroupAI", true];

		};
};

/// INITCODE
if (_isCrew) then {
_CustomInitCodeReplaced =[_SpawnModule getVariable ["CustomInitCodeCrew",""],"spawnedGroup","(_this select 0)"]call HBQSS_fnc_stringReplace;
} else {
_CustomInitCodeReplaced =[_SpawnModule getVariable ["CustomInitCode",""],"spawnedGroup","(_this select 0)"]call HBQSS_fnc_stringReplace;
};

// RUN CUSTOM INIT CODE
if (_CustomInitCodeReplaced != "") then {
private _code = compile _CustomInitCodeReplaced;  
[_group] spawn _code; 
};

// ACE UNCONCIOUS
if (HBQSS_ACE_Loaded &&  !(_ACE_unconscious) ) then {
	if !(isNil "ace_medical_statemachine_AIUnconsciousness") then {[_group] spawn HBQSS_fnc_KillUnconscious};
	if !(isNil "ace_medical_enableUnconsciousnessAI") exitWith {true}; // Old ACE Version (TitanPlatoon)
}; 

// Spawn Delete Function when Deletetime is set (units get deleted after this time)
if (_deleteTime > 0) then { 
[_group,_deleteTime,_SpawnModule]spawn HBQSS_fnc_DeleteUnitAndVehicle;
};

/////////////////////////   KILL TRIGGER    /////////////////////////
if (_KillTriggerObj != objNull) then {

[_group,_deleteTime,_SpawnModule,_KillTriggerObj] spawn HBQSS_fnc_KillTrigger;

};





if (_DynamicSimulation) then {
	_group enableDynamicSimulation true
};

_group setSpeedMode _Speed;
_group setFormDir _SpawnDirection;
_group allowFleeing _AllowFleeing;
_group setFormation _Formation;

/// ACE Headless Blacklist and ZULU Blacklist
if (_IgnoreHCTransfer) then {
	_group setVariable["zhc_offload_blacklisted", true];
};

/////////////// AI MODS GROUP SETTINGS
if !(_RushTargetPosition) then {
_group setVariable ["TCL_Disabled", not _TCL];
if (_Reinforcments) then {_group setVariable ["lambs_danger_enableGroupReinforce", _Reinforcments,true];};// PUBLIC 
_group setVariable ["lambs_danger_disableGroupAI", not _Lambs];	
if (_Lambs) then {_group setVariable ["lambs_danger_dangerFormation", "LINE"]};
};
_group setVariable ["Vcm_Disable",not _Vcom];




