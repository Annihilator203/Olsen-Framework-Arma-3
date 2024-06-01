#include "script_component.hpp"
params ["_markerposition", "_Markerlabel","_MarkerShape","_MarkerType","_MarkerSize","_Lifetime","_MarkerColor","_Opacity","_Direction","_BrushArea","_DrawCone"];

private _markerName = str random 99999999;
private _marker = createMarker [_markerName, _markerposition]; // not visible yet.
_marker setMarkerShape _MarkerShape;
_marker setMarkerSize _MarkerSize;
_marker setMarkerText _Markerlabel;
_marker setMarkerColor _MarkerColor;
_marker setMarkerType _MarkerType; // Visible.
_marker setMarkerAlpha _Opacity;
_marker setMarkerBrush _BrushArea;

// Draw Automatic Spawnpositions-Cone 
if (_MarkerShape == "POLYLINE" and _DrawCone) then {
	_x1=(_markerposition select 0);
	_y1=(_markerposition select 1);
	_markerPosX = _markerposition select 0;
	_markerPosY = _markerposition select 1;
	private _PolylineVector = [0, (_MarkerSize select 0)]; // North
	_InvertedDirection = 360-_Direction;
	private _xlen =  _markerPosX +(sin _Direction) *(_MarkerSize select 0);
	private _ylen = _markerPosY +(cos _Direction) *(_MarkerSize select 0);

	// Determine quadrant and special cases
	if ((_Direction > 0) && (_Direction < 90)) then {_PolylineVector = [_markerPosX + _xlen, _markerPosY + _ylen]};
	if ((_Direction > 90) && (_Direction < 180)) then {_PolylineVector = [_markerPosX + _xlen, _markerPosY - _ylen]};
	if ((_Direction > 180) && (_Direction < 270)) then {_PolylineVector = [_markerPosX - _xlen, _markerPosY - _ylen]};
	if ((_Direction > 270) && (_Direction < 360)) then {_PolylineVector = [_markerPosX - _xlen, _markerPosY + _ylen]};
	if (_Direction == 90) then {_PolylineVector = [(_MarkerSize select 0), 0]}; //EAST
	if (_Direction == 180) then {_PolylineVector = [0, -(_MarkerSize select 0)]};// SOUTH
	if (_Direction == 270) then {_PolylineVector = [-(_MarkerSize select 0), 0]}; //WEST
	_marker setMarkerPolyline [_x1,_y1,_xlen,_ylen];
};

if (_Lifetime != -1) then {
	sleep _Lifetime;
	deleteMarker _marker;
};