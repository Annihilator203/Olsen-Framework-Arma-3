params["_CargoData","_CustomVehicleLoadout","_UnloadPosition","_SpawnModule"];

_CargoItem = (_CargoData select 0 select 0) createVehicle _UnloadPosition;
if (_CustomVehicleLoadout)then {[_CargoItem,_CargoData]spawn HBQSS_fnc_CreateCustomLoadout;};

// Custom Init Code
_CustomInitCodeItem = [_SpawnModule getVariable ["CustomInitCodeCargo",""],"spawnedItem","(_this select 0)"]call HBQSS_fnc_stringReplace;

// RUN CUSTOM INIT CODE
if (_CustomInitCodeItem != "") then {
private _code = compile _CustomInitCodeItem;  
[_CargoItem] spawn _code; 
};

_CargoItem spawn {
waitUntil {(position _this select 2) <= 2};

if ((dayTime > 19 && dayTime < 24) or (dayTime > 0 && dayTime < 8)) then {
"Chemlight_Blue" createVehicle ((position _this)vectoradd [1,1,0]);


}; // If is night create Light.

"SmokeShellBlue" createVehicle position _this;

};


_CargoItem