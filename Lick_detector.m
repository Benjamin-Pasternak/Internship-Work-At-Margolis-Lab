%this script can onlyrun if you have already generated a lick_data file
%which is created by the Read_tdms script or somthing equivilant. So this
%checks if you have that file already and if you dont

ran_Read_tdms = input('if you ran Read_tdms input 1, if lick_data.mat already exists in that file input 0');
if ran_Read_tdms == 1
    cd(newfolder)
else
    clear
    clc
[newfolder] = uigetdir;
cd(newfolder)
load('lick_data.mat')
end
%-------------------------------------------------------------------------
%this step we are generating the unique name to store variables
slashes = [strfind(newfolder, '\')];
if strfind(newfolder, 'm1')>=1
namePT1 = [newfolder(slashes(5)+1:slashes(6)-1)];
namePT2 = [newfolder(slashes(6)+1:slashes(7)-1)];
nameFull = [namePT1,'_', namePT2];
elseif strfind(newfolder, 'PV')>=1
    namePT1 = [newfolder(slashes(6)+1:slashes(7)-1)];
namePT2 = [newfolder(slashes(7)+1:slashes(8)-1)];
nameFull = [namePT1,'_', namePT2];
end
%-----------------------------------------------------------------------

%saving useful information like grace period, thresholds, baseline etc. to
%be used later in the script
x=input('input a grace period');
y=input('input an upper thrshold');
z=input('input a lower theshold');
led=input('if led session input 1 else input 0');


if led == 1
    ap= input('if only am is led input 1, if only pm is led input 2, if both are led then input 3');
    Norm_baseline_bottom= 0;
    %This is the last trial without stimulation
    Norm_baseline_top=50;
end

%----------------------------------------------------------------------------------------------

%performing the initial peak analysis ( isolating the peaks above noise)

b=lick_data;
[m,n]=size(lick_data);
peaks_and_vallies_above_and_below_noise=[];
Lick_log=[];
Times=[];%intended for use as a global time tracker
C=zeros(1,4); % gives us the
for i=1:m
    Times_per_trial=[];
    for j=1:n
        if b(i,j)>y       %slightly above the noise reading... meant to weed out background noise when finding the peaks and other stuff.
            %there might be an issue with the time calculation
            time=j.*0.01;%-3.15;%422;
            Times_per_trial=[Times_per_trial;time];
            Times=[Times;time];
            peaks_and_vallies_above_and_below_noise=[peaks_and_vallies_above_and_below_noise;i,time,lick_data(i,j)];
        elseif b(i,j)<z  %2.48   %2.5
            time=j.*0.01;%-3.15;%422;
            Times_per_trial=[Times_per_trial;time];
            Times=[Times;time];
            peaks_and_vallies_above_and_below_noise=[peaks_and_vallies_above_and_below_noise;i,time,lick_data(i,j)];

        end
    end
end

%----------------------------------------------------------------------------------------------
B=zeros(length(Times),1);

%THIS CREATES THE 4TH COL IN PEAKS AND VALLIES SO WE CAN DETECT LICKS

count=1;
countodd=1;

if mod(length(Times),2)~=0
    for k=2:2:(length(Times-1))
        if Times(k)-Times(k-1)<=0.5
            B(k)=1;
            B(k-1)=1;
        else
            B(k)=0;
            count=count+1;

        end

    end
    for g=3:2:length(Times)
        if Times(g)-Times(g-1)<=0.5
            B(g)=1;
            B(g-1)=1;
        else
            B(g)=0;
            count=countodd+1;
        end
    end

elseif mod(length(Times),2)==0
    for p=2:2:length(Times)
        if Times(p)-Times(p-1)<=0.5
            B(p)=1;
            B(p-1)=1;
        else
            B(p)=0;
            count=count+1;

            %B(p-1)=0;

        end
        for j=3:2:length(Times-1)
            if Times(j)-Times(j-1)<=0.5
                B(j)=1;
                B(j-1)=1;
            else
                B(j)=0;
                count=countodd+1;

            end
        end
    end
end



%----------------------------------------------------------------------------------------------
%THIS BLOCK TAKES INTO ACCOUNT THE GRACE PERIOD WHEN REPRESENTING LICK_LOG
%NEGATE THIS PART IF IT IS A LICK TRIAL !!!

for i=2:2:length(B)
    for j=1
        if Times(i,j)<= x%0.7%for tests 0.5
            B(i,j)=0;
        end
    end
end

peaks_and_vallies_above_and_below_noise=[peaks_and_vallies_above_and_below_noise,B];
[m,n]=size(peaks_and_vallies_above_and_below_noise);

%----------------------------------------------------------------------------------------------

%IF THE DIFFERENCE BETWEEN ADJACENT TIMES IS LESS THAN A CERTAIN VALUE THEY
%ARE PART OF THE SAME LICK???

if mod(length(peaks_and_vallies_above_and_below_noise),2)~=0
    for k=2:2:length(peaks_and_vallies_above_and_below_noise-1)
        for i=2
            if peaks_and_vallies_above_and_below_noise(k,i)-peaks_and_vallies_above_and_below_noise(k-1,i)<=0.5 && peaks_and_vallies_above_and_below_noise(k,i)>=.5
                peaks_and_vallies_above_and_below_noise= [peaks_and_vallies_above_and_below_noise(1:k-1,:); C; peaks_and_vallies_above_and_below_noise(k,:); C; peaks_and_vallies_above_and_below_noise(k+1:end,:)];
            end
            for g=3:2:length(peaks_and_vallies_above_and_below_noise-1)
                if peaks_and_vallies_above_and_below_noise(g,i)-peaks_and_vallies_above_and_below_noise(g-1,i)<=0.5 && peaks_and_vallies_above_and_below_noise(g,i)>=.5
                    peaks_and_vallies_above_and_below_noise= [peaks_and_vallies_above_and_below_noise(1:g-1,:); C; peaks_and_vallies_above_and_below_noise(g,:); C; peaks_and_vallies_above_and_below_noise(g+1:end,:)];
                end
            end
        end
    end
end
if mod(length(peaks_and_vallies_above_and_below_noise),2)==0
    for k=2:2:length(peaks_and_vallies_above_and_below_noise)
        for i=2
            if peaks_and_vallies_above_and_below_noise(k,i)-peaks_and_vallies_above_and_below_noise(k-1,i)<=0.5 && peaks_and_vallies_above_and_below_noise(k,i)>=.5
                peaks_and_vallies_above_and_below_noise= [peaks_and_vallies_above_and_below_noise(1:k-1,:); C; peaks_and_vallies_above_and_below_noise(k,:); C; peaks_and_vallies_above_and_below_noise(k+1:end,:)];
            end
            for g=3:2:length(peaks_and_vallies_above_and_below_noise-1)
                if peaks_and_vallies_above_and_below_noise(g,i)-peaks_and_vallies_above_and_below_noise(g-1,i)<=0.5 && peaks_and_vallies_above_and_below_noise(g,i)>=.5
                    peaks_and_vallies_above_and_below_noise= [peaks_and_vallies_above_and_below_noise(1:g-1,:); C; peaks_and_vallies_above_and_below_noise(g,:); C; peaks_and_vallies_above_and_below_noise(g+1:end,:)];
                end
            end
        end
    end
end

%----------------------------------------------------------------------------------------------

%Reaply limitations of grace period to dataset for acuracy
[m,n]=size(peaks_and_vallies_above_and_below_noise);
for i=1:m
    for j=2
        if peaks_and_vallies_above_and_below_noise(i,j)<= x%0.7%for tests0.5
            peaks_and_vallies_above_and_below_noise(k,4)=0;
        end
    end
end


%----------------------------------------------------------------------------------------------
[U,Q]=size(lick_data);


%This next block of code adds a row of zeros after last item in
%each trial in peaks_and_vallies_above_and and is a final step in implementing the binerization algorithm

count=1;
for v=1:m %+(U-1)
    for h=1
        [m,n]=size(peaks_and_vallies_above_and_below_noise);
        if count==1 && peaks_and_vallies_above_and_below_noise(v,h)~= count
            count=count+1;
            peaks_and_vallies_above_and_below_noise= [peaks_and_vallies_above_and_below_noise(1:v-1,:); C; peaks_and_vallies_above_and_below_noise(v:end,:)];
        elseif peaks_and_vallies_above_and_below_noise(v,h)~= count && peaks_and_vallies_above_and_below_noise(v,h)>count
            count=count+1;
            peaks_and_vallies_above_and_below_noise= [peaks_and_vallies_above_and_below_noise(1:v-1,:); C; peaks_and_vallies_above_and_below_noise(v:end,:)];
        end
    end
end


for g=2:m%+(U-1)
    for e=n:n
        [m,n]=size(peaks_and_vallies_above_and_below_noise);
        if g==2 && peaks_and_vallies_above_and_below_noise(g-1,e)==1
            Lick_log=[Lick_log;peaks_and_vallies_above_and_below_noise(g-1,1),peaks_and_vallies_above_and_below_noise(g-1,2)];

        elseif peaks_and_vallies_above_and_below_noise(g,e)==1 && peaks_and_vallies_above_and_below_noise(g-1,e)==0
            Lick_log=[Lick_log;peaks_and_vallies_above_and_below_noise(g,1),peaks_and_vallies_above_and_below_noise(g,2)];
        end
    end
end

%----------------------------------------------------------------------------------------------
Final identification of licks following binerization procedure 
[A,B]=size(Lick_log);
count11=0;
count12=0;
for i=1:A
    for j=1
        if Lick_log(i,j)<=50 && Lick_log(i,2)>=3.15 && Lick_log(i,2)<=5.15
            count11=count11+1;
        elseif Lick_log(i,j)>50 && Lick_log(i,2)>=3.15 && Lick_log(i,2)<=5.15
            count12=count12+1;
        end
    end
end

%z2 is below baseline z3 is above baseline
[B,G]=size(Lick_log);
    Z=[Lick_log(:,2,:)];
    counting=0;
    Z2=[];
    Z3=[];
    for i = 1:B
        for j=1
            if Lick_log(i,j)<=Norm_baseline_top
                Z2=[Z2, Lick_log(i,2)];
            else
                Z3=[Z3, Lick_log(i,2)];
            end
        end
    end

save(nameFull, 'Lick_log', 'Z2', 'Z3','x','y', 'z', 'Norm_baseline_bottom', 'Norm_baseline_top' )
