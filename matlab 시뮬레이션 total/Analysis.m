% Plotting saved buffer
plot_time = 1:length(buf_ERP42);

figure,
subplot(3,1,1)
plot(plot_time, buf_ERP42(delta,:)*UNIT.R2D, 'r', 'linewidth', 2); hold on;
legend('\delta');
xlabel('time [sec]'); ylabel('[\circ]');
grid on; grid minor;
title('guidance angle');

subplot(3,1,2)
plot(plot_time, buf_ERP42(lambda,:)*UNIT.R2D, 'b', 'linewidth', 2);
legend('\lambda');
xlabel('time [sec]'); ylabel('[\circ]');
grid on; grid minor;

subplot(3,1,3)
plot(plot_time,buf_ERP42(gamma,:) *UNIT.R2D, 'g', 'linewidth', 2);
legend('\gamma');
xlabel('time [sec]'); ylabel('[\circ]');
grid on; grid minor;


figure,
plot(plot_time, buf_ERP42(deltaf_cmd,:)*UNIT.R2D, 'r', 'linewidth', 2); hold on;
plot(plot_time, buf_ERP42(deltaf_out,:)*UNIT.R2D, 'g--', 'linewidth', 2); hold on;
plot(plot_time, buf_ERP42(delta,:)*UNIT.R2D, 'b', 'linewidth', 2);
xlabel('time [sec]'); ylabel('[\circ]');
legend('\deltaf_{cmd}','\deltaf_{out}','\delta');
grid on; grid minor;
title('Compare \delta vs \delta_f');

figure,
subplot(2,1,1)
plot(plot_time, buf_ERP42(posx, :)); hold on;
plot(plot_time, buf_WP(posx,:));
xlabel('time [sec]'); ylabel('[m]');
grid on; grid minor;
legend('pos x','pos x_{cmd}');
title('Guidance command and Result');

subplot(2,1,2)
plot(plot_time, buf_ERP42(posy, :)); hold on;
plot(plot_time, buf_WP(posy,:));
xlabel('time [sec]'); ylabel('[m]');
grid on; grid minor;
legend('pos y','pos y_{cmd}');

figure, 
plot(buf_ERP42(posx, :), buf_ERP42(posy, :), 'r', 'linewidth', 2); hold on;
plot(buf_WP(posx, :), buf_WP(posy, :), 'g*', 'linewidth', 2);
xlabel('[m]'); ylabel('[m]');
grid on; grid minor;
legend('ackerman model trajectory','waypoint');

