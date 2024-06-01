params["_Positions"];

private _HousesCounts =[];
private _MostHouses=0;

{
	_HousesCounts = _HousesCounts + [count (nearestTerrainObjects [_x, ["House","Building"], 30, false, true])];
} forEach _Positions;
_MostHouses = selectMax _HousesCounts;
_HousesCounts find _MostHouses