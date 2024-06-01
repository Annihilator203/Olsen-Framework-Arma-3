params ["_trigger","_ChecksDelay","_group"];

_trigger setVariable ["HBQ_AreaTriggerTime", 0,true];// PUBLIC ??

While {
if (isNull _group) exitwith {true};
count units _group > 0

} do {

waituntil {
//sleep (_ChecksDelay*0.7);
sleep 0.1;
if (isNull _group) exitwith {true};
triggerActivated _trigger
};

_trigger setVariable ["HBQ_AreaTriggerTime", time,true]; // PUBLIC ??
sleep _ChecksDelay;

};