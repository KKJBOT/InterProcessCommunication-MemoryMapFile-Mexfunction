%%%% Setting Local path planning %%%%
obs_deg      = 0: deg2rad(5): deg2rad(360);
obs_x        = cos(obs_deg);
obs_y        = sin(obs_deg);

obs_pos_ini  = [10; 0];    % obstacle's position
obs_range    = 2.0;
obstacle     = [obs_range*obs_x; obs_range*obs_y];
obstacle_ini = obstacle+obs_pos_ini;

%%% Local Guidance parameter
sigma_Local = 0.3;
e_Local     = 0.05;
r_max_Local = 3; %[m]
%%% LIDAR RESOLUTION

deg_obs = 0:0.25:180;

psi = deg2rad(-90):deg2rad(0.25):deg2rad(90);
Fp  = zeros(1,length(deg_obs))+r_max_Local;
