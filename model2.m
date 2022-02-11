
% Cyclist riding in stages up a mountain.

forces = [40 40 40 40 40];
Aeq = [];
Beq = [];
% wholeSim(forces)
maximumForce = 80;
x = fmincon(@(forces) wholeSim(forces),forces, [1 1 1 1 1],200,Aeq,Beq, ones(length(forces)) * 0, ones(length(forces)) * maximumForce)

function time = wholeSim(forces)
    distancePerStep = 100;
    massOfRiderAndBike = 75;
%     resistanceConstant = 0.5;
    thetas = [0 0.01 0.02 0.05 0];
    energy = [400000 0 0 0 0 0];
    resultantSpeeds = [0 0 0 0 0 0];
    timePerStage = [0 0 0 0 0 0];
    
    for i=1:length(thetas)
%         timePerStage(i) = timeFromVelocitys(resultantSpeeds(i),resultantSpeeds(i+1), distancePerStep);
        timePerStage(i+1) = calc_time(timePerStage(i),forces(i),thetas(i),resultantSpeeds(i),massOfRiderAndBike,distancePerStep);
    end
    for i=1:length(thetas) 
%         fprintf("step");
%         resultantSpeeds(i+1) = velocityAtNextStep(resultantSpeeds(i), distancePerStep, forces(i),thetas(i), massOfRiderAndBike); %, resistanceConstant);
        resultantSpeeds(i+1) = calc_velocity(forces(i),massOfRiderAndBike,thetas(i),timePerStage(i+1),timePerStage(i),resultantSpeeds(i));
        energy(i+1) = energy(i) - forces(i)*distancePerStep;
    end
%     resultantSpeeds

%     timePerStage
%     energy
    time = sum(timePerStage);
    timePerStage
    resultantSpeeds
end
function time = timeFromVelocitys(initalVelocity, finalVelocity, stepDistance)
    time = (2*stepDistance)/(initalVelocity+finalVelocity);
end

function acceleration = accelerationGivenForceAndGradient (force, theta, mass, initalVelocity)%, resistance)
    %acceleration = (force - sin(theta)*mass*9.81 - initalVelocity^2*resistance)/mass;
    acceleration = (force - sin(theta)*mass*9.81);
end

function velocity = velocityAtNextStep (initalVelocity, stepDistance, force, theta, mass)%, resistance)
    %velocity = sqrt(initalVelocity^2 + 2*accelerationGivenForceAndGradient(force, theta, mass, initalVelocity, resistance)*stepDistance);
%     velocity = 
end
