stage15 = table2array(readtable('stage15.csv'));
gradsPercent = [];
cumuDist = 0;
stepDist = 0;
lastElevation = stage15(1,4);
distancePerStep = 1000;
% For every point in the data of the stage
for i = 1:length(stage15) 
%     record how long the rider has had to go.
    stepDist = stepDist + stage15(i,6);
    cumuDist = cumuDist + stage15(i,6);
%     everytime the rider has traveled a kilometer or more...
    if stepDist > distancePerStep
%         Calculate the percentage slope the rider has had to go up
       gradsPercent(end+1)  = (stage15(i,4)-lastElevation)/stepDist;
%        record the height at the end of that segment.
       lastElevation = stage15(i,4);
%        Say a kilometer (ish) has gone.
       stepDist = stepDist - distancePerStep;
    end
    
end

gradsRad = zeros(1,length(gradsPercent));
for i = 1:length(gradsPercent)
	gradsRad(i) = atan(gradsPercent(i));
end
