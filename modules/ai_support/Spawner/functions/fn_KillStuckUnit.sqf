params ["_unit"];
sleep 10;
while {alive _unit} do {
	private _Startpos = getPos _unit;
	sleep 10;
	private _EndPos = getPos _unit;
	if ((_Startpos distance2d _EndPos)< 2 ) then {
		_unit setDamage 1};
	sleep 7;
};