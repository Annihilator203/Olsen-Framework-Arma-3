#include "script_component.hpp"

#include "..\..\Dia\Dia_Global.sqf"

private["_unit","_guns"];
_guns = _this;

if(!(player getVariable [VAR_SART_PLAYERRECEIVEDGUNS,false])) then
{
  _action = ["Artillery_Menu", "Artillery Menu", "", {true}, {(count (player getVariable [VAR_SART_OBSGUNS,[]])) > 0}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;


  _action = ["Artillery_Call_Menu", "Call Firemission", "", {true}, {true}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions","Artillery_Menu"], _action] call ace_interact_menu_fnc_addActionToObject;

  _action = ["PointFiremission", "Point Firemission", "", {[] call FNC_DIA_PointFiremissionOpenDialog;}, {true}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions","Artillery_Menu","Artillery_Call_Menu"], _action] call ace_interact_menu_fnc_addActionToObject;

  _action = ["LineFiremission", "Line Firemission", "", {[] call FNC_DIA_LineFiremissionOpenDialog;}, {true}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions","Artillery_Menu","Artillery_Call_Menu"], _action] call ace_interact_menu_fnc_addActionToObject;

  _action = ["BracketFiremission", "Bracket Firemission", "", {[] call FNC_DIA_BracketFiremissionOpenDialog;}, {true}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions","Artillery_Menu","Artillery_Call_Menu"], _action] call ace_interact_menu_fnc_addActionToObject;

  _action = ["DonutFiremission", "Donut Firemission", "", {[] call FNC_DIA_DonutFiremissionOpenDialog;}, {true}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions","Artillery_Menu","Artillery_Call_Menu"], _action] call ace_interact_menu_fnc_addActionToObject;

  _action = ["MarkerFiremission", "Marker Firemission", "", {[] call FNC_DIA_MarkerFiremissionOpenDialog;}, {true}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions","Artillery_Menu","Artillery_Call_Menu"], _action] call ace_interact_menu_fnc_addActionToObject;

  _action = ["PolarFiremission", "Polar Firemission", "", {[] call FNC_DIA_PolarFiremissionOpenDialog;}, {true}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions","Artillery_Menu","Artillery_Call_Menu"], _action] call ace_interact_menu_fnc_addActionToObject;

  _action = ["SpottingFiremission", "Call Spotting Round", "", {true}, {true}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions","Artillery_Menu"], _action] call ace_interact_menu_fnc_addActionToObject;


  _action = ["SpottingFiremission", "Polar Spotting Round", "", {[] call FNC_DIA_PolarSpottingFiremissionOpenDialog;}, {true}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions","Artillery_Menu","SpottingFiremission"], _action] call ace_interact_menu_fnc_addActionToObject;

  _action = ["SpottingFiremission", "Grid Spotting Round", "", {[] call FNC_DIA_GridSpottingFiremissionOpenDialog;}, {true}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions","Artillery_Menu","SpottingFiremission"], _action] call ace_interact_menu_fnc_addActionToObject;

  _action = ["FiremissionInformation", "Firemission Information", "", {true}, {true}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions","Artillery_Menu"], _action] call ace_interact_menu_fnc_addActionToObject;

  _action = ["StopFiremission", "Stop Firemissions", "", {true}, {true}] call ace_interact_menu_fnc_createAction;
  [player, 1, ["ACE_SelfActions","Artillery_Menu"], _action] call ace_interact_menu_fnc_addActionToObject;
  {
    _artyName =_x call FNC_GetArtyDisplayName;
    _text = ("Stop " + _artyName);
    _action = ["Stop",_text , "", {(_this select 2) call FUNC(FIREMIS_StopArtilleryClient); }, {!(( _this select 2) call FNC_IsArtyAviable)},{},_x] call ace_interact_menu_fnc_createAction;
    [player, 1, ["ACE_SelfActions","Artillery_Menu","StopFiremission"], _action] call ace_interact_menu_fnc_addActionToObject;
  }forEach _guns;

  {
    _artyName =_x call FNC_GetArtyDisplayName;
    _text = ("Info " + _artyName);
    _action = ["Info",_text , "",{hint ((_this select 2) call FNC_GetCompleteInfoText); }, { !((_this select 2) call FNC_IsArtyAviable)},{},_x] call ace_interact_menu_fnc_createAction;
    [player, 1, ["ACE_SelfActions","Artillery_Menu","FiremissionInformation"], _action] call ace_interact_menu_fnc_addActionToObject;
  }forEach _guns;

  _id = ["Event_ArtyIsReady",
  {
    [PFM_DIA_IDC_GUNSELECT] call FNC_ArtLoadAviableArtilleries;
    [LFM_DIA_IDC_GUNSELECT] call FNC_ArtLoadAviableArtilleries;
    [BFM_DIA_IDC_GUNSELECT] call FNC_ArtLoadAviableArtilleries;
    [DFM_DIA_IDC_GUNSELECT] call FNC_ArtLoadAviableArtilleries;
    [MFM_DIA_IDC_GUNSELECT] call FNC_ArtLoadAviableArtilleries;
    [PSFM_DIA_IDC_GUNSELECT] call FNC_ArtLoadAviableArtilleries;
    [GSFM_DIA_IDC_GUNSELECT] call FNC_ArtLoadAviableArtilleries;
  }] call CBA_fnc_addEventHandler;
  player setVariable [VAR_SART_PLAYERRECEIVEDGUNS,true,true];
};
