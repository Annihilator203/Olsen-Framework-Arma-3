params ["_group","_TakeCover"];
sleep 10;
if (isNil "_group") exitWith {true};
if (isNull _group) exitWith {true};
{_x enableAI "AUTOCOMBAT";_x enableAI "CHECKVISIBLE";}foreach units _group;

waituntil {
	sleep 0.2;
	if (isNil "_group") exitWith {true};
	if (isNull _group) exitWith {true};

	_group GetVariable ["HBQ_HoldFire",false] == false
};

_group setVariable ["lambs_danger_disableGroupAI",not (_group getVariable "HBQ_Lambs")];

{
	_x enableAI "AutoTarget";
	_x enableAI "Target";
	_x enableAI "AutoCombat";
	_x setVariable ["SFSM_excluded", not (_group getVariable "HBQ_DCO_SFSM")];
	_x setVariable ["lambs_danger_disableAI", not (_group getVariable "HBQ_Lambs")];
	if !(_TakeCover) then {_x setUnitPos "AUTO";};
} foreach units _group;

_group setVariable ["HBQ_RushTargetPosition", false];