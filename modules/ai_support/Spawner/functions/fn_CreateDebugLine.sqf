#include "script_component.hpp"
params ["_markerposition","_MarkerSize","_Lifetime","_MarkerColor","_Opacity","_LinePos1","_LinePos2"];
private _markerName = str random 99999999;
private _marker = createMarker [_markerName, _markerposition];
_marker setMarkerShape "POLYLINE";
_marker setMarkerPolyline [_LinePos1 select 0,_LinePos1 select 1,_LinePos2 select 0,_LinePos2 select 1];
_marker setMarkerSize _MarkerSize;
_marker setMarkerColor _MarkerColor;
_marker setMarkerAlpha _Opacity;
sleep _Lifetime;
deleteMarker _marker;