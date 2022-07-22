% Set Waypoint
% Waypoint generation

waypoint = [];
x = [5.0 15.0  20.0 20.0 20.0];           % [m]
y = [0.0   0.0  10.0 20.0 30.0];        % [m]

waypoint(:,1) = x;
waypoint(:,2) = y;
nwp = length(waypoint); % [cnt] 
minDist = 1; %[m] 