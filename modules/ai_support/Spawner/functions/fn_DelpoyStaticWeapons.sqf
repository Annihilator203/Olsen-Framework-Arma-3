params ["_group","_SpawnModule","_direction"];

//private _Mortar_Gunner = objnull;
//private _Mortar_Gunner_Assistent = objnull;
private _BackpackGunClasses = ["weapon","gun","Weapon","Gun"]; // Expand for Mods: Add strings that are contained in Backpackclassnames.
private _BackpackBipodClasses = ["support","bipod","Bipod","tripod","Tripod"]; // Expand for Mods: Add strings that are contained in Backpackclassnames.
private _Debug = _SpawnModule getVariable ["Debug",false];
if !(HBQSS_DebugEnabled) then {_Debug = false};
private _base = objnull;
private _HasGunBag = false;
private _HasBipod = false;
private _Exist_Mortar_Gunner = false;
private _Exits_Assistent = false;
//// DEFINE GUNNER AND ASSISTANT
{
	private _BackpackClass = backpack _x;
	_x setVariable ["HBQ_HasStaticWeapon",false];
	_x setVariable ["HBQ_HasBipod",false];
	 
	{
	if (count ([_BackpackClass,_x] call HBQSS_fnc_FindStringInString) > 0) then {_HasGunBag = true};
	
	} foreach _BackpackGunClasses;
	
	if (_HasGunBag) then {_x setVariable ["HBQ_HasStaticWeapon",true];_Exist_Mortar_Gunner = true; };
	
	
	{
	if (count ([_BackpackClass,_x] call HBQSS_fnc_FindStringInString) > 0) then {_HasBipod = true};
	} foreach _BackpackBipodClasses;
	if (_HasBipod) then {_x setVariable ["HBQ_HasBipod",true];_Exits_Assistent = true;};
	
	_HasGunBag = false;
	_HasBipod = false;
} foreach (units _group);




if (_Exits_Assistent && _Exist_Mortar_Gunner) then {
	
	//// PUT BIPOD BAG ON GROUND

	{	
		if (_x getVariable "HBQ_HasBipod") then {
			_base = unitBackpack _x; 
			_x action ["PutBag"]; 
			
		};

	} foreach (units _group);

	sleep 2;
	///// DEPLOY STATIC WEAPON

	{
		if (_x getVariable "HBQ_HasStaticWeapon") then {
			
			
			_x addEventHandler ["WeaponAssembled", 
			{
				params ["_unit", "_staticWeapon"];
				
				
				_unit action ["GetInGunner", _staticWeapon];
				
			
			}];
			_x domove (getpos (objectparent _base));
			sleep 4;
			_x action ["Assemble", _base]; 

		};
	
	_x setDir _direction;
	
	} foreach (units _group);


	sleep 2;
	 
	if (_debug) then {format ["%1: Static weapon deployed", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};

};


