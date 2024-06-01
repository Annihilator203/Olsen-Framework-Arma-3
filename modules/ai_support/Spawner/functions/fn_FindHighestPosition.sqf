// returns the Index of the highest Positions
params["_Positions"];
private _Hights =[];
private _HighestLocation=[];
{
	_Hights =_Hights + [getTerrainHeightASL _x];
} forEach _Positions;
_HighestLocation = selectMax _Hights;
_Hights find _HighestLocation