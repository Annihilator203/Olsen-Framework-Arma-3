params["_unit"];
if !(alive _unit) exitWith {};
//_unit playMoveNow (selectRandom ["ApanPknlMstpSnonWnonDnon_G01", "ApanPknlMstpSnonWnonDnon_G02", "ApanPknlMstpSnonWnonDnon_G03", "ApanPpneMstpSnonWnonDnon_G01", "ApanPpneMstpSnonWnonDnon_G02", "ApanPpneMstpSnonWnonDnon_G03"]);
//_unit playMove (selectRandom ["ApanPknlMstpSnonWnonDnon_G01"]);
_unit playMove "ApanPpneMstpSnonWnonDnon_G03";
//doStop _unit;
//_unit setPos getPos _unit;
_unit disableAI "PATH";

private _ScreamSounds = [
	"Gendarmerie_RestrictedAreaAlarm_Gendarme_A_01_Vincent",
	"Gendarmerie_RestrictedAreaAlarm_Gendarme_A_Ahmeed_02",
	"Gendarmerie_RestrictedAreaAlarm_Gendarme_B_01_Vincent",
	"Gendarmerie_VehicleAttack_Gendarme_A_01_Vincent",
	"Gendarmerie_AttackWarning_Gendarme_A_01_Vincent",
	"Gendarmerie_AttackWarning_Gendarme_A_02_Vincent",
	"Syndikat_AttackWarning_Soldier_A_01_Vincent",
	"Syndikat_AttackWarning_Soldier_A_Ahmeed_02",
	"Syndikat_AttackWarning_Soldier_B_01_Vincent",
	"Syndikat_AttackWarning_Soldier_B_03_Vincent",
	"Syndikat_EnemyWarning_Soldier_A_02_02_Vincent",
	"Syndikat_EnemyWarning_Soldier_A_02_Ahmeed_01",
	"Syndikat_EnemyWarning_Soldier_A_02_Ahmeed_02",
	"Syndikat_EnemyWarning_Soldier_A_03_Vincent",
	"Syndikat_EnemyWarning_Soldier_A_04_Vincent"
];

// Auskommentieren wenn keine Sounds erwünscht sind
[_unit, [selectRandom _ScreamSounds, 250, 1]] remoteExec ["say3D", 0, true];

//sleep  15;
_unit playActionNow "UP";
sleep 2;
_unit playActionNow "";
sleep 4;
//_unit switchMove "";
_unit enableAI "PATH";