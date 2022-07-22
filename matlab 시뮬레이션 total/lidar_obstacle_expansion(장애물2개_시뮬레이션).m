close all; clear;clc;

%================================================
% expansion 코드로 시뮬레이션 돌리기
%================================================
V       = 10                    ; %Speed
intv    = 0.01                  ; %Time interval
K       = 30                    ; %Gain
initial_point = [0 ; 0]         ;   %initial point
Gamma   = deg2rad(30)  ;
r_max = 10; % dectecting range [m] - lidar 


Way_point     = [60;40];
edge_point = [-5, Way_point(1)+5;
              -5, Way_point(2)+5];

l = 0.75;  % vehicle size(half) [m]

vehi_ini = [0,7;
           0,0];

R    = [cos(Gamma),-sin(Gamma);
         sin(Gamma),cos(Gamma)];


vehi = R*vehi_ini ;
vehi = vehi + initial_point     ;
R_point       = vehi(:,1)   ;
  
deg = 0 : deg2rad(5) : deg2rad(360);
x = cos(deg); y = sin(deg);
circle_ini = [ l*x ; l*y ];

%-------------------------------------------
% 장애물 설정 
% Problem1: 장애물 탐지 -> 조향 뒤 갈 곳이 없으면 급격하게 우회함.
%

obs1_pos_ini = [25;35];
obs1_pos_rel = obs1_pos_ini;
obs1_range = 10;
obst1_ini = [ obs1_range*x ; obs1_range*y ] + obs1_pos_ini ;

obs2_pos_ini = [27;17];
obs2_pos_rel = obs2_pos_ini;
obs2_range = 5;
obst2_ini = [ obs2_range*x ; obs2_range*y ] + obs2_pos_ini ;


deg = deg2rad(-90) : deg2rad(2) : deg2rad(90);
x = cos(deg); y = sin(deg);
r_detect_ini = [r_max*x;r_max*y];
r_detect = R*r_detect_ini + R_point;

r = norm(vehi(:,1)-Way_point);
ramda = Way_point - R_point     ;
ramda = atan2(ramda(2),ramda(1)) ;
delta = Gamma - ramda           ;
way_init = R_point                ;
delta_f = delta;
scan_n = 0;

sigma = 0.3;
e = 0.05;

deg_obs = 0:0.25:180;      %% off는 0~180 값이어야 한다.

psi = deg2rad(-90):deg2rad(0.25):deg2rad(90);

Fp = zeros(1,length(deg_obs));
Fp1 = zeros(1,length(deg_obs));
Fp2 = zeros(1,length(deg_obs));
Fp1 = Fp1 + r_max;
Fp2 = Fp2 + r_max;
Fp = Fp + r_max;

k = 1; % [m]    // 확장시킬 원 반지름 -> 차 반지름 크기보다 커야함.
% max_range = 11;

while r>5
    
    omega = -K*V*sin(delta)/r ;
    delta_f = 2*omega*l/V;
    leng = V*intv;
    
    Fs = r_max * exp((-(psi-delta_f).^2)/(2*sigma^2));   % -90 ~ 90
    R_i2b    = [cos(Gamma),sin(Gamma);
        -sin(Gamma),cos(Gamma)];
    
    obs1_pos_rel = R_i2b*(obs1_pos_ini - R_point);
    a1 = obs1_pos_rel(1); b1 = obs1_pos_rel(2);
    
    if norm(obs1_pos_rel) <= obs1_range+r_max
        for i = 1:length(deg_obs)
            m = tan(psi(i));
            D_obs1 = obs1_range^2*(1+m^2) - (b1 - m*a1)^2;
            if D_obs1 >= 0
                x_c1 = (a1 + b1*m - sqrt(D_obs1))/(1+m^2);
                y_c1 = m*x_c1;
                p_c1 = [x_c1;y_c1];
                if x_c1 > 0
                    Fp1(i) = norm(p_c1);
                else
                    Fp1(i) = r_max;
                end
                if Fp1(i) > r_max; Fp1(i) = r_max; end
            else
                Fp1(i) = r_max;
            end
        end
    else
        Fp1 = zeros(1,length(deg_obs)) + r_max;
    end
    
    obs2_pos_rel = R_i2b*(obs2_pos_ini - R_point);
    a2 = obs2_pos_rel(1); b2 = obs2_pos_rel(2);
    
    if norm(obs2_pos_rel) <= obs2_range+r_max
        for i = 1:length(deg_obs)
            m = tan(psi(i));
            D_obs2 = obs2_range^2*(1+m^2) - (b2 - m*a2)^2;
            if D_obs2 >= 0
                x_c2 = (a2 + b2*m - sqrt(D_obs2))/(1+m^2);
                y_c2 = m*x_c2;
                p_c2 = [x_c2;y_c2];
                if x_c2 > 0
                    Fp2(i) = norm(p_c2);
                else
                    Fp2(i) = r_max;
                end
                if Fp2(i) > r_max; Fp2(i) = r_max; end
            else
                Fp2(i) = r_max;
            end
        end
    else
        Fp2 = zeros(1,length(deg_obs)) + r_max;
    end
    
    for i = 1:length(deg_obs)
        if Fp1(i)<Fp2(i)
            Fp(i)=Fp1(i);
        else
            Fp(i)=Fp2(i);
        end
    end
    
    
    %=======================================================================
    % OFF expansion
    %=======================================================================
    
    data = Fp;
    data_handled = data;
    
    for i = 1:length(deg_obs)
        r_i = Fp(1,i);
        theta_i = deg_obs(i);       % 0 : 0.25 : 180
        
        tmp = k/r_i;%%%%%%%%%%%%%    => arcsin 땜시
        if tmp>1 ; tmp = 1;end%%%%%%%%%%
        theta = fix((-asind(tmp)+theta_i)*4)/4;%%%%%%%%%%%%%%
        
        while (theta < (asind(tmp) + theta_i) && theta <= 180)%%%%%%%%%%%%%
            index = int16(theta * 4)+1;
            
%             if (index >= 1 && index <= length(deg_obs) && data(i)<r_max)
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
%     FI = (1-e) * Fp + e * Fs;
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
    
    ramda = Way_point - R_point     ;
    ramda = atan2(ramda(2),ramda(1)) ;
    delta = Gamma - ramda           ;
    line_RtoW = [way_init Way_point] ;
    
    figure(1)
        subplot(3,6,[1,2,3,7,8,9,13,14,15])
    
    % ======================
    % moving objection
    %
    plot(circle(1,:),circle(2,:),'k', ...
        r_detect(1,:),r_detect(2,:),'r', ...
        obst1_ini(1,:), obst1_ini(2,:),'g', ...
        obst2_ini(1,:), obst2_ini(2,:),'g', ...
        line_RtoW(1,:),line_RtoW(2,:),'b', ...
        vehi(1,:), vehi(2,:),'b', ...
        edge_point(1,:),edge_point(2,:),'w.');
    %    grid on;axis equal;axis([-10 60 -10 60])
    
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
%         axis([-90 90 0 6.5]);grid on
    
        subplot(3,6,10)
        plot(rad2deg(psi),data_handled,'r', rad2deg(psi), Fp,'b')
%         axis([-90 90 0 6.5]);grid on
    
        subplot(3,6,16)
        plot(rad2deg(psi),FI)
%         axis([-90 90 0 6.5]);grid on
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






