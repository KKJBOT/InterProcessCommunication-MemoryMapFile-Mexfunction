
% Rotate ERP42
Roate_body = [cos(ERP42.gamma),-sin(ERP42.gamma); sin(ERP42.gamma), cos(ERP42.gamma)];
Rotate_wheel = [cos(ERP42.gamma + ERP42.deltaf),-sin(ERP42.gamma + ERP42.deltaf) ; sin(ERP42.gamma + ERP42.deltaf), cos(ERP42.gamma + ERP42.deltaf)];
% disp(ERP42.gamma + ERP42.deltaf);
ERP42.body = ERP42.pos(1,:)' + Roate_body*init_body;
POS_wheel  = ERP42.pos(1,:)' + Roate_body*init_body(:,end-1);
ERP42.wheel = POS_wheel + Rotate_wheel*(init_wheel - init_body(:,end-1));

% Plot();
figure(1),
subplot(3,6,[1,2,3,7,8,9,13,14,15])
plot(waypoint(ERP42.nwp,xx), waypoint(ERP42.nwp,yy), 'ro' ,ERP42.pos(1,xx), ERP42.pos(1,yy), 'bo',...
    [ERP42.pos(1,xx) waypoint(ERP42.nwp,xx)], [ERP42.pos(1,yy) waypoint(ERP42.nwp,yy)],'g',...
    ERP42.body (1,1:5), ERP42.body (2,1:5),'b',ERP42.body (1,6:end-2), ERP42.body (2,6:end-2),'b', ERP42.body (1,end-1:end), ERP42.body (2,end-1:end),'b',...
    ERP42.wheel(1,1:5), ERP42.wheel(2,1:5),'r',ERP42.wheel(1,6:end), ERP42.wheel(2,6:end),'r',...
    obstacle_ini(1,:), obstacle_ini(2,:),'k');grid on;
xlim([min(waypoint(:,1))-3 max(waypoint(:,1))+3]); ylim([min(waypoint(:,2))-3 max(waypoint(:,2))+3]);
xlabel('[m]'); ylabel('[m]');
grid on;axis equal; title('simulation map'); 


    subplot(3,6,4)
    plot(rad2deg(psi),Fs)
    axis([-90 90 0 6.5]);grid on
    
    subplot(3,6,10)
    plot(rad2deg(psi),data_handled,'r', rad2deg(psi), Fp,'b')
    axis([-90 90 0 6.5]);grid on
    
    subplot(3,6,16)
    plot(rad2deg(psi),FI)
    axis([-90 90 0 6.5]);grid on
    drawnow limitrate