params["_SpawnModule","_MaxGlobalUnits","_debug","_ChecksDelay"];

while {sleep 0.5; _SpawnModule GetVariable "HBQ_SpawnsTerminated" == false} do {
	private _AllKIUnits = allUnits select {!(isPlayer _x)};
	if ((count _AllKIUnits) >= _MaxGlobalUnits) then {
		_SpawnModule setVariable ["HBQ_MaxUnits", true,true];// PUBLIC ??

		/// DEBUG
		if (_debug) then {format ["%1: Spawn is Paused. Max number of KI reached", _SpawnModule] remoteExec ["systemchat", TO_ALL_PLAYERS];};
	} else {
		_SpawnModule setVariable ["HBQ_MaxUnits", false,true];// PUBLIC ??
	};
	
	if (_debug) then {format ["%1: Total KI units in Mission: %2 ", _SpawnModule,count _AllKIUnits] remoteExec ["systemchat", TO_ALL_PLAYERS];};
	sleep (_ChecksDelay * 2);
};