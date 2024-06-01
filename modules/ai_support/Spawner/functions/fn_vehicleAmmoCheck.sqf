/* fn_vehicleAmmoCheck
*  Author: PapaReap
*  function name: pr_fnc_vehicleAmmoCheck

*  Arguments:
*  0: <VEHICLE>
*  1: <AMMO TYPE>
*/


params ["_arty","_ammoType"];
_ammoCheck = false;
_totalMags = 0;
_magCount = count magazinesAllTurrets _arty;
_count = _magCount - 1;

for "_i" from 0 to _count do {
    _array = (magazinesAllTurrets _arty) select _i;
    if (_ammoType in _array) then {
        if ((_array select 2) > 0) then {
            _ammoCheck = true;
            _totalMags = _totalMags + (_array select 2);
        };
    };
};

_return = [_ammoCheck, _totalMags];
_return
