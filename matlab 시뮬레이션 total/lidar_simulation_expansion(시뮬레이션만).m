close all; clear;clc;


%================================================
% extension 
%================================================
V       = 10                    ; %Speed
intv    = 0.01                  ; %Time interval
K       = 30                    ; %Gain
initial_point = [0 ; 0]         ; %initial point
Gamma   = deg2rad(60)  ;

l = 0.75;  % vehicle size(half) [m]                       

vehi_ini = [0,7;
            0,0];

R    = [cos(Gamma),-sin(Gamma);
         sin(Gamma),cos(Gamma)];
     
vehi = R*vehi_ini ;
vehi = vehi + initial_point     ;     
R_point       = vehi(:,1)   ;                            % vehicle (첫번째 열 (처음엔 [0,0])
Way_point     = [60;60]           ;                      % waypoint 좌표 
deg = 0 : deg2rad(5) : deg2rad(360);                     % 0 ~ 360 [rad]
x = cos(deg); y = sin(deg);                              % 원을 그리기 위한 각도 
circle_ini = [ l*x ; l*y ];                              % vehicle 의 크기 [l*x, l*y]
 
obs_pos_ini = [25;25];                                   % 장애물의 위치를 지정

obs_pos_rel = obs_pos_ini;                               % 장애물의 상대적 위치???

obs_range = 5;                                           % 장애물의 크기
obst = [ obs_range*x ; obs_range*y ];                    % 장애물 원의 크기 ( obst)원 
obst_ini = [ obs_range*x ; obs_range*y ] + obs_pos_ini ;

deg = deg2rad(-90) : deg2rad(2) : deg2rad(90);           % -90~90 rad 단위의 각도 배열 
r_max = 6; % dectecting range [m]                        % detecting range (6[m])
x = cos(deg); y = sin(deg);                              % 여기서 deg의 정의가 변화함 -90~90으로 
r_detect_ini = [r_max*x;r_max*y];                        % 이건 vehicle의 detect의 그림을 그려준것임 
r_detect = R*r_detect_ini + R_point;                     % 

r = norm(vehi(:,1)-Way_point);                           % vehicle이 직선으로 되어있어서 뒤의 점에 대해서 r을 계산한다.
ramda = Way_point - R_point     ;                        % R_point = vehi(:,1)
ramda = atan2(ramda(2),ramda(1)) ;                       % atan2(
delta = Gamma - ramda           ;                        % 초기 자동차의 헤딩- 가이던스 프레임에 대한 (waypoint-vehicle(:,1))
way_init = R_point                ;                      % vehi(:,1)
scan_n = 0;

sigma = 0.3;                                             % parameter_sigma
e = 0.05;                                                % parameter

deg_obs = 0:0.25:180;     

psi = deg2rad(-90):deg2rad(0.25):deg2rad(90);            % -90:0.25:90 psi [rad]
% Fp = zeros(1,length(psi));
Fp = zeros(1,length(deg_obs));                           
Fp = Fp + r_max;

k = 1.5; % [m]
max_range = 11;

while r>3
    
    omega = -K*V*sin(delta)/r ;                          % Guidance law ( omega output)
    delta_f = 2*omega*l/V;                               % bicycle kinematics 고려한 delta_f
    leng = V*intv;                                       % interval 간격마다 이동한 거리 
    
    Fs = r_max*exp((-(psi-delta_f).^2)/(2*sigma^2));   % -90 ~ 90  조향장 만들어내는 수식인듯 SFF
    R_i2b    = [cos(Gamma),sin(Gamma);                   % 이렇게 되면 gamma값이 계속적으로 변화하는 변환행렬이 만들어지는 건가?
        -sin(Gamma),cos(Gamma)];
    obs_pos_rel = R_i2b*(obs_pos_ini - R_point);         % obstacle의 포지션을 바디좌표계로 변환한다. 
    a = obs_pos_rel(1); b = obs_pos_rel(2);              % 바디좌표계의 상대적 위치의 좌표계를 변수로 치환
    
    %     if mod(scan_n,10) == 1
    %     end
    if norm(obs_pos_rel) <= obs_range+r_max              % r_max는 detecting range=6 obs_range는 5m ==11[m]
        for i = 1:length(deg_obs)                        % deg_obs = 0:0.25:180 but real sensor spec을 고려줘야할 듯 
            m = tan(psi(i));                             
            D = obs_range^2*(1+m^2) - (b - m*a)^2;       % a= obstacle의 x좌표 b=obstacle의 y좌표 
            if D >= 0
                x_c = (a + b*m - sqrt(D))/(1+m^2);
                y_c = m*x_c;
                p_c = [x_c;y_c];
                if x_c > 0
                    Fp(i) = norm(p_c);
                else
                    Fp(i) = r_max;
                end
                if Fp(i) > r_max; Fp(i) = r_max; end
            else
                Fp(i) = r_max;
            end
        end
        
    else
        %         Fp = zeros(1,length(psi)) + r_max;
        Fp = zeros(1,length(deg_obs));
        
    end

    %=======================================================================
    % OFF extension
    %=======================================================================
    
    data = Fp;
    data_handled = data;
    
    for i = 1:length(deg_obs)
        r_i = Fp(1,i);
        theta_i = deg_obs(i);       % 0 : 0.25 : 180
        
        tmp = k/r_i;%%%%%%%%%%%%%    => arcsin ?븳?떆
        if tmp>1 ; tmp = 1;end%%%%%%%%%%
        theta = fix((-asind(tmp)+theta_i)*4)/4;%%%%%%%%%%%%%%
        
        while (theta < (asind(tmp) + theta_i) && theta <= 180)%%%%%%%%%%%%%
            index = int16(theta * 4)+1;
            
            if (index >= 1 && index <= length(deg_obs))
                D = (r_i^2 * cosd(deg_obs(index)-theta_i)^2) - (r_i^2 - k^2);
                if D < 0; D = 0; end
                r_tmp = r_i*cosd(deg_obs(index)-theta_i) - sqrt( D );
                if r_tmp < 0; r_tmp = 0; end%%%%%%%%%%%%%%%%%%
                if (r_tmp <= data_handled(index) )
                    data_handled(index) = r_tmp;
                end
            end
            
            theta = theta + 0.25;
            if theta > 180; break; end
            
        end
        
        
    end    

    %=======================================================================
        FI = (1-e) * Fp + e * Fs;
        FI = (1-e) * data_handled + e * Fs;

    [~, idx] = max(FI);
    delta_f=psi(idx);
    
    omega =V*delta_f/(2*l) ;
    psi_c = omega * intv ;
    Gamma =   Gamma + psi_c;
    
    R = [cos(Gamma),-sin(Gamma);
        sin(Gamma),cos(Gamma)];
    vehi = R*vehi_ini + R_point      ;
    vehi(1,:)  = vehi(1,:) + leng*cos(Gamma+delta_f/2) ;
    vehi(2,:)  = vehi(2,:) + leng*sin(Gamma+delta_f/2) ;
    R_point    = vehi(:,1)  ;
    circle = circle_ini + R_point;
    
    
    
    r = norm(vehi(:,1)-Way_point);
    Gamma = vehi(:,2) - vehi(:,1)   ;
    Gamma = atan2(Gamma(2),Gamma(1)) ;
    r_detect = R*r_detect_ini + R_point;
    delta = Gamma - ramda           ;
    line_RtoW = [way_init Way_point] ;
  
    
    figure(1)
    subplot(3,6,[1,2,3,7,8,9,13,14,15])
   
    % ======================
    % moving objection
%     
    plot(circle(1,:),circle(2,:),'k', ...
        r_detect(1,:),r_detect(2,:),'r', ...
        obst_ini(1,:), obst_ini(2,:),'g', ...
        line_RtoW(1,:),line_RtoW(2,:),'b', ...
        vehi(1,:), vehi(2,:),'b');
   grid on;axis equal;axis([-10 60 -10 60])

   % ======================
   % To check the trajectory
%     hold on ; p1 = plot(obst_ini(1,:), obst_ini(2,:),'g', 'linewidth',1.5)
%     hold on ; p3 = plot(circle(1,:),circle(2,:),'r')
%     
%     grid on;axis equal;axis([-10 60 -10 60])
    
   % ======================
   % OFF, IFF, SFF

    subplot(3,6,4)
    plot(rad2deg(psi),Fs)
    axis([-90 90 0 6.5]);grid on
    
    subplot(3,6,10)
    plot(rad2deg(psi),data_handled,'r', rad2deg(psi), Fp,'b')
    axis([-90 90 0 6.5]);grid on
    
    subplot(3,6,16)
    plot(rad2deg(psi),FI)
    axis([-90 90 0 6.5]);grid on
    
   % ======================
%     subplot(3,6,[5,6,11,12,17,18])
%     plot(circle_ini(1,:),circle_ini(2,:),'b', ...
%         r_detect_ini(1,:),r_detect_ini(2,:),'r', ...
%         obst(1,:)+obs_pos_rel(1),obst(2,:)+obs_pos_rel(2),'g');
%     grid on;axis equal;
%     axis([-3 12 -12 12]);
    
    drawnow limitrate
    
   
    
end
drawnow
