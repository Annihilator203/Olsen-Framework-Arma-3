params ["_group","_deleteTime","_SpawnModule","_KillTriggerObj"];

private _ChecksDelay = _SpawnModule getVariable ["ChecksDelay",5];
if(_ChecksDelay == -1) then {_ChecksDelay = HBQSS_ChecksDelay;};

if !(_KillTriggerObj isKindOf "EmptyDetector") exitWith {true};

waituntil {
	sleep _ChecksDelay;
	if (isNull _group) exitWith {true};
	if ((count units _group)== 0) exitWith {true};
	triggerActivated _KillTriggerObj

};

if (isNull _group) exitWith {true};
if ((count units _group)== 0) exitWith {true};
sleep (random 10);
[_group,0,_SpawnModule]spawn HBQSS_fnc_DeleteUnitAndVehicle;