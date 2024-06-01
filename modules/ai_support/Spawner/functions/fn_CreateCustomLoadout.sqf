#include "script_component.hpp"
params ["_Vehicle","_LoadoutData"];
private _MagazineCargo = [];
private _ItemsCargo = [];
private _WeaponsCargo = [];
private _BackpackCargo = [];

clearItemCargoGlobal _Vehicle;
clearMagazineCargoGlobal _Vehicle;
clearWeaponCargoGlobal _Vehicle;
clearBackpackCargoGlobal _Vehicle;
if (!isNil{_LoadoutData select 0 select 6}) then {_MagazineCargo = _LoadoutData select 0 select 6;};
if (!isNil{_LoadoutData select 0 select 7}) then {_ItemsCargo = _LoadoutData select 0 select 7;};
if (!isNil{_LoadoutData select 0 select 8}) then {_WeaponsCargo = _LoadoutData select 0 select 8;};
if (!isNil{_LoadoutData select 0 select 9}) then {_BackpackCargo = _LoadoutData select 0 select 9;};

if (count _MagazineCargo != 0) then {
{
_Vehicle addMagazineCargoGlobal   [_x, (_MagazineCargo select 1) select _forEachIndex];
}foreach (_MagazineCargo select 0);
};

if (count _ItemsCargo != 0) then {
{
_Vehicle addItemCargoGlobal [_x, (_ItemsCargo select 1) select _forEachIndex];
}foreach (_ItemsCargo select 0);
};

if (count _WeaponsCargo != 0) then {
{
_Vehicle addWeaponCargoGlobal   [_x, (_WeaponsCargo select 1) select _forEachIndex];
}foreach (_WeaponsCargo select 0);
};

if (count _BackpackCargo != 0) then {
{
_Vehicle addBackpackCargoGlobal   [_x, (_BackpackCargo select 1) select _forEachIndex];
}foreach (_BackpackCargo select 0);
};