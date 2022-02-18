function plotHill(thetas,distancePerStep)

%thetas is a vector of the angles for the different sections of the hill,
%and distancePerStep is a distance in metres

x=zeros(size(thetas));

for i=1:length(thetas) 
    x(i+1)=x(i)+distancePerStep*cos(thetas(i));
end

y=zeros(size(thetas));

for i=1:length(thetas) 
    y(i+1)=y(i)+distancePerStep*sin(thetas(i));
end

plot(x,y)

end