clc
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Main function for Matlab/Unreal connection measure primaries
%% D:\VR_Projects\CalibrationHMD unity
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save_filename = 'Calibration_UnityStandard_CS2000_Pimax_30_03_2023.mat';

cs2000 = CS2000;
% Synchronization
sync = CS2000_Sync('Internal', 90);
cs2000.setSync(sync);

%Connection with Unity
tcpipClient = tcpip('127.0.0.1',55001,'NetworkRole','Client');
set(tcpipClient,'Timeout',30);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  RED CHANNEL
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
j=1;
R=0;G=0;B=0;

for R=0:5:255
    tic
    fopen(tcpipClient);
    a=R+","+G+","+B;
    fwrite(tcpipClient,a);
    fclose(tcpipClient);
    disp(a);
    pause(2)
    

    Red(j) = cs2000.measure;
    disp(Red(j).color.xyY')
    t_time = toc;
    disp(['It took ', num2str(t_time), ' s']);
    disp '-------------------------------------------'
    j=j+1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  GREEN CHANNEL
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
j=2;
R=0;G=0;B=0;
Green(1)=Red(1);
for G=5:5:255
    tic
    fopen(tcpipClient);
    a=R+","+G+","+B;
    fwrite(tcpipClient,a);
    fclose(tcpipClient);
    disp(a);
    pause(2)
   
    Green(j) = cs2000.measure;
    disp(Green(j).color.xyY')
    t_time = toc;
    disp(['It took ', num2str(t_time), ' s']);
    disp '-------------------------------------------'
    j=j+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  BLUE CHANNEL
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
j=2;
R=0;G=0;B=0;
Blue(1)=Red(1);
for B=5:5:255
    tic
    fopen(tcpipClient);
    a=R+","+G+","+B;
    fwrite(tcpipClient,a);
    fclose(tcpipClient);
    disp(a);
    pause(2)

    Blue(j) = cs2000.measure;
    disp(Blue(j).color.xyY')
    t_time = toc;
    disp(['It took ', num2str(t_time), ' s']);
    disp '-------------------------------------------'
    j=j+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Gray CHANNEL
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
j=2;
R=0;G=0;B=0;
Gray(1)=Red(1);
for B=5:5:255
    tic
    R = B; G = B;
    fopen(tcpipClient);
    a=R+","+G+","+B;
    fwrite(tcpipClient,a);
    fclose(tcpipClient);
    disp(a);
    pause(2)

    Gray(j) = cs2000.measure;
    disp(Gray(j).color.xyY')
    t_time = toc;
    disp(['It took ', num2str(t_time), ' s']);
    disp '-------------------------------------------'
    j=j+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  WHITE POINT
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
j=1;
R=255;G=255;B=255;
tic
fopen(tcpipClient);
    a=R+","+G+","+B;
    fwrite(tcpipClient,a);
    fclose(tcpipClient);
    disp(a);
    pause(2)

White(j) = cs2000.measure;
disp(White(j).color.xyY')
t_time = toc;
disp(['It took ', num2str(t_time), ' s']);
disp '-------------------------------------------'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Validation predefined values
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load PredefinedRGB.mat
% 
j=1;
for i=1:length(PredefinedRGB)
    tic
    R=double(PredefinedRGB(i,1));
    G=double(PredefinedRGB(i,2));
    B=double(PredefinedRGB(i,3));
    fopen(tcpipClient);
    a=R+","+G+","+B;
    fwrite(tcpipClient,a);
    fclose(tcpipClient);
    disp(a);
    pause(2)

    Validation_rand(j) = cs2000.measure;
    disp(Validation_rand(j).color.xyY')
    t_time = toc;
    disp(['It took ', num2str(t_time), ' s']);
    disp '-------------------------------------------'
    j=j+1;
end

%Delete from Workspace
clear tcpipClient;


save(save_filename, 'Red', 'Blue', 'Green', 'Gray', 'White', ...
                    'Validation_rand', 'PredefinedRGB', '-v7.3');
       
message = 'disconnected';

disp(message);
  

