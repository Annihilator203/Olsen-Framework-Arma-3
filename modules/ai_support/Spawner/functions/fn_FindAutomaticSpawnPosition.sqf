params ["_PlayerSecurityRadius","_debug","_SpawnCenterObj","_MinRadiusAmount","_MaxRadiusAmount","_SpawnAngle","_CheckWatchDirection","_ChecksDelay","_SafeSpawnPositionRadius","_SpawnModule"];

private _TempSafePosition = [0,0,0];
private _SafeSpawnPosition = [0,0,0];
private _TempForestPosition = [0,0,0];
private _SpawnHidden =  _SpawnModule getVariable ["SpawnHidden",false];
private _SpawnType = _SpawnModule getVariable ["HBQ_SpawnType",""];
 
private _SpawnRadius = round (_MinRadiusAmount + random ((_MaxRadiusAmount-_MinRadiusAmount)+0.1));

/// Calculate Random Position in Cone around Spawnmodule (using distance setting, Module Direction and Cone Angle Setting)
private _RandomSpawnPosition = [];
private _SpawnDirection = getDir _SpawnCenterObj;

_RandomSpawnPosition = _SpawnCenterObj getPos [_SpawnRadius, random (_SpawnAngle)-(_SpawnAngle/2)+_SpawnDirection];

_TempSafePosition = [_RandomSpawnPosition, 0, (_SafeSpawnPositionRadius + 40), _SafeSpawnPositionRadius + 5, 1, 40, 0, [], _RandomSpawnPosition] call BIS_fnc_findSafePos; 


/// PREFER SPAWN NEAR BUILDINGS/TREES

if (_SpawnHidden && _SpawnType == "INFANTRY") then {
	
	//// SEARCH BUILDINGS 
	private _NearestBuildings = nearestTerrainObjects [_RandomSpawnPosition, ["House"], ((_SpawnRadius * 0.25) max 50), false, true];
	//private _NearestBuildings = nearestObjects [_RandomSpawnPosition, ["House"], ((_SpawnRadius * 0.25) max 50),true];
	
	private _NearstBldgsShuffle = _NearestBuildings call BIS_fnc_arrayShuffle;
	if(count _NearstBldgsShuffle > 0) exitWith {

		private _ValidBuildings = [];
		_ValidBuildings =  _NearstBldgsShuffle select {count ([_x] call BIS_fnc_buildingPositions) > 0};
		
		if (count _ValidBuildings != 0) then {

			private _done = false;
			{
				
				private _RandomBuildingPositions = [];
				private _RandomBuildingPosShuffle = [];
				_RandomBuildingPositions = _x buildingPos -1;
				private _BuildingMoveposition = [];
				_RandomBuildingPosShuffle = _RandomBuildingPositions call BIS_fnc_arrayShuffle;
				
				{
				
				if (count (_x nearEntities 1) == 0) exitWith {_done = true; _TempSafePosition = _x }; // Check if Buildingpos is allready occupied
				
				} foreach _RandomBuildingPosShuffle;
				
				if (_done) exitWith {_TempSafePosition};
				
			} foreach _ValidBuildings;

		} else {

			private _RandomNonValidBuilding = selectRandom _NearestBuildings;
			_TempSafePosition = [getpos _RandomNonValidBuilding, 0, (_SafeSpawnPositionRadius + 5), (_SafeSpawnPositionRadius + 1), 1, 0, 0, [], _RandomSpawnPosition] call BIS_fnc_findSafePos;

		};
		
		_TempSafePosition
		
	};

	/// NO BUILDING FOUND SEARCH TREES
	private _randomLocations = [];
	private _randomLocation = [];
	for "_i" from 1 to 20 do {
		_randomLocation = [[[_RandomSpawnPosition, ((_SpawnRadius * 0.25)max 50)]], []] call BIS_fnc_randomPos; 
		_randomLocations = _randomLocations + [_randomLocation];
	};

	_TempForestPosition = _randomLocations select ([_randomLocations]call HBQSS_fnc_FindForestPosition);
	if (! isNil {_TempForestPosition select 0}) then {
		_TempSafePosition = [_TempForestPosition, 0, (_SafeSpawnPositionRadius + 2), (_SafeSpawnPositionRadius + 1), 1, 0, 0, [], _TempForestPosition] call BIS_fnc_findSafePos;
	} else {
		_TempSafePosition = [_RandomSpawnPosition, 0, (_SafeSpawnPositionRadius + 2), (_SafeSpawnPositionRadius + 1), 1, 0, 0, [], _TempForestPosition] call BIS_fnc_findSafePos;
	};

};

if (_TempSafePosition isEqualType 0) then {
_TempSafePosition = [_RandomSpawnPosition, 0, (_SafeSpawnPositionRadius + 20), (_SafeSpawnPositionRadius + 20), 1, 0, 0, [], _TempForestPosition] call BIS_fnc_findSafePos;
};

if (count _TempSafePosition != 3) then {_TempSafePosition set [2, 0]};
_SafeSpawnPosition = [_TempSafePosition select 0,_TempSafePosition select 1, _TempSafePosition select 2]; 
if (count _SafeSpawnPosition != 3) then {_SafeSpawnPosition = [0,0,0]};

_SafeSpawnPosition

