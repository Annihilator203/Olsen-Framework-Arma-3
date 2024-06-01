params ["_group","_LeaderDistance","_ChecksDelay"];
sleep 10;

while {
	count (units _group) > 1 && !(isNull _group)
} do {

/////// UNITS MOVE IN FORMATION //////////

	private _MaxDistance = 0;
	private _ActualDistance = 0;
	{
		_ActualDistance = _x distance2d (leader _group);
		_MaxDistance = _MaxDistance max _ActualDistance;
		if (_ActualDistance > _LeaderDistance && side _x == side (leader _group) && alive _x) then {
			[_x] spawn {
			params ["_unit"];
			private _formationPos = formationPosition _unit;
			_unit setVariable ["HBQ_IsForcedToMove",true];
			[_unit,[_formationPos],{},"AmovPercMrunSrasWrflDf_ldst",12,0.3] call BIS_fnc_scriptedMove;
			_unit setVariable ["HBQ_IsForcedToMove",false];
			[_unit] joinSilent  group _unit;
			_unit doFollow (leader group _unit);
			};
		};
	} foreach (units _group) -[leader _group];

//////// TEAMLEADER WAIT /////////////////

	private _AllUnitsInFormation = true;
		{
			if (HBQSS_ACE_Loaded) then {
				if (not isNull _x && side _x == side (leader _group) && !(_x getVariable ["ACE_isUnconscious", false]) && alive _x) then {
					_AllUnitsInFormation = _AllUnitsInFormation && (_x distance2d leader _group ) < _LeaderDistance;
				};
			} else {
				if (not isNull _x && side _x == side (leader _group) && damage _x < 0.5 && alive _x) then {
					_AllUnitsInFormation = _AllUnitsInFormation && (_x distance2d leader _group) < _LeaderDistance;
				};
			};
		} forEach units _group;

	//// If a Unit of Group is not in Formation Teamleader Waits
	private _leader = (leader _group);
	if (not _AllUnitsInFormation && _leader getVariable "HBQ_IsForcedToMove" == false) then {
		if (isNull (leader _group)) exitWith {true};
		_leader disableAI "PATH";
		sleep (_MaxDistance * 0.03 * _ChecksDelay);  // TIME THE LEADER WAITS FOR MEMBERS OF THE GROUP
		if (((group _leader) getVariable "HBQ_TakeCover" == false or _group getVariable "HBQ_ReachedTargetPos" == false) && _group getVariable "HBQ_Static" == false) then {_leader enableAI "PATH";};
	};
	sleep (_ChecksDelay);
};