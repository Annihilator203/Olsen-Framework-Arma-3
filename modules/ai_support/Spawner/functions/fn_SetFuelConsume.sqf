params ["_vehicle","_ConsumeRate"];
private _ConsumeRateConverted = linearconversion [0,1,_ConsumeRate,0,0.02,true];
while {(alive _vehicle)} do { 
	if (isengineon _vehicle and fuel _vehicle > 0) then {
	_vehicle setFuel ( Fuel _vehicle - _ConsumeRateConverted);
	};
	sleep 10; //Set Sleep higher for slower Fuel Consumption
};