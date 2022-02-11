thetas = (pi/180) * [0,5,10,15,20];
distancePerStep = 50;
grads = tan(thetas);

x=zeros(size(thetas));

for i=1:length(thetas) 
    x(i+1)=x(i)+distancePerStep*cos(thetas(i));
end

y=zeros(size(thetas));

for i=1:length(thetas) 
    y(i+1)=y(i)+distancePerStep*sin(thetas(i));
end

plot(x,y)