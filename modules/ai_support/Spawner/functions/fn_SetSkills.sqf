params ["_unit","_Skill","_SpawnModule"];

_unit setSkill _Skill;
private _UseCBAskillsModule = _SpawnModule getVariable ["UseCBAskills",false];
private _UseCBAskills = false;
if (_UseCBAskillsModule && HBQSS_UseHBQSkills) then {_UseCBAskills = true};


private _UseVcomSkills = _SpawnModule getVariable ["VcomSkill",true];



if (_UseCBAskills) then {
sleep 15; // Initial sleep for Vcom Compatibility.

_unit setSkill ["aimingAccuracy", HBQSS_AimingSkill];
_unit setSkill ["aimingShake", HBQSS_aimingShake];
_unit setSkill ["aimingSpeed", HBQSS_aimingSpeed];
_unit setSkill ["spotDistance", HBQSS_spotDistance];
_unit setSkill ["spotTime", HBQSS_spotTime];
_unit setSkill ["courage", HBQSS_courage];
_unit setSkill ["reloadSpeed", HBQSS_reloadSpeed];
_unit setSkill ["commanding", HBQSS_commanding];
_unit setSkill ["general", HBQSS_general];
};


/// Set Skill Again for Vcom Compatibility
if (!_UseVcomSkills && !_UseCBAskills) then {
sleep 15;
_unit setSkill _Skill;

};
