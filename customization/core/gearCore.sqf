private ["_unit", "_type"];

_unit = _this select 0;
_type = _this select 1;

if (!local _unit) exitWith {};

removeHeadgear player;
removeGoggles player;
removeVest player;
removeBackpack player;
removeUniform player;
removeAllWeapons player;
removeAllAssignedItems player;

FNC_AddItem = {([_unit] + _this) call FNC_AddItemOrg;};