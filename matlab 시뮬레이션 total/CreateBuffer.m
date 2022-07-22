
%Buffer Enumeration
posx = 1; posy = 2;
posx_dot = 3; posy_dot = 4;
lambda = 7; gamma = 8; delta = 9; deltaf_out = 10; deltaf_cmd = 11;
r = 5; w = 6;

nbuffer = 14;

% Create Buffer
buf_ERP42 = zeros(nbuffer,STIME.ntime);
buf_WP = zeros(2,STIME.ntime);