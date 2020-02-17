%% 1. Open and test instruments
clear COMShutter COMStage
arduinoport='/dev/tty.usbserial-14330'; % for shutter
velmexport='/dev/tty.usbserial-AH061E3D'; % for stages

if  ~exist('COMStage') || ~exist('COMShutter') ||  strcmp(COMStage.Status,'closed') || strcmp(COMShutter.Status,'closed')
    instrreset
    COMShutter = serial(arduinoport,'BaudRate',9600);
    COMStage = serial(velmexport,'BaudRate',9600);
    
    fopen(COMShutter); disp('Shutter connected');
    fopen(COMStage); disp('Stages connected');
    
    fprintf(COMStage,'V');
    pause(.1); % wait for 100ms
    
    % see if the controller connected properly
    readStatus(COMStage);
    
    % Initialize stage
    disp('Initializing at speed 6000 and acceleration 50')
    fprintf(COMStage,'F,C,setM1M3,S1M6000,A1M50,setL1M1,R');
    fprintf(COMStage,'F,C,setM2M3,S2M6000,A2M50,setL2M1,R');
    fprintf(COMStage,'F,C,setM3M3,S3M6000,A3M50,setL3M1,R');
    
    readStatus(COMStage);
    
    set(COMStage,'Timeout',30);
    
end

%% Test shutter
pause(1);
Shutter(COMShutter, 'f', 1)

%% Test stage
[stageStatus, posX, posY, posZ] = monitorStatus(COMStage)