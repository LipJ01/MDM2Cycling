massOfRiderAndBike = 70;
resistanceConstant = 0.19;
averageRiderPower = 325;
gradients = gradsRad;
distances = ones(1,length(gradients)) * 1000;
guessPowers = ones(1, length(gradients)) * averageRiderPower;

global Speeds
Speeds = zeros(1, length(gradients));

initalGuess = Simulation(guessPowers,distances,gradients,massOfRiderAndBike,resistanceConstant);

totalEnergy = length(gradients) * averageRiderPower;
Aeq = [];
Beq = [];
maximumPower = 500;

% fmincon algorithm choices: 'interior-point' (default), 'trust-region-reflective', 'sqp', 'sqp-legacy' (optimoptions only), 'active-set'
options = optimoptions('fmincon','MaxFunctionEvaluations',1e+5,'PlotFcn','optimplotfval','Algorithm','interior-point');
% x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
x = fmincon(@(powers) Simulation(powers, distances, gradients, massOfRiderAndBike, resistanceConstant), guessPowers, ones(1,length(gradients)),totalEnergy,Aeq,Beq, zeros(1,length(gradients)), ones(1,length(gradients)) * maximumPower,[],options)


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

function force = RequiredForce(gradient, mass, velocity, resistance)
%     Somehow need to decide on a rough velocity... then use it to find out
%     the velocity...
    force = max(sin(gradient)*mass*9.81 + velocity^2*resistance, 0);
%     force = max(sin(gradient)*mass*9.81, 0);
end

function velocity = velocityAtNextStep (initalVelocity, stepDistance, power, gradient, mass, resistance)
    guess = min(power / RequiredForce(gradient, mass, initalVelocity, resistance), 26);
    previousGuess = initalVelocity;
    breakloop = true;
    while breakloop % Shagged it here.
        guess = min(power / RequiredForce(gradient, mass, previousGuess, resistance), 26);
        guess = previousGuess
        if abs(guess - previousGuess) < 0.05
            breakloop = false;
        end
        previousGuess = guess;
    end
    
%     when power / required force (velocity) = velocity
    
    
    velocity = min(guess, 26); % MAXIMUM SPEED OF A RIDER DOWNHILL
%     squareVel = initalVelocity^2 + 2*accelerationGivenForceAndGradient(power, gradient, mass, initalVelocity, resistance)*stepDistance;
%     velocity = sqrt(squareVel); % deal with when rider comes to a holt during iterations
end
