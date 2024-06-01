params ["_SpawnPosObj","_SpawnPosition","_Side","_TriggerRadius","_SpawnModule","_ChecksDelay"];	
waituntil {
	_SpawnPosObj setVariable ["HBQ_TriggerCheck",false,true]; // PUBLIC ??
	if (_TriggerRadius > 0 && _TriggerRadius < 100) then {sleep (_ChecksDelay/2);}; 
	if (_TriggerRadius >= 100 && _TriggerRadius < 300) then {sleep _ChecksDelay;}; 
	if (_TriggerRadius >= 300 && _TriggerRadius < 500) then {sleep (_ChecksDelay*1.5);}; 
	if (_TriggerRadius >= 500 && _TriggerRadius < 1000) then {sleep (_ChecksDelay*2);};
	if (_TriggerRadius >= 1000) then {sleep (_ChecksDelay*3)}; 

	count (([_SpawnPosition,_Side,_TriggerRadius,false,_SpawnModule] call HBQSS_fnc_getNearUnits ) select 0) > 0
};
_SpawnPosObj setVariable ["HBQ_TriggerCheck",true,true]; // PUBLIC ??
