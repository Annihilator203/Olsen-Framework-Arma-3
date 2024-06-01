#include "script_component.hpp"
params ["_group","_radius","_TargetPosition"];
private ["_group","_radius","_TargetPosition","_units","_count", "_diff", "_movePos", "_degree", "_newPos", "_watchPos"]; 

_units =  units _group; 

_move_fnc1 = 
{ 
 params ["_unit", "_posArray"]; 
 private ["_pos", "_watchPos"]; 
 _pos = _posArray select 0; 
 _watchPos = _posArray select 1; 
 if (vehicle _unit != _unit) exitWith {}; 
 sleep 0.1;
 waitUntil {
 sleep 0.1;
 if (isNull _unit) exitWith {true};
 unitReady _unit
 };
 doStop _unit; 
 _unit setUnitPos "MIDDLE"; 
 sleep 0.2; 
 _unit moveTo _pos; 
 waitUntil {sleep 1; (!alive _unit || moveToCompleted _unit || currentCommand _unit != "STOP")}; 
 _unit doWatch _watchPos; 
 waitUntil {sleep 1; (!alive _unit || currentCommand _unit != "STOP")}; 
 _unit doWatch objNull; 

}; 

_count = count _units; 
if (_count == 0) exitWith {}; 
_diff = 360/_count; 
_movePos = []; 
for "_i" from 0 to (_count -1) do  
{ 
 _degree = 1 + _i*_diff; 
 _newPos = [_radius*(sin _degree), _radius*(cos _degree), 0] vectorAdd _TargetPosition; 
 _watchPos = [100*(sin _degree), 100*(cos _degree), 0] vectorAdd _TargetPosition; 
 _movePos pushBack [_newPos, _watchPos]; 
}; 
for "_i" from 0 to (_count-1) do  
{ 
 [_units select _i, _movePos select _i] spawn _move_fnc1; 
};