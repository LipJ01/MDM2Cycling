function [x,y,gradients,distances]=plotHill2%(gradients,distances)

%thetas is a vector of the angles for the different sections of the hill,
%and distancePerStep is a distance in metres

stage2 = table2array(readtable('2-nice-nice.csv'));
global gradients;
global distances;
gradients = stage2(:,7);
distances = stage2(:,6);

thetas = gradients*(pi/200);

x=zeros(size(thetas));

for i=1:length(thetas) 
    x(i+1)=x(i)+distances(i)*cos(thetas(i));
end

y=zeros(size(thetas));

for i=1:length(thetas) 
    y(i+1)=y(i)+distances(i)*sin(thetas(i));
end

plot(x,y)


end