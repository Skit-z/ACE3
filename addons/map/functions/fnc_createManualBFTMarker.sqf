#include "..\script_component.hpp"
/*
 * Author: Skitz
 * Creates a manual Blue Force Tracking (BFT) marker on the map for the specified group or fireteam leader.
 *
 * Arguments:
 * unit (object)
 * markFireteam (bool) - Whether to mark the fireteam position instead of the group position.
 * clickPos (array) - The position to mark on the map.
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player, true, getPosATL player] call ACE_map_fnc_createManualBFTMarker
 *
 * Public: No
 */
params ["_player","_markFireteam","_clickPos"];

// Get existing fireteam and group markers for the player
private _playerFireteamMarkers = _player getVariable ["ACE_FireTeamMarker", []];
private _groupBFTMarkers = (group _player) getVariable ["ACE_GroupMarker", []];
private _timestamp = [] call FUNC(formatTimestamp);

if ((_clickPos isEqualTo [0, 0, 0]) || (_clickPos isEqualTo [])) exitWith {
    ["","Position Marking Cancelled"] spawn sr_support_fnc_infoMessage;
};

if (_markFireteam) then {
    // Delete existing BFT markers for the fireteam
    {
        deleteMarker _x;
    } forEach _playerFireteamMarkers;
    _playerFireteamMarkers = [];

    // Check if FTL and select Marker Details
    _markerDetail = [];
    switch (_player getVariable ["ACE_FTL",""]) do {
        case "RED": {_markerDetail = ["SR_Marker_FTL","SRColorRed",false]};
        case "BLUE": {_markerDetail = ["SR_Marker_FTL","SRColorBlue",false]};
        case "GREEN": {_markerDetail = ["SR_Marker_FTL","SRColorGreen",false]};
        case "YELLOW": {_markerDetail = ["SR_Marker_FTL","SRColorGold",false]};
    };
    // Draw FTL Marker
    if (count _markerDetail > 0) then {
        private _markerLocal = createMarkerLocal [format ["ACE_BFT_FTL_LOCAL_%1", _player], [_clickPos select 0, _clickPos select 1], 1];
        _markerLocal setMarkerTypeLocal (_markerDetail select 0);
        _markerLocal setMarkerColorLocal (_markerDetail select 1);
        // Set Marker Timestamp
        _markerLocal setMarkerTextLocal format ["%1", _timestamp];
        _playerFireteamMarkers pushBack _markerLocal;

        private _markerShared = createMarkerLocal [format ["ACE_BFT_FTL_SHARED_%1", _player], [_clickPos select 0, _clickPos select 1], 3];
        _markerShared setMarkerTypeLocal (_markerDetail select 0);
        _markerShared setMarkerColorLocal (_markerDetail select 1);
        // Set Marker Timestamp
        _markerShared setMarkerText format ["%1", _timestamp];
        _playerFireteamMarkers pushBack _markerShared;
    };

    // Store the fireteam markers for the player
    _player setVariable ["ACE_FireTeamMarker", _playerFireteamMarkers];
} else {
    // Delete existing BFT markers for the group
    {
        deleteMarker _x;
    } forEach _groupBFTMarkers;
    _groupBFTMarkers = [];

    _markerDetail = switch (groupId (group _player)) do {
        case "HQ": {["SR_Marker_HQ","SRColorGold",false]};
        case "PL": {["SR_Marker_PL1","SRColorGold",false]};
        case "PL-1": {["SR_Marker_PL1","SRColorGold",false]};
        case "PL-2": {["SR_Marker_PL2","SRColorGold",false]};
        case "A": {["SR_Marker_A1","SRColorGreen",false]};
        case "A-1": {["SR_Marker_A1","SRColorGreen",false]};
        case "A-2": {["SR_Marker_A2","SRColorGreen",false]};
        case "B": {["SR_Marker_B1","SRColorBrown",false]};
        case "B-1": {["SR_Marker_B1","SRColorBrown",false]};
        case "B-2": {["SR_Marker_B2","SRColorBrown",false]};				
        case "C": {["SR_Marker_C1","SRColorPurple",false]};
        case "C-1": {["SR_Marker_C1","SRColorPurple",false]};
        case "C-2": {["SR_Marker_C2","SRColorPurple",false]};
        case "D": {["SR_Marker_D1","SRColorBlack",false]};
        case "D-1": {["SR_Marker_D1","SRColorBlack",false]};
        case "D-2": {["SR_Marker_D2","SRColorBlack",false]};			
        case "S": {["SR_Marker_S1","SRColorBlue",false]};
        case "S-1": {["SR_Marker_S1","SRColorBlue",false]};
        case "S-2": {["SR_Marker_S2","SRColorBlue",false]};		
        case "R": {["SR_Marker_R1","SRColorBlue",false]};
        case "R-1": {["SR_Marker_R1","SRColorBlue",false]};
        case "R-2": {["SR_Marker_R2","SRColorBlue",false]};
        case "R-3": {["SR_Marker_R3","SRColorBlue",false]};	
        case "R-4": {["SR_Marker_R4","SRColorBlue",false]};	
        case "RPR": {["SR_Marker_R1","SRColorRed",false]};	
        case "RPR-1": {["SR_Marker_R1","SRColorRed",false]};	
        case "RPR-2": {["SR_Marker_R2","SRColorRed",false]};	
        case "RPR-3": {["SR_Marker_R3","SRColorRed",false]};	
        case "RPR-4": {["SR_Marker_R4","SRColorRed",false]};	
        case "F": {["SR_Marker_F1","SRColorBlue",false]};
        case "F-1": {["SR_Marker_F1","SRColorBlue",false]};
        case "F-2": {["SR_Marker_F2","SRColorBlue",false]};		
        case "F-3": {["SR_Marker_F3","SRColorBlue",false]};		
        case "F-4": {["SR_Marker_F4","SRColorBlue",false]};		
        case "M": {["SR_Marker_M1","SRColorBlue",false]};		
        case "M-1": {["SR_Marker_M1","SRColorBlue",false]};		
        case "M-2": {["SR_Marker_M2","SRColorBlue",false]};		
        case "M-3": {["SR_Marker_M3","SRColorBlue",false]};		
        case "M-4": {["SR_Marker_M4","SRColorBlue",false]};		
        case "E": {["SR_Marker_E1","SRColorBlue",false]};
        case "E-1": {["SR_Marker_E1","SRColorBlue",false]};
        case "E-2": {["SR_Marker_E2","SRColorBlue",false]};	
        case "L": {["SR_Marker_L1","SRColorBlue",false]};	
        case "L-1": {["SR_Marker_L1","SRColorBlue",false]};	
        case "L-2": {["SR_Marker_L2","SRColorBlue",false]};	
        case "H-1": {["SR_Marker_H1","SRColorBlue",false]};	
        case "H-2": {["SR_Marker_H2","SRColorBlue",false]};	
        case "H-3": {["SR_Marker_H3","SRColorBlue",false]};	
        case "H-4": {["SR_Marker_H4","SRColorBlue",false]};	
        case "W-1": {["SR_Marker_W1","SRColorBlue",false]};	
        case "W-2": {["SR_Marker_W2","SRColorBlue",false]};	
        case "W-3": {["SR_Marker_W3","SRColorBlue",false]};	
        case "W-4": {["SR_Marker_W4","SRColorBlue",false]};	
        default {[[_player] call EFUNC(common,getMarkerType),"SRColorBlue",true]}; 
    };

    private _marker = createMarkerLocal [format ["ACE_BFT_%1", groupId (group _player)], [_clickPos select 0, _clickPos select 1], 1];
    _marker setMarkerTypeLocal (_markerDetail select 0);
    if (_markerDetail select 2) then {
        _timestamp = format ["%1 %2", groupID (group _player), _timestamp];
    };
    _marker setMarkerColorLocal (_markerDetail select 1);
    // Set Marker Timestamp
    _marker setMarkerText _timestamp;
    _groupBFTMarkers pushBack _marker;
    (group _player) setVariable ["ACE_GroupMarker", _groupBFTMarkers];
};
