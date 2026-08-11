#include "script_component.hpp"
/*
 * Author: Skitz
 * Opens the map, shows a prohibited (exclusion) area around the player, and
 * blocks until the player clicks a valid position outside that area, or
 * cancels by closing the map.
 *
 * Arguments:
 * 0: Player <OBJECT>
 *
 * Return Value:
 * None directly - result is written to _player's "SR_RallyPos" variable:
 *   [x,y,z]  - valid position the player picked
 *   []       - player cancelled (closed the map without clicking)
 * Stored on the unit rather than missionNamespace so two players placing a
 * rally at the same time can't overwrite each other's result.
 *
 * Example:
 * [player] spawn FUNC(getRallyPos)
 *
 * Public: No
 */

params ["_player"];
private _cooldown = CBA_MissionTime - ace_lastRally;

// Check cooldown
if(ace_lastRally > 0 && _cooldown < ace_fortify_rallyCooldown) exitWith {
	["",("RP: Cooldown " + str((round (_cooldown - ace_fortify_rallyCooldown)*-1)) + "s")] spawn sr_support_fnc_infoMessage;
};

// Check and update resources
private _remain = ace_trenches_trenchSupplies - ace_fortify_rallyCosts;
if (_remain < 0) exitWith {
    ["","RP: Not enough Resources"] spawn sr_support_fnc_infoMessage;
}; 

// Check friendly close
private _friendlies = _player nearEntities [["CAManBase","Car","Tank"], 5];
if (({([side _x, playerSide] call BIS_fnc_sideIsFriendly)} count _friendlies) < 2) exitWith {
    ["","RP: No Friendlies nearby"] spawn sr_support_fnc_infoMessage;
};

// Get minimum distance
private _exclusionRadius = ace_fortify_minRallyDistance;
if (_exclusionRadius >= 50) then {

    // Hint Msg to Click on Map
    openMap true;
    private _message = format ["Click on Map to Designate Rallypoint (Min: %1m away) Close Map to Cancel", _exclusionRadius];
    ["", _message] spawn sr_support_fnc_infoMessage;

    // Create Prohibited Area Marker
    private _prohibitedArea = createMarkerLocal [format ["rally_exclusion_%1", netId _player], position _player];
    _prohibitedArea setMarkerShapeLocal "ELLIPSE";
    _prohibitedArea setMarkerColorLocal "ColorPink";
    _prohibitedArea setMarkerAlphaLocal 0.34;
    _prohibitedArea setMarkerSizeLocal [_exclusionRadius, _exclusionRadius];
    _prohibitedArea setMarkerBrushLocal "SolidBorder";

    _clickEH = addMissionEventHandler ["MapSingleClick", {
        params ["_units", "_pos", "_alt", "_shift"];
        
        // parse _thisArgs
        _exclusionRadius = _thisArgs select 0;
        _player = _thisArgs select 1;
        _marker = _thisArgs select 2;

        // Initialize checking variables
        private _clickPos = [0, 0, 0];
        private _done = false;

        _clickPos = _pos;
        _distance = _clickPos distance2d getPosATL(_player);

        // Check if the Rally is too close to the caller
        if ((_distance >= _exclusionRadius) && !(_clickPos isEqualTo [0, 0, 0])) then {
            _done = true;
        } else {
            ["", "RP: Too close to your position"] spawn sr_support_fnc_infoMessage;
            _clickPos = [0, 0, 0];
            _done = false;
        };

        // Check if the Rally is within the AO or there is no AO
        if ((_clickPos inArea "bis_fnc_moduleCoverMap_border") || (markerShape "bis_fnc_moduleCoverMap_border") == "") then {
            _done = true;
        } else {
            ["", "RP: Cannot create rally outside AO"] spawn sr_support_fnc_infoMessage;
            _clickPos = [0, 0, 0];
            _done = false;
        };

        if (_done) then {
            // Stop listening for map clicks - without this, the handler keeps firing on
            // every future map click for the rest of the mission.
            removeMissionEventHandler ["MapSingleClick", _thisEventHandler];

            // Clean up area marker
            deleteMarker _marker;

            // Hand the result back to fnc_buildRally
            if !(_clickPos isEqualTo [0, 0, 0]) then {
                _player setVariable ["SR_RallyPos", _clickPos];
                [_player] spawn ace_fortify_fnc_BuildRally;
            };
        };
    }, [_exclusionRadius, _player, _prohibitedArea]];

    _mapEH = addMissionEventHandler ["Map", {
        params ["_mapIsOpened", "_mapIsForced"];
        
        // parse _thisArgs
        _clickEH = _thisArgs select 0;
        _marker = _thisArgs select 1;

        if !(_mapIsOpened) then {
            // Stop listening for map clicks - without this, the handler keeps firing on
            // every future map click for the rest of the mission.
            removeMissionEventHandler ["MapSingleClick", _clickEH];

            // Clean up area marker
            deleteMarker _marker;
        };
    }, [_clickEH, _prohibitedArea]]; 

// If we're under 50m, just spawn on the player
} else {

    // Progress Bar
    [2, [_player], {
    
        // Parameter Init
        params ["_args","_elapsedTime","_totalTime","_errorCode"];
        _args params ["_unit","_remain"];

        // Hand the result back to fnc_buildRally
        _player setVariable ["SR_RallyPos", (_player getPos [0.5, direction _player])];
        [_player] spawn ace_fortify_fnc_BuildRally;

    }, "Placing Rallypoint"] call ace_common_fnc_progressBar;
};
