// Split Driver and Gunner to new Group
params ["_group"];
private _DriverGroup = createGroup [(side _group),true];
_DriverGroup setVariable ["HBQ_SpawnedBy",_group getVariable ["HBQ_SpawnedBy",objnull],true];
_DriverGroup setVariable ["HBQ_SpawnPos",_group getVariable ["HBQ_SpawnPos",[]],true];
private _Leader = leader _group;
private _Vehicle = vehicle _Leader;
private _Crew = crew _Vehicle;
private _CrewWithoutCargo = _Crew select {assignedVehicleRole _x select 0 != "cargo"};
private _driver = driver _Vehicle;
private _commander = commander _Vehicle;
private _gunner = gunner _Vehicle;

{
	_x joinAsSilent [_DriverGroup, _forEachIndex];
} foreach _CrewWithoutCargo;

[_DriverGroup]call HBQSS_fnc_deleteGroupWhenEmpty;
[_DriverGroup,_Vehicle,_driver,_gunner,_commander]