#include "script_component.hpp"
/*
 * Author: Skitz
 * Checks whether the given player can build a Rallypoint.
 *
 * Arguments:
 * 0: Player <OBJECT>
 *
 * Example:
 * [player] spawn ace_fortify_fnc_BuildRally
 *
 * Public: Yes
 */

// Parameter Init
params ["_unit"];

// Get Position
private _position = _unit getVariable ["SR_RallyPos", []];

if ((_position isEqualTo [0, 0, 0]) || (_position isEqualTo [])) exitWith {
    ["","RP: Placement cancelled"] spawn sr_support_fnc_infoMessage;
};

// Check enemies close
private _enemies = _position nearEntities [["CAManBase","Car","Tank"], ace_fortify_rallyDistance];
if (({!([side _x, playerSide] call BIS_fnc_sideIsFriendly)} count _enemies) > 0) exitWith {
    ["","RP: Enemies too close"] spawn sr_support_fnc_infoMessage;
};

// Create Rally (up to 3 attempts)
private _rally = objNull;
for "_i" from 1 to 3 do {
    // Create rally point, but ignore surrounding objects so that it can be placed even in tight spaces then disable simulation and damage
    _rally = createVehicle ["ACE_RallyPoint", _position, [], 0, "CAN_COLLIDE"];
    [_rally, false] remoteExec ["enableSimulationGlobal", 2];
    _rally allowDamage false;

    // If rally was successfully created, set its position and timestamp and exit loop
    if (!isNull _rally && alive _rally) exitWith {
        _rally setPos _position;
        _rally setVariable ["ace_fortify_CTIME",CBA_missionTime,true];
    };
};

// Wait for the server to create/process the rally then check if it exists
sleep 0.5;
if (isNull _rally || !alive _rally || !(_rally in ace_rally)) exitWith {
    ["","RP: Placement failed, no supplies or cooldown used"] spawn sr_support_fnc_infoMessage;
};

private _message = format ["RP: Rallypoint Created at %1", mapGridPosition _position];
["", _message] spawn sr_support_fnc_infoMessage;

// Update Supplies
ace_trenches_trenchSupplies = ace_trenches_trenchSupplies - ace_fortify_rallyCosts;
publicVariable "ace_trenches_trenchSupplies";

// Update Global Time Stamp
ace_lastRally = CBA_MissionTime;
publicVariable "ace_lastRally";

// Cleanup rally position
_unit setVariable ["SR_RallyPos", []];

// Condition and code for deletion
[{{!([side _x, playerSide] call BIS_fnc_sideIsFriendly)} count (_this nearEntities [["CAManBase","Car","Tank"],  ace_fortify_rallyDistance]) > 0}, {
    deleteVehicle _this;
}, _rally, ace_fortify_rallyTimer, {deleteVehicle _this;}] call CBA_fnc_waitUntilAndExecute;
