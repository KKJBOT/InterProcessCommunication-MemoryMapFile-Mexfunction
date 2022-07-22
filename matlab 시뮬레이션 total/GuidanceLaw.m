% Guidance Law
ERP42.r = norm(waypoint(ERP42.nwp,:)' - ERP42.pos') +(sigNav * randn(1,1)); 
ERP42.w = ERP42.v / ERP42.r * sin(ERP42.delta)*Kgain;

ERP42.lambda = atan2( (waypoint(ERP42.nwp, yy) - ERP42.pos(1,yy)), (waypoint(ERP42.nwp, xx) - ERP42.pos(1,xx)) );

ERP42.delta = ERP42.gamma - ERP42.lambda;
if ERP42.delta > 180*UNIT.D2R
    ERP42.delta = ERP42.delta - 180*UNIT.D2R ;
elseif ERP42.delta < -180*UNIT.D2R
    ERP42.delta = ERP42.delta +180*UNIT.D2R ;
end


ERP42.deltaf = -2*ERP42.If*Kgain*sin(ERP42.delta)/ERP42.r; %bicyle model아닌가
if ERP42.deltaf > 28*UNIT.D2R
    ERP42.deltaf = 28*UNIT.D2R ;
elseif ERP42.deltaf < -28*UNIT.D2R
    ERP42.deltaf = -28*UNIT.D2R ;
end

%%%%%%% Local Guidance Signal processing
Fs          = r_max_Local*exp((-(psi-ERP42.deltaf).^2)/(2*sigma_Local^2));
Rot_i2b     = [cos(ERP42.gamma), sin(ERP42.gamma);
               -sin(ERP42.gamma), cos(ERP42.gamma)];
obs_pos_rel = Rot_i2b*(obs_pos_ini-[ERP42.pos(1,xx); ERP42.pos(1,yy)]);
a= obs_pos_rel(1) ;
b= obs_pos_rel(2) ;

if norm(obs_pos_rel) <= obs_range+r_max_Local              % r_max는 detecting range=6 obs_range는 5m ==11[m]
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
                Fp(i) = r_max_Local;
                 disp(ERP42.deltaf);
            end
            if Fp(i) > r_max_Local; Fp(i) = r_max_Local; end
        else
            Fp(i) = r_max_Local;
        end
    end
    
else
    %         Fp = zeros(1,length(psi)) + r_max;
    Fp = zeros(1,length(deg_obs));
    
end

 % OFF extension
    %=======================================================================

    data_handled = Fp;
    
    for i = 1:length(deg_obs)
        r_i = Fp(1,i);
        theta_i = deg_obs(i);       % 0 : 0.25 : 180
        
        tmp = Kgain/r_i;%%%%%%%%%%%%%    => arcsin ?븳?떆
        if tmp>1 ; tmp = 1;end%%%%%%%%%%
        theta = fix((-asind(tmp)+theta_i)*4)/4;%%%%%%%%%%%%%%
        
        while (theta < (asind(tmp) + theta_i) && theta <= 180)%%%%%%%%%%%%%
            index = int16(theta * 4)+1;
            
            if (index >= 1 && index <= length(deg_obs))
                D = (r_i^2 * cosd(deg_obs(index)-theta_i)^2) - (r_i^2 - Kgain^2);
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

%   FI = (1-e_Local) * Fp + e_Local * Fs;
     FI = (1-e_Local) * data_handled + e_Local * Fs;

    [~, idx] = max(FI);
    ERP42.deltaf=psi(idx);
    %=======================================================================

% Motor Transfer function
ERP42.actv = (1-STIME.ts/Ta)*ERP42.actv + STIME.ts/Ta*ERP42.v; 
ERP42.actdf = (1-STIME.ts/Tb)*ERP42.actdf + STIME.ts/Tb*ERP42.deltaf;

% Ackerman model heading angle kinematics
ERP42.gamma = ERP42.gamma + ERP42.actv*STIME.ts*tan(ERP42.actdf)/ERP42.If + (sigAHRS * randn(1,1));
if ERP42.gamma > 180*UNIT.D2R
    ERP42.gamma = ERP42.gamma - 180*UNIT.D2R ;
elseif ERP42.gamma < -180*UNIT.D2R
    ERP42.gamma = ERP42.gamma +180*UNIT.D2R ;
end

% Ackerman model position kinematics
ERP42.pos(1,xx) = ERP42.pos(1,xx) + ERP42.v*STIME.ts*cos(ERP42.gamma);
ERP42.pos(1,yy) = ERP42.pos(1,yy) + ERP42.v*STIME.ts*sin(ERP42.gamma);
