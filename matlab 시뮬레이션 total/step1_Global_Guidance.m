clc; clear all; close all;

Setting();        % Enumeration % Time % Unit Conversion
SettingLocal();
CreateBuffer();
SetWaypoint();
CreateERP42();


while (ERP42.nwp <= nwp - 1 )
    GuidanceLaw();
   
    ChangeWaypoint();
    
    SaveBuffer();
    Plotting();
    STIME.cnt = STIME.cnt + 1;
    idx = idx + 1;
end

% Analysis();
% Compare_SIMvsHILS();