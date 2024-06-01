params["_Positions"];
	private _treesCounts =[];
	private _MostTrees=0;
	{
	_treesCounts = _treesCounts + [count (nearestTerrainObjects [_x, ["Tree", "Bush","ROCK"], 30, false, true])];
	} forEach _Positions;
	_MostTrees = selectMax _treesCounts;
	_treesCounts find _MostTrees