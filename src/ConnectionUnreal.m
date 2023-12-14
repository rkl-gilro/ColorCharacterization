clc
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Main function for Matlab/Unreal connection measure primaries
%% D:\VR_Projects\CalibrationHMD unreal
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save_filename = 'Calibration_UnrealStandard_Pimax_30_03_2023.mat';

HTC=0;
Pimax=1;
Varjo=0;

if(HTC==1)
    threshold=0.2;
else
    threshold=0.1;
end

pause(2);
cs2000 = CS2000;
% Synchronization
sync = CS2000_Sync('Internal', 90);
cs2000.setSync(sync);

% %% Create the connection
t = tcpip('127.0.0.1', 8890);
fopen(t);

xCompare=1000;
yCompare=-1;
zCompare=1000;

range = (0:5:255)./255;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Measure Red channel
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cont=0;
saturate=0;
i=1;
while i < length(range) && saturate==0
    
    tic
    

    fwrite(t, "Value:" + range(i) + "," + 0 + "," + 0);
    a = fscanf(t, '%s\n');
    
    while ~strcmp(a, "SHOT")
        a = fscanf(t, '%s\n');
        fwrite(t, "Value:" + range(i) + "," + 0 + "," + 0);
    end
    
    disp("Value:" + range(i) + "," + 0 + "," + 0)
    Red(i) = cs2000.measure;
    xyzObtain=Red(i).color.XYZ';
    %Pimax: add ||xyzObtain(2)>20
    while(cont<3&&xyzObtain(2)-yCompare<threshold)
        fwrite(t, "Value:" + 1 + "," + 1 + "," + 1);
        a = fscanf(t, '%s\n');
        while ~strcmp(a, "SHOT")
            a = fscanf(t, '%s\n');
            fwrite(t, "Value:" + 1 + "," + 1 + "," + 1);
        end
        desperdiciar=cs2000.measure;
        fwrite(t, "Value:" + range(i) + "," + 0 + "," + 0);
        a = fscanf(t, '%s\n');
        while ~strcmp(a, "SHOT")
            a = fscanf(t, '%s\n');
            fwrite(t, "Value:" + range(i) + "," + 0 + "," + 0);
        end
        Red(i) = cs2000.measure;
        xyzObtain=Red(i).color.XYZ';
        cont=cont+1;
        if cont>1
            saturate=1;
            Red(i:length(range))=Red(i);
        end
    end
    
    
    yCompare=xyzObtain(2);
    
    
    disp(Red(i).color.xyY')
    
    
    t_time = toc;
    disp(['It took ', num2str(t_time), ' s']);
    disp '-------------------------------------------'
    i=i+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Measure Green channel
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cont=0;
saturate=0;
i=2;
Green(1)=Red(1);
yCompare=-1;
while i<length(range)&& saturate==0
    
    tic
    
    fwrite(t, "Value:" + 0 + "," + range(i) +  "," + 0);
    a = fscanf(t, '%s\n');
    
    while ~strcmp(a, "SHOT")
        a = fscanf(t, '%s\n');
        fwrite(t, "Value:" + 0 + "," + range(i) +  "," + 0);
    end
    
    disp("Value:" + 0 + "," + range(i) +  "," + 0)
    Green(i) = cs2000.measure;
    xyzObtain=Green(i).color.XYZ';
    %%Pimax: add ||xyzObtain(2)>20
    while(cont<3&&xyzObtain(2)-yCompare<threshold)
        fwrite(t, "Value:" + 1 + "," + 1 + "," + 1);
        a = fscanf(t, '%s\n');
        while ~strcmp(a, "SHOT")
            a = fscanf(t, '%s\n');
            fwrite(t, "Value:" + 1 + "," + 1 +  "," + 1);
        end
        desperdiciar=cs2000.measure;
        fwrite(t, "Value:" + 0 + "," + range(i) +  "," + 0);
        a = fscanf(t, '%s\n');
        while ~strcmp(a, "SHOT")
            a = fscanf(t, '%s\n');
            fwrite(t, "Value:" + 0 + "," + range(i) +  "," + 0);
        end
        Green(i) = cs2000.measure;
        xyzObtain=Green(i).color.XYZ';
        cont=cont+1;
        if cont>1
            saturate=1;
            Green(i:length(range))=Green(i);
        end
    end
    
    yCompare=xyzObtain(2);
    
    
    disp(Green(i).color.xyY')

    
    t_time = toc;
    disp(['It took ', num2str(t_time), ' s']);
    disp '-------------------------------------------'
    i=i+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Measure Blue channel
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Blue(1)=Red(1);
yCompare=-1;
cont=0;
saturate=0;
i=2;
while i<length(range)&& saturate==0
    
    tic
    
    fwrite(t, "Value:" + 0 + "," + 0 + "," + range(i));
    a = fscanf(t, '%s\n');
    
    while ~strcmp(a, "SHOT")
        a = fscanf(t, '%s\n');
        fwrite(t, "Value:" + 0 + "," + 0 + "," + range(i));
    end
    
    disp("Value:" + 0 + "," + 0 + "," + range(i))
    Blue(i) = cs2000.measure;
    xyzObtain=Blue(i).color.XYZ';
    %Pimax: add ||xyzObtain(2)>20
    while(cont<3&&xyzObtain(2)-yCompare<threshold/2)
        fwrite(t, "Value:" + 1 + "," + 1 + "," + 1);
        a = fscanf(t, '%s\n');
        while ~strcmp(a, "SHOT")
        a = fscanf(t, '%s\n');
        fwrite(t, "Value:" + 1 + "," + 1 + "," + 1);
        end
        desperdiciar=cs2000.measure;
        fwrite(t, "Value:" + 0 + "," + 0 + "," + range(i));
        a = fscanf(t, '%s\n');
        while ~strcmp(a, "SHOT")
            a = fscanf(t, '%s\n');
            fwrite(t, "Value:" + 0 + "," + 0 + "," + range(i));
        end
        Blue(i) = cs2000.measure;
        xyzObtain=Blue(i).color.XYZ';
        cont=cont+1;
        if cont>1
            saturate=1;
            Blue(i:length(range))=Blue(i);
        end
    end
    
    yCompare=xyzObtain(2);
    
    disp(Blue(i).color.xyY')

    
    t_time = toc;
    disp(['It took ', num2str(t_time), ' s']);
    disp '-------------------------------------------'
    i=i+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Measure Gray channel
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Gray(1)=Red(1);
yCompare=-1;
cont=0;
saturate=0;
i=2;
while i<length(range)&& saturate==0
    
    tic
    
    fwrite(t, "Value:" + range(i) + "," + range(i) + "," + range(i));
    a = fscanf(t, '%s\n');
    
    while ~strcmp(a, "SHOT")
        a = fscanf(t, '%s\n');
        fwrite(t, "Value:" + range(i) + "," + range(i) + "," + range(i));
    end
    
    disp("Value:" + range(i) + "," + range(i) + "," + range(i))
    Gray(i) = cs2000.measure;
    xyzObtain=Gray(i).color.XYZ';
    
    while(cont<3&&xyzObtain(2)-yCompare<threshold)
        fwrite(t, "Value:" + 1 + "," + 1 + "," + 1);
        a = fscanf(t, '%s\n');
        while ~strcmp(a, "SHOT")
            a = fscanf(t, '%s\n');
            fwrite(t, "Value:" + 1 + "," + 1 + "," + 1);
        end
        desperdiciar=cs2000.measure;
        fwrite(t, "Value:" + range(i) + "," + range(i) + "," + range(i));
        a = fscanf(t, '%s\n');
        while ~strcmp(a, "SHOT")
            a = fscanf(t, '%s\n');
            fwrite(t, "Value:" + range(i) + "," + range(i) + "," ...
                + range(i));
        end
        Gray(i) = cs2000.measure;
        xyzObtain=Gray(i).color.XYZ';
        cont=cont+1;
        if cont>1
            saturate=1;
            Gray(i:length(range))=Gray(i);
        end
    end
    
    yCompare=xyzObtain(2);
   
    disp(Gray(i).color.xyY')

    
    t_time = toc;
    disp(['It took ', num2str(t_time), ' s']);
    disp '-------------------------------------------'
    i=i+1;
end
White = Gray(end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Validation predefined values
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yCompare=-1;
load PredefinedRGB.mat
cont=0;
clear range

range = double(PredefinedRGB)./255;
for i = 1:size(PredefinedRGB, 1)
    
    tic
    
    fwrite(t, "Value:" + range(i, 1) + "," + range(i, 2) + "," ...
        + range(i, 3));
    a = fscanf(t, '%s\n');
    
    while ~strcmp(a, "SHOT")
        a = fscanf(t, '%s\n');
        fwrite(t, "Value:" + range(i, 1) + "," + range(i, 2) + ...
            "," + range(i, 3));
    end
    
    disp("Value:" + range(i, 1) + "," + range(i, 2) + "," + range(i, 3))
    Validation_rand(i) = cs2000.measure;
    xyzObtain=Validation_rand(i).color.XYZ';
    
    while(cont<3&&(abs(xyzObtain(1)-xCompare)<=0.8)&&...
            (abs(xyzObtain(2)-yCompare)<=0.8)&&...
            (abs(xyzObtain(3)-zCompare)<=0.8))
        fwrite(t, "Value:" + 1 + "," + 1 + "," + 1);
        a = fscanf(t, '%s\n');
        while ~strcmp(a, "SHOT")
            a = fscanf(t, '%s\n');
            fwrite(t, "Value:" + 1 + "," + 1 + "," + 1);
        end
        desperdiciar=cs2000.measure;
        fwrite(t, "Value:" + range(i, 1) + "," + range(i, 2) + ...
            "," + range(i, 3));
        a = fscanf(t, '%s\n');
        while ~strcmp(a, "SHOT")
            a = fscanf(t, '%s\n');
            fwrite(t, "Value:" + range(i, 1) + "," + range(i, 2) + ...
                "," + range(i, 3));
        end
        Validation_rand(i) = cs2000.measure;
        xyzObtain=Validation_rand(i).color.XYZ';
        cont=cont+1;
    end
    
    xCompare=xyzObtain(1);
    yCompare=xyzObtain(2);
    zCompare=xyzObtain(3);
    disp(Validation_rand(i).color.xyY')
    cont=0;
    
    t_time = toc;
    disp(['It took ', num2str(t_time), ' s']);
    disp '-------------------------------------------'
    
end




save(save_filename, 'Red', 'Blue', 'Green', 'Gray', 'White', ...
                    'Validation_rand', 'PredefinedRGB', '-v7.3');

                
fwrite(t,"DONE:0");