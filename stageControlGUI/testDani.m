%% First tests with linear stage
clear all
close all
instrreset

%% Connect
% arduinoport='/dev/tty.usbserial-A9EUCR0N'; % for shutter
velmexport='/dev/tty.usbserial-AH061E3D'; % for stages

% if ~exist('s1')
%     s1 = serial(arduinoport,'BaudRate',9600);
% end

if  ~exist('s2') ||  strcmp(s2.Status,'closed')
    instrreset
    
    % s1 = serial(arduinoport,'BaudRate',9600);
    s2 = serial(velmexport,'BaudRate',9600);
    
    % fopen(s1); disp('Shutter connected');
    fopen(s2); disp('Stages connected');
    
    fprintf(s2,'V');
    pause(.1); % wait for 100ms
    
    % see if the controller connected properly
    readStatus(s2);
    
    % Initialize stage
    disp('Initializing')
    fprintf(s2,'F,C,setM1M3,S1M6000,A1M50,setL1M1,R');
    fprintf(s2,'F,C,setM2M3,S2M6000,A2M50,setL2M1,R');
    fprintf(s2,'F,C,setM3M3,S3M6000,A3M50,setL3M1,R');
    
    readStatus(s2);
    
    set(s2,'Timeout',30);
    
end

%% Launch stageControl
stageControl(s2);

% %% 
% searchr = 0;
%  
% while searchr==0
%     searchr=input('Finished moving? (0 No, 1 Yes): ');
%     if searchr==0
%         motor=input('Motor? (1 (Z), 2 (X), 3 (Y)): ');
%         distance=input('Distance (mm)? (include sing)');
%         stepsZ=linearstage(s2,motor,sign(distance),abs(distance));
%     end
% end

% %% Where am I
%     
%     % see if the controller connected properly
%     readStatus(s2,'F,C,X,R');