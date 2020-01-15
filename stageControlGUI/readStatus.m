function motorResponse = readStatus(s2, in)
    if exist('in')
        disp(in)
        fprintf(s2, in);
        pause(0.1);        
    end
    if s2.BytesAvailable>0
        motorResponse = fscanf(s2,'%c',s2.BytesAvailable);
    end
    
end

