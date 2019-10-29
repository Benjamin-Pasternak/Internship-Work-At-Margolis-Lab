
y=input('input an upper thrshold');
z=input('input a lower bIndexshold');
avg_matrix=[];
tot_avg=[];
%----------------------------------------------------------------------------------------------
    [newfolder]=uigetdir; %brings up gui to select parent folder
    cd(newfolder)
    FilePattern=fullfile(newfolder);
    p=genpath(FilePattern); % creates a string with full file paths of all sub folders seperates bIndexm with ;
    sepPath=[strfind(p,';')]; % find bIndex position of each file path by creating array of indexes where bIndexre is an ;
%----------------------------------------------------------------------------------------------
    %bIndex following defines which files we work on based on bIndex order bIndexy are saved in bIndex file system
    if mod(length(sepPath),2)~=0
        matrix=[];
        for i=2:2:length(sepPath)
            matrix=[matrix, p(sepPath(i)+1:sepPath(i+1)-1)];
        end
        bIndex=[strfind(matrix, 'R:')]; %bIndex defines the beginning index for all paths which originate on R: drive
    else
        matrix=[];
        for i=2:2:length(sepPath)-1
            matrix=[matrix, p(sepPath(i)+1:sepPath(i+1)-1)];
        end
        matrix=[matrix,  p(sepPath(length(sepPath)-1):sepPath(length(sepPath)))];
        bIndex=[strfind(matrix, 'R:')];
    end

%----------------------------------------------------------------------------------------------
    for i=1:length(bIndex-1) %reapeat for the number of files for this mouse on the day specified by user
    %THIS SEPERATES OUT bIndex DIFFERENT TDMS PATHWAYS STORED IN MATRIX FOR
    %bIndex PURPOSE OF CHANGIN bIndex DIRECTORY
    if length(bIndex)<8 %some days had lacking data and must account for this
        if i~=length(bIndex)
            curPath=[matrix(bIndex(i):bIndex(i+1)-1)];
        else
           curPath=[matrix(bIndex(i):length(matrix))];
        end

    elseif length(bIndex)==8
        if i~=8
        curPath=[matrix(bIndex(i):bIndex(i+1)-1)];
        else
            curPath=[matrix(bIndex(i):length(matrix))];
        end
    end
    cd(curPath)
    filePattern = fullfile(curPath, '*.tdms');
    tdmsfiles = dir(filePattern);
    readTDMS %function that reads TDMS files into cell array

%----------------------------------------------------------------------------------------------
    %the following is the peak analysis
    lData=lick_data;
    [m,n]=size(lick_data);
    avg_matrix_baseline=[];
    for i=1:50
        for j=1:n
            if lData(i,j)>y
                time=j.*0.01;
                avg_matrix_baseline=[avg_matrix_baseline; i,time,lick_data(i,j)];
            elseif lData(i,j)<z
                time=j.*0.01;
                avg_matrix_baseline=[avg_matrix_baseline; i,time,lick_data(i,j)];
            end
        end
    end
    avg_matrix_nbaseline=[];
    for i=51:m
        for j=1:n
            if lData(i,j)>y
                time=j.*0.01;
                avg_matrix_nbaseline=[avg_matrix_nbaseline; i,time,lick_data(i,j)];
            elseif lData(i,j)<z
                time=j.*0.01;
                avg_matrix_nbaseline=[avg_matrix_nbaseline; i,time,lick_data(i,j)];
            end
        end
    end
    avg_below=mean(avg_matrix_baseline(:,2));
    avg_above=mean(avg_matrix_nbaseline(:,2));
%----------------------------------------------------------------------------------------------

    %in future make it on a per mouse basis, for now it is total across all
    %mice differentiating between m1 and s1
    if length(bIndex-1)<8 && i<3
        avg_matrix=[avg_matrix;avg_below,avg_above,0,0];
    elseif length(bIndex-1)<8 && i>2
        avg_matrix=[avg_matrix;0,0,avg_below,avg_above];
    end
    if length(bIndex-1)>=8 && i<5
        avg_matrix=[avg_matrix;avg_below,avg_above,0,0];
    elseif length(bIndex-1)>=8 && i>4
        avg_matrix=[avg_matrix;0,0,avg_below,avg_above];
    end
    end

%----------------------------------------------------------------------------------------------
[A,B]=size(avg_matrix);
if A>4
    sum1=avg_matrix(1,1)+avg_matrix(2,1)+avg_matrix(3,1)+avg_matrix(4,1);
    sum1=sum1/4;
    sum2=avg_matrix(1,2)+avg_matrix(2,2)+avg_matrix(3,2)+avg_matrix(4,2);
    sum2=sum2/4;
    sum3=avg_matrix(5,3)+avg_matrix(6,3)+avg_matrix(7,3)+avg_matrix(8,3);
    sum3=sum3/4;
    sum4=avg_matrix(5,4)+avg_matrix(6,4)+avg_matrix(7,4)+avg_matrix(8,4);
    sum4=sum4/4;
    disp(sum1)
    disp(sum2)
    disp(sum3)
    disp(sum4)
end

if A<5
    sum1=avg_matrix(1,1)+avg_matrix(2,1);
    sum1=sum1/2;
    sum2=avg_matrix(1,2)+avg_matrix(2,2);
    sum2=sum2/2;
    sum3=avg_matrix(3,3)+avg_matrix(4,3);
    sum3=sum3/2;
    sum4=avg_matrix(3,4)+avg_matrix(4,4);
    sum4=sum4/2;
end
