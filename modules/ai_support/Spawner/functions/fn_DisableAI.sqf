#include "script_component.hpp"
// Disable all AI and Simulation Features for more performant Spawning
params ["_unit"];
	_unit hideObjectGlobal true;
	_unit enableSimulationGlobal false;
	_unit disableAI "ALL";
	_unit disableConversation true;
	_unit setVariable ["lambs_danger_disableAI", true];
	_unit setVariable ["SFSM_excluded", true];
	(group _unit) setVariable ["Vcm_Disable",true]; 
	(group _unit) setVariable ["lambs_danger_disableGroupAI",true];
	(group _unit) setVariable ["TCL_Disabled", true];