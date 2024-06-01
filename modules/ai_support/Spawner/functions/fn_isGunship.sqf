#include "script_component.hpp"
private ["_mags","_mag","_ammoC","_sim"];
params ["_heli"];

private _weaponsAll = [_heli] call HBQSS_fnc_TakeWeapons;	
private _isGunship = false;

	{
	if (isArray (configfile >> "CfgWeapons" >> (_x select 0) >> "magazines")) then
		{
		_mags = (getArray (configfile >> "CfgWeapons" >> (_x select 0) >> "magazines"));
		if ((count _mags) > 0) then
			{
			_mag = _mags select 0;
			
			if (isText (configfile >> "CfgMagazines" >> _mag >> "simulation")) then
				{
				_ammoC = getText (configfile >> "CfgMagazines" >> _mag >> "ammo");
				_sim = configFile >> "CfgAmmo" >> _ammoC >> "simulation";
				
				_isGunship = (isText _sim) and {((toLower (getText _sim)) in ["shotmissile","shotrocket"])};
				};
			};
		};
		
	if (_isGunship) exitWith {};
	}
foreach ((_weaponsAll select 0) + (_weaponsAll select 1));

_isGunship