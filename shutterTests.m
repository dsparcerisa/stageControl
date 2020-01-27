% Shutter tests

% 1. Connect
arduinoport='/dev/tty.usbserial-14340'; % for shutter

if exist('s1') 
else
    s1 = serial(arduinoport,'BaudRate',9600);
end

if strcmp(s1.Status,'closed')
    instrreset
    
    s1 = serial(arduinoport,'BaudRate',9600);
    
    fopen(s1); disp('Shutter connected');
        
end

% 2. Configure
A = 't';
t = 1.34;
Configure_shutter(s1,A,t)

% 3. Shot
A = 'n';
Ntimes = 1;
Shutter(s1,A,Ntimes)

fclose(s1);delete(s1); disp('Arduino disconnected');
