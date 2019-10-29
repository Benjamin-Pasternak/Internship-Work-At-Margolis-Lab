%This script averages behavior across sessions of mice

clc
clear
%----------------------------------------------------------------
%This snipit selects the folder you wish to run on
[newfolder] = uigetdir;
cd(newfolder)
filePattern1 = fullfile(newfolder);
% p = genpath(filePattern1);
% rr=[strfind(p, ';')];
%-------------------------------------------------------------------
%this line turns filepattern1 into a structure containing its subfolders
matfiles = dir(filePattern1);
%-----------------------------------------------------------
%This block traverses the structure and loads each mat file iterativly, and
%stores the important info as a cumulative vectors which represent the
%licks above and below the threshold for across all sessions
item1=[];
count = length(matfiles);
totalZ2= [];
totalZ3=[];
 for num = 3:count
     item = matfiles(num).name;
     load(item, '-mat');
     item1=[item];
     totalZ2 = [totalZ2, Z2];
     totalZ3 = [totalZ3, Z3];
 end
%------------------------------------------------------------------------------------
 %averaging the number of objects in each bin in a pre-determined interval
 %(0.1) so increase interval and count objects in each interval. averag
 %over number of objects in each file
 if strfind(item1, 'm')>1
 part1= [strfind(item1, 'm')];
 name = [item1(part1(1):part1(2)-2)];
 elseif strfind(item1, 'PV')>1
     part1= [strfind(item1, 'M')];
     part2= [strfind(item1,'PV')];
 name = [item1(part2(1):part1(1)-2)];
 end
 %--------------------------------------------------------------------
 %This block of code is used to compute the averages by segregating items
 %into bins of .1 sec, since we are only looking at 7 sec there will be 70
 %bins...
% maxZ2= ceil(max(totalZ2));
% maxZ3= ceil(max(totalZ3));
per_mouse_avg_below_baseline= [];
standard_error_of_mean_below=[];
for j =1.1:0.1:8
    temp = j-1;
    bincnt=0;
    for i=1:length(totalZ2)
        if totalZ2(i)>temp-0.1 && totalZ2(i)<=temp
            bincnt = bincnt+1;
        end
    end
    %divided first by 50 since there are 50 trials below baseline
    bincnt = bincnt/50;
    %divided by count which = number of sessions we are computing over
        bincnt = bincnt/count;
        per_mouse_avg_below_baseline=[per_mouse_avg_below_baseline, bincnt];
end

per_mouse_avg_above_baseline= [];

for j =1.1:0.1:8
    temp = j-1;
    bincnt=0;
    for i=1:length(totalZ3)
        if totalZ3(i)>temp-0.1 && totalZ3(i)<=temp
            bincnt = bincnt+1;
        end
    end
    bincnt = bincnt/77;
        bincnt = bincnt/count;
        per_mouse_avg_above_baseline=[per_mouse_avg_above_baseline, bincnt];
end

    save(name, 'per_mouse_avg_above_baseline', 'per_mouse_avg_below_baseline')
