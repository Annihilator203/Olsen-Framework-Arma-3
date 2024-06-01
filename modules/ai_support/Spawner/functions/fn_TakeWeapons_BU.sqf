private ["_modes","_mode","_isHoming","_mags","_mag","_ammo","_airLock","_irLock","_laserLock","_nvLock"];
params ["_veh"];

private _weaponsHoming = [];
private _weapons = [];

	{
	_modes = getarray (configfile >> "cfgweapons" >> _x >> "modes");
	if (count _modes > 0) then 
		{
		_mode = _modes select 0;
		if (_mode == "this") then {_mode = _x;};
		
		_isHoming = false;
		_airLock = 0;
		
		if (isArray (configfile >> "CfgWeapons" >> _x >> "magazines")) then
			{
			_mags = (getArray (configfile >> "CfgWeapons" >> _x >> "magazines"));
			if ((count _mags) > 0) then
				{
				_mag = _mags select 0;
				
				if (isText (configfile >> "CfgMagazines" >> _mag >> "ammo")) then
					{
					_ammo = getText (configfile >> "CfgMagazines" >> _mag >> "ammo");
					_irLock = configFile >> "CfgAmmo" >> _ammo >> "irLock";
					_laserLock = configFile >> "CfgAmmo" >> _ammo >> "laserLock";
					_nvLock = configFile >> "CfgAmmo" >> _ammo >> "nvLock";
					_airLock = getNumber (configFile >> "CfgAmmo" >> _ammo >> "airLock");
					
					_isHoming = (({(not (isNumber _x) or {((getNumber _x) < 1)})} count [_irLock,_laserLock,_nvLock]) < 3) and {(_airLock < 1)};
					};
				};
			};
		
		if (_isHoming) then
			{
			_weaponsHoming pushBack [_x,_mode];
			}
		else
			{
			if (_airLock < 2) then
				{
				_weapons pushBack [_x,_mode];
				}
			}
		};
	} 
foreach ((typeOf _veh) call bis_fnc_weaponsEntityType);



[_weaponsHoming,_weapons]