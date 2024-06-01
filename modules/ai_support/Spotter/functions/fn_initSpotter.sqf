#include "script_component.hpp"
if (!isServer) exitWith {}; 

_this spawn { 
/*
params["_SpotterModule"];
private _SyncedGroups = [];
private _SyncedInfantry = [];
private _SyncedVehicles = [];
private _SyncedObjs = synchronizedObjects _SpotterModule;
_SyncedUnits = _SyncedObjs select {_x isKindOf "AllVehicles"};
{_SyncedGroups = _SyncedGroups + [group _x];} forEach _SyncedUnits;
*/
	params ["_x"];
	group _x setVariable ["HBQ_isSpotter",true,true];// PUBLIC 
	group _x setVariable ["HBQ_isSpotting",false,true];// PUBLIC 
	_leaderisPlayable = [(leader _x)] arrayIntersect playableUnits;
	if ((count _leaderisPlayable) != 0) then {
		
		
		/*[_x] spawn {
			//_leader = leader (_this select 0);
			waituntil {
				sleep 5;
				getPlayerUID _leader != ""
			};
			sleep 5;			
			[group _x] remoteExec  ["HBQSS_fnc_SpotterChecks", _leader];
		};
		*/

		[group _x] remoteExec  ["HBQSS_fnc_SpotterChecks", (leader _x)];
	
		
		// Respawn Eventhandler (So Player is still Spotter after respawn)
		//(leader _x) setVariable ["HBQ_SpotterModule",_SpotterModule,true];
		
		/*(leader _x) addEventHandler ["Respawn", {
		params ["_unit", "_corpse"];
		//private _SpotterModule = _unit getVariable ["HBQ_SpotterModule",objnull];
		
		[group _unit] spawn {
		_leader = leader (_this select 0);
		waituntil {
			sleep 5;
			getPlayerUID _leader != ""
		};
		sleep 5;			
		[group _leader,(_this select 1)] remoteExec  ["HBQSS_fnc_SpotterChecks", _leader];
		};

		}];
		*/
		
		
		
	} else {
		[group _x] remoteExec  ["HBQSS_fnc_SpotterChecks", (leader _x)];
	};
	
	
	



};

