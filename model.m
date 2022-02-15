
% Cyclist riding in stages up a mountain.

stage2 = table2array(readtable('2-nice-nice.csv'));
global gradients;
global distances;
gradients = stage2(:,7);
distances = stage2(:,6);
% length(gradients)
maximumForce = 6000;
global totalEnergy;
totalEnergy = 400000;
global resultantSpeeds
resultantSpeeds = zeros(1,length(gradients)+1);
global timePerStage
timePerStage = zeros(1,length(gradients)+1);
forces = ones(1,length(gradients))*0.8*maximumForce;
% length(forces)
Aeq = [];
Beq = [];
% wholeSim(forces)
% initalStrat = wholeSim(forces)
options = optimoptions('fmincon','MaxFunctionEvaluations',1e+10,'PlotFcn','optimplotfval')
% options = optimoptions('fmincon','PlotFcn','optimplotfval')
x = fmincon(@(forces) wholeSim(forces),forces, ones(1,length(forces)),totalEnergy,Aeq,Beq, zeros(1,length(forces)), ones(1,length(forces)) * maximumForce,[],options);
x(1:10)
function time = wholeSim(forces)
    global distances;
    global gradients;
    distancePerStep = distances;
    massOfRiderAndBike = 70;
    resistanceConstant = 0.5;
    thetas = gradients;
    energy = ones(1,length(thetas));
    global totalEnergy;
    energy(1) = totalEnergy;
    global resultantSpeeds;
    global timePerStage;
    for i=1:length(thetas) 
%         fprintf("step");
        resultantSpeeds(i+1) = velocityAtNextStep(resultantSpeeds(i), distancePerStep(i), forces(i),thetas(i), massOfRiderAndBike, resistanceConstant);
        energy(i+1) = energy(i) - forces(i)*distancePerStep(i);
    end
%     resultantSpeeds
    for i=1:length(thetas)
        timePerStage(i) = timeFromVelocitys(resultantSpeeds(i),resultantSpeeds(i+1), distancePerStep(i));
    end
%     timePerStage
%     length(distancePerStep)
%     length(thetas)
%     length(energy)
%     length(resultantSpeeds)
%     length(timePerStage)
    time = sum(timePerStage);
end
function time = timeFromVelocitys(initalVelocity, finalVelocity, stepDistance)
    time = (2*stepDistance)/(initalVelocity+finalVelocity);
end

function acceleration = accelerationGivenForceAndGradient (force, theta, mass, initalVelocity, resistance)
    acceleration = (force - sin(theta)*mass*9.81 - initalVelocity^2*resistance)/mass;
end

function velocity = velocityAtNextStep (initalVelocity, stepDistance, force, theta, mass, resistance)
    squareVel = initalVelocity^2 + 2*accelerationGivenForceAndGradient(force, theta, mass, initalVelocity, resistance)*stepDistance;
    velocity = sqrt(max(squareVel,0.1)); % deal with when rider comes to a holt during iterations
end

