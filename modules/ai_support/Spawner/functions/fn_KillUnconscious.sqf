params ["_group"];

while { ({alive _x} count (units _group)) > 0 } do { 
	sleep 5;
	{ 
		if (alive _x) then {
			if (_x getVariable ["ACE_isUnconscious",false]) then 
			{ 
				_x setVariable ["ace_medical_bloodvolume", 0];
			};
		};
	 
	} forEach units _group;
};