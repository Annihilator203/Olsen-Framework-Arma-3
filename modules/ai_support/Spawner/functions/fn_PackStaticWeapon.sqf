params ["_group","_SpawnModule"];


private _Debug = _SpawnModule getVariable ["Debug",false];
if !(HBQSS_DebugEnabled) then {_Debug = false};
private _Mortar_Gunner = objnull;
private _Mortar_Gunner_Assistent = objnull;


private _Exist_Mortar_Gunner = false;
if (count (units _group) >= 3 ) then {
{
	if ( (objectparent _x) isKindOf "StaticWeapon") then {
	_Exist_Mortar_Gunner = true;
	};

} foreach (units _group);





if (_Exist_Mortar_Gunner) then {[_group] call BIS_fnc_packStaticWeapon};
sleep 2;
if (_debug) then {format ["%1: Static weapon Packed", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};
};


/*

//// DEFINE GUNNER AND ASSISTANT

{

if ( (objectparent _x) isKindOf "StaticWeapon") then {
_x setVariable ["HBQ_HasStaticWeapon",true]; _Exist_Mortar_Gunner = true; _Mortar_Gunner = _x 
} else {
_Mortar_Gunner_Assistent = _x;


};

	
} foreach (units _group);




if (_Exist_Mortar_Gunner && count (units _group)> 1 ) then {
	
	systemchat "CHECK DOIT";
	
	_mortarVehicle = vehicle _mortar_gunner;	
	_mortar_gunner action ["getOut", _mortarVehicle];
	_mortar_gunner action ["DisAssemble", _mortarVehicle]; 
	sleep 3;
	private _array = nearestObjects [_mortar_gunner, ["WeaponHolder"], 55];
	systemchat str _array;
	sleep 1;
	private _wh = _array select 0;

	if (!isNull (firstBackpack _wh)) then 
	{
	_bp = firstBackpack _wh;
	_mortar_gunner action ["AddBag", _wh, typeOf _bp];
	};


	//deleteVehicle  _bp;
	sleep 6;
	private _array2 = nearestObjects [_Mortar_Gunner_Assistent, ["WeaponHolder"], 55];
	
	private _wh2 = _array2 select 0;
	

	if (!isNull (firstBackpack _wh2)) then 
	{
	private _bp2 = firstBackpack _wh2;
	_Mortar_Gunner_Assistent action ["AddBag", _wh2, typeOf _bp2];
	};

	//deleteVehicle  _mortarVehicle;
	sleep 2;

	 
	if (_debug) then {format ["%1: Static weapon Assembled", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};

};




















































		
		
	
		_mortarVehicle = vehicle _mortar_gunner;	
		_mortar_gunner action ["getOut", _mortarVehicle];
		_mortar_gunner action ["DisAssemble", _mortarVehicle]; 
		sleep 2;
		

		sleep 1;
		_wh = _array select 0;

		if (!isNull (firstBackpack _wh)) then 
		{
		_bp = firstBackpack _wh;
		_mortar_gunner action ["AddBag", _wh, typeOf _bp];
		};


		//deleteVehicle  _bp;
		sleep 6;
		_array2 = nearestObjects [_Mortar_Gunner_Assistent, ["WeaponHolder"], 35];
		
		_wh2 = _array2 select 0;
		

		if (!isNull (firstBackpack _wh2)) then 
		{
		_bp2 = firstBackpack _wh2;
		_Mortar_Gunner_Assistent action ["AddBag", _wh2, typeOf _bp2];
		};

		//deleteVehicle  _mortarVehicle;
		sleep 2;