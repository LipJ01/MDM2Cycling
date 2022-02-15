
% Cyclist riding in stages up a mountain.

stage2 = table2array(readtable('2-nice-nice.csv'));
gradients = stage2(:,7);
distances = stage2(:,6);
% length(gradients)
maximumForce = 6000;
totalEnergy = 4000000;
global resultantSpeeds;
resultantSpeeds = zeros(1,length(gradients)+1);
global timePerStage
timePerStage = zeros(1,length(gradients)+1);
initialForces = ones(1,length(gradients))*0.5*maximumForce;
% length(forces)
Aeq = [];
Beq = [];
% wholeSim(forces)
% initalStrat = wholeSim(forces)
options = optimoptions('fmincon','MaxFunctionEvaluations',1e+10,'PlotFcn','optimplotfval',)
% options = optimoptions('fmincon','PlotFcn','optimplotfval')
x = fmincon(@(forces) wholeSimNoGlob(forces, distances, gradients, totalEnergy),initialForces, ones(1,length(initialForces)),totalEnergy,Aeq,Beq, zeros(1,length(initialForces)), ones(1,length(initialForces)) * maximumForce,[],options);
x(1:10)


function time = wholeSimNoGlob(forces, dists, grads, energyTot)
    tic
    distancePerStep = dists;
    massOfRiderAndBike = 70;
    resistanceConstant = 0.5;
    thetas = grads;
    energy = ones(1,length(thetas));
    energy(1) = energyTot;
    speeds = zeros(1,length(thetas)+1);
    times = zeros(1,length(thetas)+1);
    
    for i=1:length(thetas) 
%         fprintf("step");
        speeds(i+1) = velocityAtNextStep(speeds(i), distancePerStep(i), forces(i),thetas(i), massOfRiderAndBike, resistanceConstant);
        energy(i+1) = energy(i) - forces(i)*distancePerStep(i);
        times(i) = timeFromVelocitys(speeds(i),speeds(i+1), distancePerStep(i));
    end
%     resultantSpeeds
    for i=1:length(thetas)
        
    end
%     timePerStage
%     length(distancePerStep)
%     length(thetas)
%     length(energy)
%     length(resultantSpeeds)
%     global timePerStage;
%     global resultantSpeeds;
%     resultantSpeeds = speeds;
%     timePerStage = times;
%     length(timePerStage)
    toc
    time = sum(times);
end

function time = timeFromVelocitys(initalVelocity, finalVelocity, stepDistance)
    time = (2*stepDistance)/(initalVelocity+finalVelocity);
end

function acceleration = accelerationGivenForceAndGradient (force, theta, mass, initalVelocity, resistance)
    acceleration = (force - sin(theta)*mass*9.81 - initalVelocity^2*resistance)/mass;
end

function velocity = velocityAtNextStep (initalVelocity, stepDistance, force, theta, mass, resistance)
    squareVel = initalVelocity^2 + 2*accelerationGivenForceAndGradient(force, theta, mass, initalVelocity, resistance)*stepDistance;
    velocity = sqrt(max(squareVel,1)); % deal with when rider comes to a holt during iterations
end

