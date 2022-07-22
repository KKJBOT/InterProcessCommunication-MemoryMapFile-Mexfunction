clc; clear all; close all;

buf_ERP42_C = load('ERP_guidance.txt');

delta_c = 1; lambda_c = 2; gamma_c = 3; % [rad]
deltaf_c = 4; % [deg]
posx_c = 5; posy_c = 6;
posx_cmd_c = 7; posy_cmd_c = 8;

buf_ERP42_C = buf_ERP42_C';
UNIT = struct('R2D', 180/pi, 'D2R', pi/180);
% Plotting saved buffer
xmap_min = min(buf_ERP42_C(posx_c,:));
xmap_max = max(buf_ERP42_C(posx_cmd_c,:));
ymap_min = min(buf_ERP42_C(posy_c,:));
ymap_max = max(buf_ERP42_C(posy_cmd_c,:));

plot_time = 1:350;

figure,
subplot(3,1,1)
plot(plot_time, buf_ERP42_C(delta_c,plot_time)*UNIT.R2D, 'r', 'linewidth', 2); hold on;
legend('\delta');
xlabel('time [sec]'); ylabel('[\circ]');
grid on; grid minor;
title('guidance angle');

subplot(3,1,2)
plot(plot_time, buf_ERP42_C(lambda_c,plot_time)*UNIT.R2D, 'b', 'linewidth', 2);
legend('\lambda');
xlabel('time [sec]'); ylabel('[\circ]');
grid on; grid minor;

subplot(3,1,3)
plot(plot_time,buf_ERP42_C(gamma_c,plot_time) *UNIT.R2D, 'g', 'linewidth', 2);
legend('\gamma');
xlabel('time [sec]'); ylabel('[\circ]');
grid on; grid minor;


figure,
plot(plot_time, buf_ERP42_C(delta_c,plot_time)*UNIT.R2D, 'b', 'linewidth', 2); hold on;
plot(plot_time, buf_ERP42_C(deltaf_c,plot_time), 'r--', 'linewidth', 2); hold on;
xlabel('time [sec]'); ylabel('[\circ]');
legend('\delta','\deltaf');
grid on; grid minor;
title('Compare \delta vs \delta_f');

figure,
subplot(2,1,1)
plot(plot_time, buf_ERP42_C(posx_c, plot_time)); hold on;
plot(plot_time, buf_ERP42_C(posx_cmd_c,plot_time));
xlabel('time [sec]'); ylabel('[m]');
grid on; grid minor;
legend('pos x','pos x_{cmd}');
title('Guidance command and Result');

subplot(2,1,2)
plot(plot_time, buf_ERP42_C(posy_c, plot_time)); hold on;
plot(plot_time, buf_ERP42_C(posy_cmd_c,plot_time));
xlabel('time [sec]'); ylabel('[m]');
grid on; grid minor;
legend('pos y','pos y_{cmd}');

figure,
plot(buf_ERP42_C(posx_c, plot_time), buf_ERP42_C(posy_c, plot_time), 'r', 'linewidth', 2); hold on;
plot(buf_ERP42_C(posx_cmd_c,plot_time), buf_ERP42_C(posy_cmd_c,plot_time), 'g*', 'linewidth', 2);
xlabel('[m]'); ylabel('[m]');
grid on; grid minor;
legend('ackerman model trajectory','waypoint');


% Visualize ERP42
scale = 0.3;
init_body =  [ -1, -1,  -3,  -3,    -1,    -1,   -3,    -3,     -1,   -1,     2, -2, ;
    1.5, 0.5, 0.5, 1.5, 1.5,  -0.5, -0.5, -1.5, -1.5,  -0.5,   0,  0 ]*scale;
init_wheel = [1,    3,    3,      1,    1,     3,      1,     1,      3,     3, ;
    1.5,  1.5,  0.5,  0.5,  1.5,  -0.5,  -0.5, -1.5,  -1.5,  -0.5,]*scale;     % Visualization of vehicle
position_hils = [0 0];
body = init_body;
wheel = init_wheel;

figure,
for i = 1 : length(plot_time)
    % Rotate ERP42
    
    position_hils = [buf_ERP42_C(posx_c, i), buf_ERP42_C(posy_c, i)];
    Roate_body = [cos(buf_ERP42_C(gamma_c,i)),-sin(buf_ERP42_C(gamma_c,i)); sin(buf_ERP42_C(gamma_c,i)), cos(buf_ERP42_C(gamma_c,i))];
    Rotate_wheel = [cos(buf_ERP42_C(gamma_c,i) + buf_ERP42_C(deltaf_c,i)*UNIT.D2R),-sin(buf_ERP42_C(gamma_c,i) + buf_ERP42_C(deltaf_c,i)*UNIT.D2R) ; sin(buf_ERP42_C(gamma_c,i) + buf_ERP42_C(deltaf_c,i)*UNIT.D2R), cos(buf_ERP42_C(gamma_c,i) + buf_ERP42_C(deltaf_c,i)*UNIT.D2R)];
    
    body = position_hils(1,:)' + Roate_body*init_body;
    POS_wheel  = position_hils(1,:)' + Roate_body*init_body(:,end-1);
    wheel = POS_wheel + Rotate_wheel*(init_wheel - init_body(:,end-1));
    
    plot(buf_ERP42_C(posx_c, i), buf_ERP42_C(posy_c, i), 'r*', buf_ERP42_C(posx_cmd_c,i), buf_ERP42_C(posy_cmd_c,i), 'g*',...
        body (1,1:5), body (2,1:5),'b',body (1,6:end-2), body (2,6:end-2),'b', body (1,end-1:end), body (2,end-1:end),'b',...
        wheel(1,1:5), wheel(2,1:5),'r',wheel(1,6:end), wheel(2,6:end),'r');
    xlabel('[m]'); ylabel('[m]'); legend('ackerman model trajectory','waypoint');
    xlim([xmap_min-2 xmap_max+2]); ylim([ymap_min-2 ymap_max+2]);
    title('hils simulation drawnow');
    grid on; drawnow;
end
