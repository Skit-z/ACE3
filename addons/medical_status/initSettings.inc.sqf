[
    QEGVAR(medical,bleedingCoefficient),
    "SLIDER",
    [LSTRING(BleedingCoefficient_DisplayName), LSTRING(BleedingCoefficient_Description)],
    [ELSTRING(medical,Category), LSTRING(SubCategory)],
    [0, 25, 1, 1],
    true
] call CBA_fnc_addSetting;

[
    QEGVAR(medical,painCoefficient),
    "SLIDER",
    [LSTRING(PainCoefficient_DisplayName), LSTRING(PainCoefficient_Description)],
    [ELSTRING(medical,Category), LSTRING(SubCategory)],
    [0, 25, 1, 1],
    true
] call CBA_fnc_addSetting;

[
    QEGVAR(medical,ivFlowRate),
    "SLIDER",
    [LSTRING(IvFlowRate_DisplayName), LSTRING(IvFlowRate_Description)],
    [ELSTRING(medical,Category), LSTRING(SubCategory)],
    [0, 25, 1, 1],
    true
] call CBA_fnc_addSetting;

[
    QEGVAR(medical,dropWeaponUnconsciousChance),
    "SLIDER",
    [LSTRING(DropWeaponUnconsciousChance_DisplayName), LSTRING(DropWeaponUnconsciousChance_Description)],
    ELSTRING(medical,Category),
    [0, 1, 0, 2, true],
    true
] call CBA_fnc_addSetting;


[
    "ACE_UnconsciousTimer",
    "SLIDER",
    ["Unconcious Timer", "Time after which unconcious gets into cardiac arrest"],
    [ELSTRING(medical,Category), "Modifications"],
    [-1, 1200, 180, 0],
    true
] call CBA_settings_fnc_init;

[
    "ACE_OverdoseCooldown",
    "SLIDER",
    ["Overdose Cooldown", "Time after which dosage down not count towards overdose"],
    [ELSTRING(medical,Category), "Modifications"],
    [-1, 600, 120, 0],
    true
] call CBA_settings_fnc_init;

[
    QGVAR(customDiagnose),
    "CHECKBOX",
    ["Custom Diagnosis", "Custom output on check blood pressure"],
    [ELSTRING(medical,Category), "Modifications"],
    true,
    true
] call CBA_settings_fnc_init;