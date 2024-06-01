params ["_group","_Areas","_TaskCancelDelay","_TaskResetTriggerObj","_ChecksDelay","_debug","_SpawnModule","_Spawntype","_StaticAI","_isCrew"];

private _SpawnType = _SpawnModule getVariable ["HBQ_SpawnType",""];

/// EXIT IF CREW OF TRANSPORT
if (_isCrew && (_SpawnType == "TRANSPORT"  or _SpawnType == "AIRTRANSPORT" or _SpawnType == "NAVALTRANSPORT")) exitwith {true};


//////  VARIABLES
{_x setVariable ["HBQ_IsForcedToMove",false];} forEach units _group;
//private _AreaTriggersStringUnfiltered = _SpawnModule getVariable ["StayInAreasTrigger",""];
private _AreaTriggersString =[_SpawnModule getVariable ["StayInAreasTrigger",""]," ",""]call HBQSS_fnc_stringReplace;
private _MoveToLatestArea = _SpawnModule getVariable ["MoveToLatestArea",true];
private _AreaTriggersArray = (_AreaTriggersString) splitString ",";
private _AreaTriggersObjs = [];
private _AreasAreObjects = false;
private _OldActiveAreaObj = objNull;
private _ActiveTargetObj = objNull;
private _TriggerTimes = [];
private _ActiveArea = "";
private _OldActiveArea = "";
private _ActiveAreas = [];
private _AreaIsGroup= false;
private _AreaObjects = [];
private _maxTriggerTime = 0;
private _Behaviour = "";
private _startTime = time;
private _currentTime = time;
private _ReturntoBase = _SpawnModule getVariable ["ReturntoBase",false];



if (_TaskCancelDelay <= 0) then {_TaskCancelDelay = 10800};
private _ActiveAreaPosition = [];
private _DistanceThreashold = 40;
private _UnitPos = [0,0,0];
if (_Spawntype == "VEHICLES" )then {_DistanceThreashold = 150};
if (_Spawntype == "CARGOTRANSPORT")then {_DistanceThreashold = 60};
if (_SpawnType != "INFANTRY" && _isCrew) then {_DistanceThreashold = 90};
if ((_SpawnType == "AIRVEHICLES" or _SpawnType == "AIRTRANSPORT") && _isCrew) then {_DistanceThreashold = 200};
if ((_SpawnType == "AIRCARGOTRANSPORT") && _isCrew) then {_DistanceThreashold = 60};
if (_Spawntype == "VEHICLES" or _Spawntype == "CARGOTRANSPORT")then {_group setVariable ["VCM_NOFLANK",true]};



////// GET AREA TRIGGERS
{
	_AreaTriggersObjs = _AreaTriggersObjs + [missionNamespace getVariable [_x , objNull]];
} foreach _AreaTriggersArray;

////// SET TRIGGERED TIME VARIABLE

if ((count _AreaTriggersObjs) > 0 && _MoveToLatestArea) then {
	{
		[_x,_ChecksDelay,_group] spawn HBQSS_fnc_SetAreaTriggerTime;
	} forEach _AreaTriggersObjs;

};

sleep _ChecksDelay; // WAIT So Triggertime function has time to set Q_AreaTriggerTime

//////// WHILE LOOP



while { (_currentTime - _startTime) < _TaskCancelDelay and not triggerActivated _TaskResetTriggerObj} do
{
	sleep (_ChecksDelay);
	if (isNull _group) exitWith {};
	//&& (_group getVariable ["HBQ_CargoUnloaded",false])
	if (_ReturntoBase &&  (_group getVariable ["HBQ_ReachedTargetPos", false]) ) exitWith {
	sleep 20;
	[_group, _debug,_SpawnModule,true] spawn HBQSS_fnc_ReturnToBase;
	
	};

	
	if (_group getVariable "HBQ_IsFleeing") exitWith {true};
	if (_group getVariable "HBQ_IsEngaging") then {continue};
	if (_group getVariable "HBQ_IsExecutingTask") then {continue};
	/////// Check if Areas are Objects

	private _FirstAreaObjInArray = missionNamespace getVariable [(_Areas select 0) , objNull];
	if (typeName _FirstAreaObjInArray == "GROUP") then {_AreaIsGroup = true};
	if (_AreaIsGroup == false) then {
	if (_FirstAreaObjInArray isKindOf "AllVehicles" or _FirstAreaObjInArray isKindOf "Thing" or _FirstAreaObjInArray isKindOf "Logic") then {_AreasAreObjects = true};
	};
	
	
	if (_AreasAreObjects or _AreaIsGroup) then {
		
		_AreaObjects = [];
		
		if (_AreaIsGroup) then {
		
			{
				_AreaObjects = _AreaObjects + [leader (missionNamespace getVariable [_x , grpnull])] ;
			} forEach _Areas;
		
		} else {
			{
				_AreaObjects = _AreaObjects + [missionNamespace getVariable [_x , objNull]];
			} forEach _Areas;
		};
		_ActiveAreas = [];
		if ((count _AreaTriggersObjs) == (count _Areas) ) then {
		// TRIGGERED AREAS
		{
			if (triggerActivated (_AreaTriggersObjs select _forEachIndex)) then {
				_ActiveAreas = _ActiveAreas + [_x];
			};
		} foreach _AreaObjects;
		} else {
			_ActiveAreas =_AreaObjects;
		};
	
	
	
	} else {

		_ActiveAreas = [];
		if ((count _AreaTriggersObjs) == (count _Areas) ) then {
		// TRIGGERED AREAS
		{
			if (triggerActivated (_AreaTriggersObjs select _forEachIndex)) then {
				_ActiveAreas = _ActiveAreas + [_x];
			};
		} foreach _Areas;
		} else {
			_ActiveAreas =_Areas;
		};

	}; 
	

	
	_currentTime = time;
	
	// FOREACH UNIT
	{
		
		if ((_x checkAIFeature "PATH") == false && !_StaticAI) then {continue;};
		if (_x getVariable "HBQ_IsForcedToMove") then {continue;};
		_Behaviour = behaviour _x;
		_UnitPos = getPos _x;
		_AreasWithUnit = [];
		if (_AreasAreObjects or _AreaIsGroup) then {
		_AreasWithUnit = _AreaObjects select {(_UnitPos distance2d _x)< _DistanceThreashold};
		} else {
		_AreasWithUnit = _Areas select {_UnitPos inArea _x};
		};
		
		
		///// IF UNIT NOT IN ANY ACTIVE AREA MOVE TO ACTIVE AREA
		if (( count _AreaTriggersObjs == 0) or (count _ActiveAreas > 0 && count _AreaTriggersObjs > 0)) then {
			//(count _AreasWithUnit) == 0 &&
			if (_group getVariable "HBQ_IsEngaging") then {continue};
			if (_group getVariable "HBQ_IsExecutingTask") then {continue};
			
			
			_ActiveArea = _ActiveAreas select 0;
			_ActiveTargetObj = _ActiveAreas select 0;
			
			/// AREAS ARE AREAS (MARKERS)
			if !(_AreasAreObjects or _AreaIsGroup) then {
			
				
				
				if (_MoveToLatestArea && count _AreaTriggersObjs > 0) then {
					//sleep _ChecksDelay; // WAIT So Triggertime function has time to set Q_AreaTriggerTime
					_TriggerTimes =[];
					{
						_TriggerTimes = _TriggerTimes + [_x getVariable ["HBQ_AreaTriggerTime",0]];
					} forEach _AreaTriggersObjs;
					

					_maxTriggerTime = selectMax _TriggerTimes;
					_ActiveArea = _Areas select (_TriggerTimes find _maxTriggerTime);
					if (_UnitPos inArea _ActiveArea) exitWith { _group setVariable ["HBQ_ReachedTargetPos", true,true]; continue};
					//_OldActiveArea =_ActiveArea;
					//_OldActiveArea == _ActiveArea && 
			
				} else {
					// Get nearest AREA
					{
						if((getmarkerpos _x) distance2d _UnitPos < (getmarkerpos _ActiveArea) distance2d _UnitPos) then
						{
							_ActiveArea = _x;
						};
					} forEach _ActiveAreas;
					if ( _UnitPos inArea _ActiveArea) exitWith {_group setVariable ["HBQ_ReachedTargetPos", true,true]; continue};
					//_OldActiveArea =_ActiveArea;
					//_OldActiveArea == _ActiveArea &&
				};
			

			_ActiveAreaPosition = (getMarkerPos [_ActiveArea, true]);


			} else {

			/// AREAS ARE OBJECTS
			if (_MoveToLatestArea && count _AreaTriggersObjs > 0) then {
					
					
					//sleep _ChecksDelay; // WAIT So Triggertime function has time to set Q_AreaTriggerTime
					_TriggerTimes =[];
					{
						_TriggerTimes = _TriggerTimes + [_x getVariable ["HBQ_AreaTriggerTime",0]];
					} forEach _AreaTriggersObjs;
					
					
					
					_maxTriggerTime = selectMax _TriggerTimes;
					_ActiveTargetObj = _AreaObjects select (_TriggerTimes find _maxTriggerTime);
					//if ((_UnitPos distance2d _ActiveTargetObj)< 20) then {systemchat "Is already close to object";continue};
					if ( ((_UnitPos distance2d _ActiveTargetObj)< _DistanceThreashold)) then {_group setVariable ["HBQ_ReachedTargetPos", true];continue;} else 
					{_group setVariable ["HBQ_ReachedTargetPos", false]};
					
					//if (_OldActiveAreaObj != _ActiveTargetObj) then {_group setVariable ["HBQ_ReachedTargetPos",false]};
					//_OldActiveAreaObj = _ActiveTargetObj;
					if ( _group getVariable ["HBQ_ReachedTargetPos", false]) exitWith {continue};
					
					//(_OldActiveAreaObj == _ActiveTargetObj) &&
			
				} else {
					// GET NEAREST TARGET OBJECT
					
					_ActiveTargetObj = _ActiveAreas select 0;
					if(count _ActiveAreas  > 0) then {
						{
							if(_x distance2d _UnitPos < (_ActiveTargetObj distance2d _UnitPos)) then
							{
								_ActiveTargetObj = _x;
							};
						} forEach _ActiveAreas;
					};

					if ((_UnitPos distance2d _ActiveTargetObj) < _DistanceThreashold) then {_group setVariable ["HBQ_ReachedTargetPos", true];continue;} else
					{_group setVariable ["HBQ_ReachedTargetPos", false]};
					
					//if (_OldActiveAreaObj != _ActiveTargetObj) then {_group setVariable ["HBQ_ReachedTargetPos",false]};
					//_OldActiveAreaObj =_ActiveTargetObj;
					if ( _group getVariable ["HBQ_ReachedTargetPos", false]) exitWith {continue};
					
					
				};
				
				
				if (isNull _ActiveTargetObj) exitWith {true};
				_ActiveAreaPosition = getPos _ActiveTargetObj;
				
			
			};
			
			// MOVEPOSITION
			private _TargetPosRandom =[];
			if (_AreasAreObjects) then {
				_TargetPosRandom = [[[_ActiveAreaPosition, ((_ActiveAreaPosition distance2d getPos (leader _group))/10)]], []] call BIS_fnc_randomPos; 
				if (_Spawntype == "INFANTRY") then {_TargetPosRandom = [[[_ActiveAreaPosition, ((_ActiveAreaPosition distance2d getPos (leader _group))/10)+30]], [[_ActiveAreaPosition, 20]]] call BIS_fnc_randomPos; };
				if (_Spawntype == "VEHICLES") then {_TargetPosRandom = [[[_ActiveAreaPosition, ((_ActiveAreaPosition distance2d getPos (leader _group))/10)+100]], [[_ActiveAreaPosition, 90]]] call BIS_fnc_randomPos; };
				if (_Spawntype == "AIRCARGOTRANSPORT") then {_TargetPosRandom = [[[_ActiveAreaPosition, ((_ActiveAreaPosition distance2d getPos (leader _group))/10)+30]], [[_ActiveAreaPosition, 20]]] call BIS_fnc_randomPos; };
				if (_Spawntype == "CARGOTRANSPORT") then {_TargetPosRandom = [[[_ActiveAreaPosition, ((_ActiveAreaPosition distance2d getPos (leader _group))/10)+30]], [[_ActiveAreaPosition, 20]]] call BIS_fnc_randomPos; };
			} else {
				_TargetPosRandom = [[[_ActiveAreaPosition, ((_ActiveAreaPosition distance2d getPos (leader _group))/3)]], []] call BIS_fnc_randomPos; 
			};
			
			// MOVE TO AREA
			[_x,_TargetPosRandom,_isCrew,_debug,_SpawnModule,_Behaviour,_ActiveArea,_ActiveTargetObj,_AreasAreObjects,_AreaIsGroup,_SpawnModule,_ChecksDelay,_SpawnType] spawn HBQSS_fnc_MoveToArea;
		};
	} forEach units _group;

};
