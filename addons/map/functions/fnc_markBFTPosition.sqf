#include "..\script_component.hpp"
/*
 * Author: Skitz
 * Check if the unit has a GPS, DAGR, or similar device.
 *
 * Arguments:
 * unit (object)
 * markFireteam (bool) - Whether to mark the fireteam position instead of the group position.
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player] call ACE_map_fnc_hasGPS
 *
 * Public: No
 */

params ["_player",["_markFireteam", false]];

// Hint Msg to Click on Map
openMap true;
["", "Click on Map to Designate Your Position"] spawn sr_support_fnc_infoMessage;

// Get clicked position
_clickEH = addMissionEventHandler ["MapSingleClick", {
    params ["_units", "_pos", "_alt", "_shift"];
    
    // parse _thisArgs
    _player = _thisArgs select 0;
    _markFireteam = _thisArgs select 1;

    // Initialize checking variables
    private _clickPos = [0, 0, 0];
    private _done = false;

    _clickPos = _pos;
    _distance = _clickPos distance2d getPosATL(_player);
    _done = true;

    if (_done) then {
        // Stop listening for map clicks - without this, the handler keeps firing on
        // every future map click for the rest of the mission.
        removeMissionEventHandler ["MapSingleClick", _thisEventHandler];

        // Hand the result back to fnc_createManualBFTMarker
        if !(_clickPos isEqualTo [0, 0, 0]) then {
            _player setVariable ["BFT_ClickedPosition", _clickPos];
            [_player, _markFireteam, _clickPos] call ace_map_fnc_createManualBFTMarker;
        };
    };
}, [_player, _markFireteam]];

_mapEH = addMissionEventHandler ["Map", {
        params ["_mapIsOpened", "_mapIsForced"];
        
        // parse _thisArgs
        _clickEH = _thisArgs select 0;

    if !(_mapIsOpened) then {
        // Stop listening for map clicks - without this, the handler keeps firing on
        // every future map click for the rest of the mission.
        removeMissionEventHandler ["MapSingleClick", _clickEH];
        removeMissionEventHandler ["Map", _thisEventHandler];
    };
}, [_clickEH]]; 
