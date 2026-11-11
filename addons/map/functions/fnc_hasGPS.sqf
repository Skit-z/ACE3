#include "..\script_component.hpp"
/*
 * Author: Skitz
 * Check if the unit has a GPS, DAGR, or similar device.
 *
 * Arguments:
 * unit (object)
 *
 * Return Value:
 * Boolean
 *
 * Example:
 * [player] call ACE_map_fnc_hasGPS
 *
 * Public: No
 */

params ["_unit"];

private _hasGPS = false;
{
    private _itemClass = _x;

    if (_itemClass in ["ACE_DAGR","ACE_microDAGR"]) exitWith {_hasGPS = true;};
    private _types = [_itemClass] call EFUNC(common,getItemType);

    if ("gps" in _types) exitWith {_hasGPS = true;};
    if ("uav_terminal" in _types) exitWith {_hasGPS = true;};

} forEach (items _unit + assignedItems _unit);

_hasGPS;
