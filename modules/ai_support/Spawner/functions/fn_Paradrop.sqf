params ["_vehicle","_OpenHight","_CargoData","_CustomVehicleLoadout","_group","_SpawnModule"];

sleep 3;

private ["_paras","_item"];
_paras = [];

_chuteheight = if (_OpenHight != -1) then {_OpenHight } else { 120 };// Height to auto-open chute, ie 120 if not defined.
_item = if (count (_this select 2) != 0) then {_CargoData} else {nil};// Cargo to drop, or nothing if not selected.
_vehicle allowDamage false;
_dir = direction _vehicle;

ParaLandSafe =
{
    private ["_unit"];
    _unit = _this select 0;
    _chuteheight = _this select 1;
    (vehicle _unit) allowDamage false;
    [_unit,_chuteheight] spawn AddParachute;//Set AutoOpen Chute if unit is a player
    waitUntil { isTouchingGround _unit || (position _unit select 2) < 1 };
    _unit action ["eject", vehicle _unit];
    sleep 1;
    _unit setUnitLoadout (_unit getVariable ["Saved_Loadout",[]]);// Reload Saved Loadout
    _unit allowdamage true;// Now you can take damage.
};

AddParachute =
{
    private ["_paraUnit"];
    _paraUnit = _this select 0;
    _chuteheight = _this select 1;
    waitUntil {(position _paraUnit select 2) <= _chuteheight};
    _paraUnit addBackPack "B_parachute";// Add parachute
    If (vehicle _paraUnit IsEqualto _paraUnit ) then {_paraUnit action ["openParachute", _paraUnit]};//Check if players chute is open, if not open it.
};

{
    _x setVariable ["Saved_Loadout",getUnitLoadout _x,true];// PUBLIC ??
    removeBackpack _x;
    _x disableCollisionWith _vehicle;// Sometimes units take damage when being ejected.
    _x allowdamage false;// Good Old Arma, they still can take damage on Vehcile exit.
    
    
	//_x leaveVehicle _vehicle;
	unassignvehicle _x;
	moveout _x;
	
    _x setDir (_dir + 90);// Exit the chopper at right angles.
    _x setvelocity [0,0,-5];// Add a bit of gravity to move unit away from _vehicle
    sleep 0.3;//space the Para's out a bit so they're not all bunched up.
} forEach units _group;

{
    [_x,_chuteheight] spawn ParaLandSafe;
} forEach units _group;

if (!isNil ("_item")) then {

	private _CargoDrop = [_CargoData,_CustomVehicleLoadout,getpos _vehicle,_SpawnModule] call HBQSS_fnc_UnloadCargo;


	_CargoDrop allowDamage false;
	_CargoDrop disableCollisionWith _vehicle;
	_CargoDrop setPos [(position _vehicle select 0) - (sin (getdir _vehicle)* 15), (position _vehicle select 1) - (cos (getdir _vehicle) * 15), (position _vehicle select 2)];
	//clearMagazineCargoGlobal _CargoDrop;clearWeaponCargoGlobal _CargoDrop;clearItemCargoGlobal _CargoDrop;clearbackpackCargoGlobal _CargoDrop;
	waitUntil {(position _CargoDrop select 2) <= _chuteheight};
	[objnull, _CargoDrop] call BIS_fnc_curatorobjectedited;

};

_vehicle allowDamage true;
