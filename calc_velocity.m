function v_tn = calc_velocity(F,mass,theta,t_n,t0,v0)
k = 0.03;
v_tn = ((F/mass) - 9.81*sin(theta) - k*9.81*cos(theta))*(t_n - t0) + v0;