params ["_obj"];
private _Syncpositions = [];
private _SyncronizedObjects = [];
_SyncronizedObjects = synchronizedObjects _obj;
_Syncpositions =_SyncronizedObjects select {typeOf _x == "HBQ_MovePosition";};
if (count _Syncpositions > 0) then {_Syncpositions deleteRange [0,1];}; // Delete first Element
_Syncpositions