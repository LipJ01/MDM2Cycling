stage2 = table2array(readtable('2-nice-nice.csv'));
distances = ones(1,(ceil(length(stage2)/10)));
for i = 11:10:length(stage2)
    lasti = i-10;
    cumuDist = 0;
    for steps = lasti+1:i
       cumuDist = cumuDist + stage2(steps,6); 
    end
    distIndex = floor(i/10);   
    distances(distIndex) = cumuDist;
end
cumDis = zeros(1,length(distances));
for i = 1:length(distances)
    cumDis(i+1) = cumDis(i) + distances(i);
end
cumDis = cumDis(2:end);
% Smoothing out the elevation because otherwise there are bits with massive
% inclines and declines to the point where the rider can't get up the hill
% or falls to his virtual death.
% stage2(:,4) = smooth(stage2(:,4),10);
% sum(distances)
gradients = ones(1,(ceil(length(stage2)/10)));


for i = 11:10:length(stage2)
    gradIndex = floor(i/10);
    initalElev = stage2(i-10,4);
    changeInElev = stage2(i,4) - initalElev;
    grad = atan(changeInElev/distances(gradIndex));
    gradients(gradIndex) = grad;
end
gradients = smooth(gradients,6);
gradients(length(gradients)) = 0;
gradients(length(gradients)-1) = 0.05;
gradients(length(gradients)-2) = 0.05;
maximumForce = 200; % Kind of now maximum power
totalEnergy = 100000000000000000000000;
initialForces = ones(1,length(gradients))*0.5*maximumForce;
Aeq = [];
Beq = [];
% forceWeightings = distances; ones(1,length(initialForces))
options = optimoptions('fmincon','MaxFunctionEvaluations',1e+4,'PlotFcn','optimplotfval','Algorithm','sqp');

global powers;
powers = ones(1, length(distances));
global velocitys;
velocitys = ones(1, length(distances));
global RForces;
RForces = ones(1, 1);

% x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
x = fmincon(@(forces) wholeSimNoGlob(forces, distances, gradients),initialForces, distances,totalEnergy,Aeq,Beq, zeros(1,length(initialForces)), ones(1,length(initialForces)) * maximumForce,[],options)

function time = wholeSimNoGlob(forces, dists, grads)
    global RForces;
    massOfRiderAndBike = 69.8; % kg 
    resistanceConstant = 0.05; % 0.5*(air density)*(drag coefficient)*(frontal area of cyclist) , kg m-1
    
    speeds = zeros(1,length(grads)+1);
    times = zeros(1,length(grads)+1);
    RForces = ones(1, 1);
    global powers;
    global velocitys;
    for i=1:length(grads) 
        speeds(i+1) = velocityAtNextStep(speeds(i), dists(i), forces(i),grads(i), massOfRiderAndBike, resistanceConstant);
        times(i) = timeFromVelocitys(speeds(i),speeds(i+1), dists(i));
        powers(i) = forces(i) * speeds(i);
        velocitys(i) = speeds(i);
    end
    time = sum(times);
end

function time = timeFromVelocitys(initalVelocity, finalVelocity, stepDistance) % output in s
    time = (2*stepDistance)/(initalVelocity+finalVelocity);
end

function acceleration = accelerationGivenForceAndGradient (force, theta, mass, initalVelocity, resistance) % output in m s-2
    global RForces;
    resultantForce = (force - sin(theta)*mass*9.81 - initalVelocity^2*resistance); % N
    RForces(end+1) = resultantForce;
    acceleration = resultantForce/mass; 
end

function velocity = velocityAtNextStep (initalVelocity, stepDistance, force, theta, mass, resistance) % output in m s-1
    squareVel = initalVelocity^2 + 2*accelerationGivenForceAndGradient(force, theta, mass, initalVelocity, resistance)*stepDistance;
    velocity = sqrt(squareVel); % deal with when rider comes to a halt during iterations
end
