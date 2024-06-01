#include "script_component.hpp"

private _version = 0.1;

["AI Supports", "Adds AI CAS Spotters and CAS ability", "Annihilator", _version] call EFUNC(FW,RegisterModule);


GVAR(spotterMaxDist) = ([missionConfigFile >> QGVAR(settings) >> "spotterMaxDist", "number", 1] call CBA_fnc_getConfigEntry);
GVAR(spotterRadioRange) = ([missionConfigFile >> QGVAR(settings) >> "spotterRadioRange", "number", 1] call CBA_fnc_getConfigEntry);
GVAR(callChance) = ([missionConfigFile >> QGVAR(settings) >> "callChance", "number", 1] call CBA_fnc_getConfigEntry);
GVAR(callDelay) = ([missionConfigFile >> QGVAR(settings) >> "callDelay", "number", 1] call CBA_fnc_getConfigEntry);
GVAR(laseDist) = ([missionConfigFile >> QGVAR(settings) >> "laseDist", "number", 1] call CBA_fnc_getConfigEntry);
GVAR(dangClose) = ([missionConfigFile >> QGVAR(settings) >> "dangClose", "number", 1] call CBA_fnc_getConfigEntry);
GVAR(supportTimeout) = ([missionConfigFile >> QGVAR(settings) >> "supportTimeout", "number", 1] call CBA_fnc_getConfigEntry);
GVAR(spotterAbil) = ([missionConfigFile >> QGVAR(settings) >> "spotterAbil", "number", 1] call CBA_fnc_getConfigEntry) ;
GVAR(minTargetSize) = ([missionConfigFile >> QGVAR(settings) >> "minTargetSize", "number", 1] call CBA_fnc_getConfigEntry);


GVAR(casAvail) = [missionConfigFile >> QGVAR(settings) >> "casAvail", "number", "1"] call CBA_fnc_getConfigEntry  == 1;
GVAR(casAttackDist) = [missionConfigFile >> QGVAR(settings) >> "casAttackDist", "number", 1] call CBA_fnc_getConfigEntry;
GVAR(casAcc) = ([missionConfigFile >> QGVAR(settings) >> "casAcc", "number", 1] call CBA_fnc_getConfigEntry);
GVAR(numMissiles) = ([missionConfigFile >> QGVAR(settings) >> "numMissiles", "number", 1] call CBA_fnc_getConfigEntry);
GVAR(delay) = ([missionConfigFile >> QGVAR(settings) >> "delay", "number", 1] call CBA_fnc_getConfigEntry);
GVAR(cooldown) = ([missionConfigFile >> QGVAR(settings) >> "cooldown", "number", 1] call CBA_fnc_getConfigEntry);
GVAR(usePylon) = ([missionConfigFile >> QGVAR(settings) >> "usePylon", "number", 1] call CBA_fnc_getConfigEntry) ;
GVAR(searchDistance) = ([missionConfigFile >> QGVAR(settings) >> "searchDistance", "number", 1] call CBA_fnc_getConfigEntry);
GVAR(maxTime) = ([missionConfigFile >> QGVAR(settings) >> "maxTime", "number", 1] call CBA_fnc_getConfigEntry) ;
GVAR(flyHeight) = ([missionConfigFile >> QGVAR(settings) >> "flyHeight", "number", 1] call CBA_fnc_getConfigEntry);

