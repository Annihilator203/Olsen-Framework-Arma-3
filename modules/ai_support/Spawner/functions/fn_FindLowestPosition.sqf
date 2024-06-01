// returns the Index of the lowest Positions
params["_Positions"];
private _Hights =[];
private _HighestLocation=[];

{
	_Hights =_Hights + [getTerrainHeightASL _x];
} forEach _Positions;

_HighestLocation = selectMin _Hights;
_Hights find _HighestLocation