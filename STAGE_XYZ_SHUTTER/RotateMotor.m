function RotateMotor(COM,A,i)
    if strcmp(A,'B')
        fprintf(COM,'B,');
        stcmd=strcat('*',num2str(i),',R');
        fprintf(1,'Rotate %i steps\n',i)
        fprintf(COM,stcmd);
    elseif strcmp(A,'F')
        fprintf(COM,'F,');
        stcmd=strcat('*',num2str(i),',R');
        fprintf(1,'Rotate %i steps\n',i)
        fprintf(COM,stcmd);
    elseif strcmp(A,'V')
        stcmd=strcat('V',num2str(i),',');
        fprintf(COM,stcmd);
        fprintf(1,'Rotate speed %i\n',i)
    else
        disp('Error. Enter B to rotate backward or F to rotate forward')
    end
    status='';
    disp('Reading status of rotation stage');
    while numel(strfind(status,'D'))==0
        nb=COM.BytesAvailable;
        if nb>0
            status=fscanf(COM,'%s');
        end
    end
    disp('done with rotation stage');
end
