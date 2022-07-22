%SaveBuffer

buf_ERP42(posx:posy,STIME.cnt) = ERP42.pos;
buf_ERP42(posx_dot:posy_dot,STIME.cnt) = ERP42.pos_dot;

buf_ERP42(r,STIME.cnt) = ERP42.r;
buf_ERP42(w,STIME.cnt) = ERP42.w;

buf_ERP42(lambda,STIME.cnt) = ERP42.lambda;
buf_ERP42(gamma,STIME.cnt) = ERP42.gamma;
buf_ERP42(delta,STIME.cnt) = ERP42.delta;
buf_ERP42(deltaf_cmd,STIME.cnt) = ERP42.deltaf;
buf_ERP42(deltaf_out,STIME.cnt) = ERP42.actdf;

buf_WP(:,STIME.cnt) = waypoint(ERP42.nwp,:)';