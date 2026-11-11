#include "..\script_component.hpp"
/*
 * Author: Skitz
 * Format the current timestamp based on the user's settings.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ACE_map_fnc_formatTimestamp
 *
 * Public: No
 */

private _time = "";

// Handle timestamp
if ([ACE_player] call EFUNC(markers,canTimestamp)) then {
    // Determine marker timestamp based on time settings
    _time = switch ( EGVAR(markers,timestampTimezone)) do {
        case 1: {
            systemTime select [3]
        };
        case 2: {
            systemTimeUTC params ["", "", "", "_hour", "_min", "_sec", "_msec"];

            private _hourOffset = round  EGVAR(markers,timestampUTCOffset);
            _hour = _hour + _hourOffset;

            // Add or subtract minutes offset based on the negative or positive timezone
            if ( EGVAR(markers,timestampUTCMinutesOffset) != 0) then {
                _min = if (_hourOffset < 0) then { _min -  EGVAR(markers,timestampUTCMinutesOffset) } else { _min +  EGVAR(markers,timestampUTCMinutesOffset) };

                // Add/remove extra hours from minutes
                _hour = _hour + floor (_min / 60);
                _min = (_min % 60 + 60) % 60; // ensure that minutes are between 0 and 59 (included)
            };

            [(_hour % 24 + 24) % 24, _min, _sec, _msec] // ensure that hours are between 0 and 23 (included)
        };
        default {
            private _daytime = dayTime;

            private _hour = floor _daytime;
            private _min = floor ((_daytime - _hour) * 60);
            private _sec = floor ((((_daytime - _hour) * 60) - _min) * 60);
            private _msec = floor ((((((_daytime - _hour) * 60) - _min) * 60) - _sec) * 1000);

            [_hour, _min, _sec, _msec]
        };
    };

    _time params ["_hour", "_min", "_sec", "_msec"];

    // Add timestamp suffix
    private _periodPostfix = "";

    if ( EGVAR(markers,timestampHourFormat) == 12) then {
        if (_hour == 0) exitWith {
            _hour = _hour + 12;
            _periodPostfix = " am";
        };

        if (_hour == 12) exitWith {
            _periodPostfix = " pm";
        };

        if (_hour < 12) then {
            _periodPostfix = " am";
        } else {
            _hour = _hour - 12;
            _periodPostfix = " pm";
        };
    };

    private _format = switch ( EGVAR(markers,timestampFormat)) do {
        case "HH": {"[%1]"};
        case "HH:MM": {"[%1:%2]"};
        case "HH:MM:SS": {"[%1:%2:%3]"};
        case "HH:MM:SS:MM": { // milliseconds are displayed as 0 to 59
            _msec = [_msec * 60 / 1000, 2] call CBA_fnc_formatNumber;

            "[%1:%2:%3:%4]"
        };
        case "HH:MM:SS.mmm": { // milliseconds are displayed as 0 to 999
            _msec = [_msec, 3] call CBA_fnc_formatNumber;

            "[%1:%2:%3.%4]"
        };
    };

    _time = format [
        _format,
        [_hour, 2] call CBA_fnc_formatNumber,
        [_min, 2] call CBA_fnc_formatNumber,
        [_sec, 2] call CBA_fnc_formatNumber,
        _msec
    ];
};

_time;
