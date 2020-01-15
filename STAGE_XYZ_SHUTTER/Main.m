close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     STAGES XYZ + SHUTTER
%
%  GRUPO DE FISICA NUCLEAR - UCM
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%clear all;
%fclose all;

arduinoport='COM12'; % for shutter
velmexport='COM13'; % for stages

if exist('s1') && exist('s2')
else
    s1 = serial(arduinoport,'BaudRate',9600);
    s2 = serial(velmexport,'BaudRate',9600);
end
if strcmp(s1.Status,'closed') || strcmp(s2.Status,'closed')
    instrreset
    
    s1 = serial(arduinoport,'BaudRate',9600);
    s2 = serial(velmexport,'BaudRate',9600);
    
    fopen(s1); disp('Shutter connected');
    fopen(s2); disp('Stages connected');
    
    % Initialize stage
    disp('Initializing')
    fprintf(s2,'F,C,setM1M3,S1M3000,A1M1,setL1M1,R');
    fprintf(s2,'F,C,setM2M3,S2M3000,A2M1,setL2M1,R');
    fprintf(s2,'F,C,setM3M3,S3M3000,A3M1,setL3M1,R');
    
end

homing=input('Homing? (0 No, 1 Yes): ');
if homing==1
    % Set homing
    Homing(s2)
end

center=input('Search Reference position? (0 No, 1 Yes): ');
if center==1
    % Searching the center (3 stages)
    SearchCenter(s2);
end


auto=input('Auto (0 -> No  1 -> yes): ');


% Scanning
if auto==0
nxs=input('How many X positions: '); 
nys=input('How many Y positions: ');
plate=input('Plate: (1 (96 Wells) 2 (8 Wells) 3 (500 uL Epp.) 4 (2 mL Epp.)');
scan_mode=input('Scan mode: (1 (flash) 2 (normal)');
if scan_mode==2
    %shutter_timeon=input('Time ON for Shutter (seconds):');
    %Configure_shutter(s1,'t',shutter_timeon);
    Shutter_mode='n';
elseif scan_mode==1
    Shutter_mode='f';
end
else
   nxs=5; nys=4; plate=3; Shutter_mode='f'; 
end
impar=input('Which rows: (1 (odd) 2 (even)');

infostring=input('Introduce info strign: ', 's');

% log output ...
acqfolder=strcat('acq/',datestr(now,'yyyymmdd_HHMM'));
mkdir(acqfolder);
fid4=fopen(strcat(acqfolder,'/info.txt'),'w');
fprintf(fid4,'%s',infostring);
fclose(fid4);

Scan(s2,s1,nxs,nys,Shutter_mode,acqfolder,plate,impar);

return

% Close serials
disp('Closing serials');
fclose(s1);delete(s1); disp('Arduino disconnected');
fclose(s2);delete(s2);disp('Stages disconnected');
clear s1,clear s2
