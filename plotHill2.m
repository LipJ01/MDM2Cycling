function [x,y,gradients,distances]=plotHill2%(gradients,distances)

%thetas is a vector of the angles for the different sections of the hill,
%and distancePerStep is a distance in metres

stage = table2array(readtable('stage15.csv'));
global gradients;
global distances;
gradients = stage(2:end,7);
distances = stage(2:end,6);

%thetas = gradients*(pi/200);
thetas = gradients;

x=zeros(size(thetas));

for i=1:length(thetas) 
    x(i+1)=x(i)+distances(i)*cos(thetas(i));
end

y=zeros(size(thetas));

for i=1:length(thetas) 
    y(i+1)=y(i)+distances(i)*sin(thetas(i));
end

y=y+stage(1,4);

plot(x,y, 'Linewidth', 2)

set(gca,'TickLabelInterpreter','latex') 

xlabel('Horizontal Distance Along Course (m)', 'Interpreter', 'latex');
ylabel('Elevation (m)', 'Interpreter', 'latex');
title('Elevation Profile of the "Grand Colombier", 2020 Stage 15', 'Interpreter', 'latex');

grid on

end