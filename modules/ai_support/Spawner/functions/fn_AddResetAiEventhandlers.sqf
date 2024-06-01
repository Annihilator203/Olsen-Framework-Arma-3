#include "script_component.hpp"
params ["_unit","_ExitStatic","_ExitStaticShotsNear","_isCrew"];

if (_ExitStatic == true) then {

	if (_isCrew) then {
		
		// Explosion Eventhandler
		(objectParent _unit) addEventHandler ["Explosion", {
		params ["_vehicle", "_damage", "_source"];
		
		if (isNull (driver _vehicle) or !Alive (driver _vehicle)) then {
			_vehicle removeEventHandler [_thisEvent, _thisEventHandler];
		} else {
		
			private _suppressionThreshold = (group _vehicle) getVariable ["HBQ_suppressionThreshold",0.5];
			if (_damage >= (_suppressionThreshold*0.5)) then {
				{
					_x enableAI "ALL";
					_x setUnitPos  "AUTO";
					
					
				} forEach (units group (driver _vehicle));
				(group _vehicle) setVariable ["HBQ_Static", false];
				(group _vehicle) enableAttack false;
				_vehicle removeEventHandler [_thisEvent, _thisEventHandler];
			};
		};
		
		}];
		
		/// Dammaged Eventhandler
		(objectParent _unit) addEventHandler ["Dammaged", {
		params ["_unit", "_selection", "_damage", "_hitIndex", "_hitPoint", "_shooter", "_projectile"];
		
		if (isNull (driver _unit) or !Alive (driver _unit)) then {
			_unit removeEventHandler [_thisEvent, _thisEventHandler];
		} else {
			private _suppressionThreshold = (group _unit) getVariable ["HBQ_suppressionThreshold",0.5];
			if (_damage >= _suppressionThreshold) then {
				
				{
					_x enableAI "ALL";
					_x setUnitPos  "AUTO";
					
				} forEach (units group (driver _unit));
				(group driver _unit) enableAttack false;
				(group driver _unit) setVariable ["HBQ_Static", false];
				_unit removeEventHandler [_thisEvent, _thisEventHandler];
			};
		};
		}];

	} else {
	
		// Suppressed Eventhandler
		_unit addEventHandler ["Suppressed", {
			params ["_unit", "_distance", "_shooter", "_instigator", "_ammoObject", "_ammoClassName", "_ammoConfig"];

			private _suppressionThreshold = _unit getVariable ["HBQ_suppressionThreshold",0.5];
			if (getSuppression _unit > _suppressionThreshold) then {
				{
				_x enableAI "ALL";
				_x setUnitPos  "AUTO";
				_x setVariable ["HBQ_Static", false];
				_x removeEventHandler ["AnimChanged", 0];
				} forEach (units group _unit);
				(group _unit) enableAttack true;
				(group _unit) setVariable ["HBQ_Static", false];
				_unit removeEventHandler [_thisEvent, _thisEventHandler];
			};
		}];
	};
};

if (_ExitStaticShotsNear > 0) then {
	if (_isCrew) then {
		// FiredNear Eventhandler
		(objectParent _unit) addEventHandler ["FiredNear", {
			params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
			private _ExitStaticShotsNear = (group driver _unit) getVariable ["HBQ_ExitStaticShotsNear",70];
			
			if (_distance <= _ExitStaticShotsNear) then {
			{
			_x enableAI "ALL";
			_x setUnitPos  "AUTO";
			} forEach (units group (driver _unit));
			(group driver _unit) enableAttack false;
			(group driver _unit) setVariable ["HBQ_Static", false];
			
			
			_unit removeEventHandler [_thisEvent, _thisEventHandler];
			};
			
		}];
	} else {
		// FiredNear Eventhandler
		_unit addEventHandler ["FiredNear", {
			params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
			private _ExitStaticShotsNear = (group _unit) getVariable ["HBQ_ExitStaticShotsNear",70];
			if (_distance <= _ExitStaticShotsNear) then {
			{
			_x enableAI "ALL";
			_x setUnitPos  "AUTO";
			
			} forEach (units group _unit);
			(group _unit) enableAttack false;
			(group _unit) setVariable ["HBQ_Static", false];
			_unit removeEventHandler [_thisEvent, _thisEventHandler];
			};
		}];
	};
};