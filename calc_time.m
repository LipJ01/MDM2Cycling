function t_n = calc_time(t0, F, theta, v, mass, dist)

t_n = (-(((-F*t0)/mass) + 9.81*t0*sin(theta) + v) + sqrt(v^2 +(2*F*dist)/mass -2*9.81*dist*sin(theta)))/((F/mass) - 9.81*sin(theta));