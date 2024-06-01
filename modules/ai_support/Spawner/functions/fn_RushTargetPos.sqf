params["_unit","_Stance"];
// DISABLE AI FEATURES (Add Eventhandler to turn AI on when Fired at)
(group _unit) setVariable ["HBQ_RushTargetPosition", true];
waitUntil {
	sleep 0.1;
	(_unit getVariable ["HBQ_SpwnFin",false]) == true
};

(group _unit) setVariable ["lambs_danger_disableGroupAI",true];
_unit setVariable ["lambs_danger_disableAI", true];
_unit setVariable ["SFSM_excluded", true];
_unit disableAI "AutoTarget";
_unit disableAI "Target";
_unit disableAI "AutoCombat";

_unit setUnitPos "UP";
_unit addEventHandler ["Suppressed", {
			params ["_unit", "_distance", "_shooter", "_instigator", "_ammoObject", "_ammoClassName", "_ammoConfig"];
			private _Threshold = (group _unit) getVariable "HBQ_suppressionThreshold";
			if (getSuppression _unit > _Threshold) then {
			
			{

				_x enableAI "AutoTarget";
				_x enableAI "Target";
				_x enableAI "AutoCombat";
				_x setVariable ["SFSM_excluded", not ((group _x) getVariable "HBQ_DCO_SFSM")];
				_x setVariable ["lambs_danger_disableAI", not ((group _x) getVariable "HBQ_Lambs")];
				
			} foreach units (group _unit);
			(group _unit) setVariable ["HBQ_RushTargetPosition", false];
			(group _unit) setVariable ["lambs_danger_disableGroupAI",not ((group _unit) getVariable "HBQ_Lambs")];
			_unit setUnitPos "AUTO";
			_unit removeEventHandler [_thisEvent, _thisEventHandler];
			};
		}];