function [cps] = acquire()
    command='C:\Users\SEPUCM\Dropbox\pisepucm\PRONTO\ps6000\x64\Debug\ps6000Con.exe &'; % Command to run PicoScope
    %cpsfile='.\petcps.txt';
    status=system(command);
    %fid=fopen(cpsfile,'r');
    %cps=fscanf(fid,'%d');
    %fclose(fid);
end

