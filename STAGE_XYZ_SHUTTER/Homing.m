function Homing(COM)
    f=0;
    status='B';
    while f~=1
        homingr=input('Homing? (0 No, 1 Yes): ');
        if homingr==1
            disp('Homing Depth (Z)');
            fprintf(COM,'C,S1M1000,I1M-0,I1M400,IA1M-0,R');pause(5);
            while numel(strfind(status,'R'))==0
                fprintf(COM,'C,V,R'); disp('Reading status of motor 1');pause(1);
                status=fscanf(COM);
            end            
            savezpos(0,0);            
%         end
%         homingz=input('Homing Z Stages? (0 No, 1 Yes): ');
%         if homingz==1
            disp('Homing X');
            status='B';
            fprintf(COM,'C,S2M1000,I2M-0,I2M400,IA2M-0,R'); pause(5); % Motor 2
            while numel(strfind(status,'R'))==0
                fprintf(COM,'C,V,R'); disp('Reading status of motor 2');pause(1);
                status=fscanf(COM);
            end
            savexpos(0,0);
            disp('Homing Y');
            status='B';
            fprintf(COM,'C,S3M1000,I3M-0,I3M400,IA3M-0,R');pause(5); % Motor 3
            while numel(strfind(status,'R'))==0
                fprintf(COM,'C,V,R'); disp('Reading status of motor 3');pause(1);
                status=fscanf(COM);
            end
            saveypos(0,0);
        end
        f=1;
    end
    disp('Homing finished')
end