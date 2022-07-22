% Plotting saved buffer
buf_ERP42_C = load('ERP_guidance.txt');

delta_c = 1; lambda_c = 2; gamma_c = 3; 
deltaf_c = 4; posx_c = 5; posy_c = 6;
posx_cmd_c = 7; posy_cmd_c = 8;

buf_ERP42_C = buf_ERP42_C';
UNIT = struct('R2D', 180/pi, 'D2R', pi/180);

plot_time = 1:350;

figure,
subplot(3,1,1)
plot(plot_time, buf_ERP42(delta,plot_time)*UNIT.R2D, 'r', 'linewidth', 2); hold on;
plot(plot_time, buf_ERP42_C(delta_c,plot_time)*UNIT.R2D, 'r--', 'linewidth', 2); 
legend('\delta_{sim}','\delta_{hils}');
xlabel('time [sec]'); ylabel('[\circ]');
grid on; grid minor;
title('guidance angle');

subplot(3,1,2)
plot(plot_time, buf_ERP42(lambda,plot_time)*UNIT.R2D, 'b', 'linewidth', 2); hold on;
plot(plot_time, buf_ERP42_C(lambda_c,plot_time)*UNIT.R2D, 'b--', 'linewidth', 2);
legend('\lambda_{sim}','\lambda_{hils}');
xlabel('time [sec]'); ylabel('[\circ]');
grid on; grid minor;

subplot(3,1,3)
plot(plot_time,buf_ERP42(gamma,plot_time) *UNIT.R2D, 'g', 'linewidth', 2); hold on;
plot(plot_time,buf_ERP42_C(gamma_c,plot_time) *UNIT.R2D, 'g--', 'linewidth', 2);
legend('\gamma_{sim}','\gamma_{hils}');
xlabel('time [sec]'); ylabel('[\circ]');
grid on; grid minor;


figure,
plot(plot_time, buf_ERP42(deltaf_cmd,plot_time)*UNIT.R2D, 'r', 'linewidth', 2); hold on;
plot(plot_time, buf_ERP42_C(deltaf_c,plot_time), 'r--', 'linewidth', 2); hold on;
plot(plot_time, buf_ERP42(deltaf_out,plot_time)*UNIT.R2D, 'g--', 'linewidth', 2); hold on;
plot(plot_time, buf_ERP42(delta,plot_time)*UNIT.R2D, 'b', 'linewidth', 2); hold on;
plot(plot_time, buf_ERP42_C(delta_c,plot_time)*UNIT.R2D, 'b--', 'linewidth', 2);
xlabel('time [sec]'); ylabel('[\circ]');
legend('\deltaf_{sim cmd}','\delta_{hils cmd}','\deltaf_{sim out}','\delta_{sim}','\delta_{hils}');
grid on; grid minor;
title('Compare \delta vs \delta_f');

figure,
subplot(2,1,1)
plot(plot_time, buf_ERP42(posx, plot_time)); hold on;
plot(plot_time, buf_ERP42_C(posx_c, plot_time)); hold on;
plot(plot_time, buf_WP(posx,plot_time));
xlabel('time [sec]'); ylabel('[m]');
grid on; grid minor;
legend('pos x','posx_{hils}','pos x_{cmd}');
title('Guidance command and Result');

subplot(2,1,2)
plot(plot_time, buf_ERP42(posy, plot_time)); hold on;
plot(plot_time, buf_ERP42_C(posy_c, plot_time));
plot(plot_time, buf_WP(posy,plot_time));
xlabel('time [sec]'); ylabel('[m]');
grid on; grid minor;
legend('pos y','posy_{hils}','pos y_{cmd}');


figure, 
plot(buf_ERP42(posx, plot_time), buf_ERP42(posy, plot_time), 'r', 'linewidth', 2); hold on;
plot(buf_ERP42_C(posx_c, plot_time), buf_ERP42_C(posy_c, plot_time), 'b--', 'linewidth', 2); hold on;
plot(buf_WP(posx, plot_time), buf_WP(posy, plot_time), 'g*', 'linewidth', 2);
xlabel('[m]'); ylabel('[m]'); legend('pos_{sim}','pos_{hils}','waypoint');
grid on; grid minor;
title('ackerman model trajectory');

