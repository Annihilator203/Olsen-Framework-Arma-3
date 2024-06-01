params ["_obj","_startPos", "_endPos", "_distance", "_step"];

fnc_lerp3D = {
    private ["_start", "_end", "_t", "_result"];
    
    _start = _this select 0;
    _end = _this select 1;
    _t = _this select 2;
    
    _result = [
        (_start select 0) + ((_end select 0) - (_start select 0)) * _t,
        (_start select 1) + ((_end select 1) - (_start select 1)) * _t,
        (_start select 2) + ((_end select 2) - (_start select 2)) * _t
    ];
    _result
};


// Schleife für die Animation

sleep 0.5;
for [{_i = 0}, {_i <= 1}, {_i = _i + _step}] do {
    _currentPos = [_startPos, _endPos, _i] call fnc_lerp3D; // Verwenden Sie die selbst geschriebene Lerp-Funktion für die Animation
    // Hier können Sie die aktuelle Position verwenden, um den Punkt in der 3D-Welt zu zeichnen oder ihn anderweitig zu verwenden
	_obj setposASL _currentPos;
    sleep 0.02; // Kurze Verzögerung für die Animation
};


