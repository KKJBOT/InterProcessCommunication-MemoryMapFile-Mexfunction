%CreateERP42

% Initial Value
initpos = [0, 0]; %[m m]
velocity =2; %[m/s]
initnwp = 1; %[cnt]

% ERP42 
ERP42 = struct(...
    'pos', initpos, 'pos_dot', [0 0], 'err_pos', 0,... %[m m] [m/s m/s] [m m]
    'v', velocity, 'w', 0, 'actv', 0, 'actdf', 0,... %[m/s] [rad/s]
    'If', 0.5, 'Ir', 0.5,...% Length of Vehicle  Front[m]  Rear[m]
    'r', YET, 'lambda', YET, 'gamma', 0, 'delta', 0, 'deltaf', 0,... % [m] [rad] [rad] [rad]
    'max_ang', 28*UNIT.D2R, 'nwp', initnwp ); % [deg] [cnt]

Kgain = 6; %[-]
initangle = 0; %[deg]

ERP42.r = norm(ERP42.pos(1,:)' - waypoint(initnwp,:)', 2);
ERP42.lambda = atan2( (waypoint(initnwp, yy) - ERP42.pos(yy)), (waypoint(initnwp, xx) - ERP42.pos(xx)) );
ERP42.gamma = initangle*UNIT.D2R;
ERP42.delta = ERP42.gamma - ERP42.lambda;

% Visualize ERP42
scale = 0.3;
init_body =  [ -1, -1,  -3,  -3,    -1,    -1,   -3,    -3,     -1,   -1,     2, -2, ;
                    1.5, 0.5, 0.5, 1.5, 1.5,  -0.5, -0.5, -1.5, -1.5,  -0.5,   0,  0 ]*scale;
init_wheel = [1,    3,    3,      1,    1,     3,      1,     1,      3,     3, ;
                  1.5,  1.5,  0.5,  0.5,  1.5,  -0.5,  -0.5, -1.5,  -1.5,  -0.5,]*scale;     % Visualization of vehicle 

ERP42.body  = init_body;
ERP42.wheel = init_wheel;
% figure, plot(ERP42.body (1,:), ERP42.body (2,:),'b*',ERP42.wheel(1,:), ERP42.wheel(2,:),'r*') ;
% figure, plot(ERP42.wheel(1,1:4), ERP42.wheel(2,1:4),'r*',ERP42.wheel(1,5:end), ERP42.wheel(2,5:end),'b*') ;
% figure, plot(ERP42.body (1,1:5), ERP42.body (2,1:5),'b',ERP42.body(1,6:end-2), ERP42.body(2,6:end-2),'r') ;

% ERP42 motor spec
Ta = 0.1;
Tb = 0.2;
tf_motor_veloc = tf([1],[Ta 1]);
tf_motor_steer = tf([1],[Tb 1]);
% figure, step(tf_motor_veloc); hold on; step(tf_motor_steer); hold off;
% legend('velocity','steer');

% Navigation Filter and AHRS covariance
sigAHRS = 0.01; %[deg]
sigNav   = 0.05*scale; %[m]
