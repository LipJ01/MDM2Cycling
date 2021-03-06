massOfRiderAndBike = 70;
resistanceConstant = 0.19;
averageRiderPower = 325;
gradients = gradsRad;
distances = ones(1,length(gradients)) * 1000;
%guessPowers = averageRiderPower.*rand(length(gradients),1);

guessPowers = averageRiderPower.*ones(length(gradients),1);

global Speeds
Speeds = zeros(1, length(gradients));

initalGuess = Simulation(guessPowers,distances,gradients,massOfRiderAndBike,resistanceConstant)

totalEnergy = length(gradients) * averageRiderPower;
Aeq = [];
Beq = [];
maximumPower = 1000;

length(gradients)
% fmincon algorithm choices: 'interior-point' (default), 'trust-region-reflective', 'sqp', 'sqp-legacy' (optimoptions only), 'active-set'
options = optimoptions('fmincon','MaxFunctionEvaluations',1e+5,'PlotFcn','optimplotfval','Algorithm','interior-point','OptimalityTolerance',1e-7,'StepTolerance',1e-10);
% x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
x = fmincon(@(powers) Simulation(powers, distances, gradients, massOfRiderAndBike, resistanceConstant), guessPowers, ones(1,length(gradients)),totalEnergy,Aeq,Beq, zeros(1,length(gradients)), ones(1,length(gradients)) * maximumPower,[],options);
finalTime = Simulation(x, distances, gradients, massOfRiderAndBike, resistanceConstant)

% Note that the previous winner of this stage did it in 16453 seconds.
% Simulation ( forces : vector, dists : vector, grads : vector, 
function time = Simulation(powers, dists, grads, mass, resistance)

    speeds = zeros(1,length(grads)+1);
    times = zeros(1,length(grads)+1);
    for i=1:length(grads) 
%         Calculate the average speed deviding power by force required
        speeds(i+1) = velocityAtNextStep(speeds(i), dists(i), powers(i), grads(i), mass, resistance);
        times(i) = timeFromVelocitys(speeds(i),speeds(i+1), dists(i));
    end
    global Speeds
    Speeds = speeds;
    time = sum(times);
end

function time = timeFromVelocitys(initalVelocity, finalVelocity, stepDistance)
    time = (2*stepDistance)/(initalVelocity+finalVelocity);
end

function new_velocity = VP(gradient, mass, velocity, resistance, power)
    new_velocity = (power / (sin(gradient)*mass*9.81 + velocity^2*resistance))-velocity;
end

function differential = DifVP(gradient, mass, velocity, resistance, power)
    differential = ( -2*power*resistance*velocity )/( (sin(gradient)*mass*9.81 + resistance*velocity^2)^2 )-1;
end

function velocity = velocityAtNextStep (initalVelocity, stepDistance, power, gradient, mass, resistance)
    guess = 1;
%     VP(gradient, mass, 0.1, resistance, power) % arbitary
%     differential = DifVP(gradient, mass, 0.1, resistance, power)
%     guess = 0.1 - VP(gradient, mass, 0.1, resistance, power) / (DifVP(gradient, mass, 0.1, resistance, power))
    previousGuess = max(initalVelocity, 0.2);
    breakloop = true;
    breakloopcount = 0;
    while breakloop % Shagged it here.
        breakloopcount = breakloopcount + 1;
        guess = abs(previousGuess - VP(gradient, mass, previousGuess, resistance, power) / (DifVP(gradient, mass, previousGuess, resistance, power)));
        if abs(guess - previousGuess) < 0.1
            breakloop = false;
        end
        if breakloopcount > 1000
            guess = previousGuess
            break
        end
        previousGuess = guess;
    end
    
%     when power / required force (velocity) = velocity
    
    velocity = min(guess, 26); % MAXIMUM SPEED OF A RIDER DOWNHILL
        
%     squareVel = initalVelocity^2 + 2*accelerationGivenForceAndGradient(power, gradient, mass, initalVelocity, resistance)*stepDistance;
%     velocity = sqrt(squareVel); % deal with when rider comes to a holt during iterations
end
