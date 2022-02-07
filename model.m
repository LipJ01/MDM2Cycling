
% Cyclist riding in stages up a mountain.

forces = [400 400 400 400 400];
Aeq = [];
Beq = [];
% wholeSim(forces)
maximumForce = 500;
x = fmincon(@(forces) wholeSim(forces),forces, [1 1 1 1 1],2400,Aeq,Beq, ones(length(forces)) * 0, ones(length(forces)) * maximumForce)

function time = wholeSim(forces)
    distancePerStep = 100;
    massOfRiderAndBike = 70;
    resistanceConstant = 0.5;
    thetas = [0 10 10 10 0];
    energy = [400000 0 0 0 0 0];
    resultantSpeeds = [0 0 0 0 0 0];
    timePerStage = [0 0 0 0 0];
    
    for i=1:length(thetas) 
%         fprintf("step");
        resultantSpeeds(i+1) = velocityAtNextStep(resultantSpeeds(i), distancePerStep, forces(i),thetas(i), massOfRiderAndBike, resistanceConstant);
        energy(i+1) = energy(i) - forces(i)*distancePerStep;
    end
%     resultantSpeeds
    for i=1:length(thetas)
        timePerStage(i) = timeFromVelocitys(resultantSpeeds(i),resultantSpeeds(i+1), distancePerStep);
    end
%     timePerStage
%     energy
    time = sum(timePerStage);
end
function time = timeFromVelocitys(initalVelocity, finalVelocity, stepDistance)
    time = (2*stepDistance)/(initalVelocity+finalVelocity);
end

function acceleration = accelerationGivenForceAndGradient (force, theta, mass, initalVelocity, resistance)
    acceleration = (force - sin(theta)*mass*9.81 - initalVelocity^2*resistance)/mass;
end

function velocity = velocityAtNextStep (initalVelocity, stepDistance, force, theta, mass, resistance)
    velocity = sqrt(initalVelocity^2 + 2*accelerationGivenForceAndGradient(force, theta, mass, initalVelocity, resistance)*stepDistance);
end

