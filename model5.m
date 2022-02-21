

gradients = gradsRad; % from other .m file in workspace
distances = ones(1, length(gradsRad)) * 1000;

maximumForce = 200; % Unit check required
totalEnergy = 100000000000000000000000; % consider this inf.
initialForces = ones(1,length(gradients))*0.5*maximumForce; % shouldn't matter
Aeq = []; % Can possibly make use of...
Beq = []; % at least a discription of what it is is needed here.
% forceWeightings = distances; ones(1,length(initialForces))
options = optimoptions('fmincon','MaxFunctionEvaluations',1e+4,'PlotFcn','optimplotfval','Algorithm','sqp');

% Globals being used to see what's happening within the simulation/plot
% graphs... thinking would be better to use those while not doing the
% optomise bit... Yeah. Will remove and come back later. 
global powers;
powers = ones(1, length(distances));
global velocitys;
velocitys = ones(1, length(distances));
global RForces;
RForces = ones(1, 1);

% x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
x = fmincon(@(forces) Simulation(forces, distances, gradients),initialForces, distances,totalEnergy,Aeq,Beq, zeros(1,length(initialForces)), ones(1,length(initialForces)) * maximumForce,[],options)


function time = Simulation(forces, dists, grads)
    global RForces;
    massOfRiderAndBike = 70;
    resistanceConstant = 0.05;
    
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

function time = timeFromVelocitys(initalVelocity, finalVelocity, stepDistance)
    time = (2*stepDistance)/(initalVelocity+finalVelocity);
end

function acceleration = accelerationGivenForceAndGradient (force, theta, mass, initalVelocity, resistance)
    global RForces;
    resultantForce = (force - sin(theta)*mass*9.81 - initalVelocity^2*resistance);
    RForces(end+1) = resultantForce;
    acceleration = resultantForce/mass;
end

function velocity = velocityAtNextStep (initalVelocity, stepDistance, force, theta, mass, resistance)
    squareVel = initalVelocity^2 + 2*accelerationGivenForceAndGradient(force, theta, mass, initalVelocity, resistance)*stepDistance;
    velocity = sqrt(squareVel); % deal with when rider comes to a holt during iterations
end
