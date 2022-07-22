% Enumeration
YET = 0; xx = 1; yy = 2;

% Time
STIME = struct('start', 0, 'final', 10, 'ts', 0.05, 'cnt', 1,...
    'time', YET, 'ntime', YET);
STIME.time = STIME.start : STIME.ts : STIME.final;
STIME.ntime = length(STIME.time);

idx = 1;
% Unit Conversion
UNIT = struct('R2D', 180/pi, 'D2R', pi/180);
