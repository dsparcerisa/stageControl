function Scan(COM,COMr,nxs,nys,Shutter_mode,acqfolder,plate,impar)

    xcenterfile='data/xcenter.txt';
    fid=fopen(xcenterfile,'r');
    xcenter=fscanf(fid,'%f');
    fclose(fid);
    ycenterfile='data/ycenter.txt';
    fid=fopen(ycenterfile,'r');
    ycenter=fscanf(fid,'%f');
    fclose(fid);
    zcenterfile='data/zcenter.txt';
    fid=fopen(zcenterfile,'r');
    zcenter=fscanf(fid,'%f');
    fclose(fid); 
    
    if plate==1
    % 96 wells plate
    
    % distance between wells XY [mm]
    delta_x=9;
    delta_y=9; 
    % relative position from beam alignment to first well
    zero_shift_x=10*delta_x+5.5;                             
    zero_shift_y=7*delta_y;
    % number of shots per column, row ...
    v_nshots=[1 2 3 4 6 8 10];
    elseif plate==3
    % distance between wells XY [mm]
    delta_x=12;
    delta_y=12; 
    % relative position from beam alignment to first well
    zero_shift_x=0;                            
    zero_shift_y=-20;
    % number of shots per column, row ...
    if impar==1
        v_nshots=[1 2 4 6 8; 0 0 0 0 0;1 2 4 6 8; 0 0 0 0 0;]';
    else
        v_nshots=[0 0 0 0 0; 10 20 40 60 80;0 0 0 0 0; 10 20 40 60 80;]';
    end
%     v_time=[0.1 0.5 5 1 2; 1 2 4 6 8; 0.1 0.5 5 1 2;  1 2 4 6 8]';
    elseif plate==4
    % distance between wells XY [mm]
    delta_x=16;
    delta_y=16; 
    % relative position from beam alignment to first well
    zero_shift_x=-8;                            
    zero_shift_y=-22;
    % number of shots per column, row ...
    v_nshots=[1 4 8; 10 20 30;50 75 100;]';
    v_time=[0.5 2 4; 6 8 10; 20 30 50;]';
    end
    
    % go to reference position
    initialposX=xcenter+zero_shift_x; % first well X position
                                    
    % X move from curret X position to first well X position
    initialposshiftX=initialposX-steps2mm(savexpos(1,0));
    % move X stage                                                      
    stepsX=linearstage(COM,2,sign(initialposshiftX),abs(initialposshiftX));
    
    % same for Y
    initialposY=ycenter+zero_shift_y;
    initialposshiftY=initialposY-steps2mm(saveypos(1,0))
    stepsY=linearstage(COM,3,sign(initialposshiftY),abs(initialposshiftY));
    
    % same for Z
%      initialposZ=zcenter; 
%      initialposshiftZ=initialposZ-steps2mm(savezpos(1,0));
%      stepsZ=linearstage(COM,1,sign(initialposshiftZ),abs(initialposshiftZ));

fid5=fopen(strcat(acqfolder,'/irradiation_times.txt'),'w');
fprintf(fid5,'%s\t%s\t%s\t%s\n','nx','ny','nshots','date_and_time');

for ny=1:nys % Y moves
    for nx=1:nxs % X moves
         Configure_shutter(COMr,'t',v_time(nx,ny));
         disp('Activating Shutter...');
%         fprintf(fid5,'%i\t%i\t%i\t%s\n',nx,ny,v_nshots(nx,ny),datestr(now,'yyyymmdd_HHMM'));
        fprintf(fid5,'%i\t%i\t%i\t%s\n',nx,ny,v_time(nx,ny),datestr(now,'yyyymmdd_HHMM'));
        %Shutter(COMr,Shutter_mode,v_nshots(nx,ny));
        Shutter(COMr,Shutter_mode,1);
        if nx<nxs
            stepsX=linearstage(COM,2,-1,delta_x); % Y move
        end
    end
    % Move to next column
    if ny<nys
        stepsY=linearstage(COM,3,-1,delta_y);
        stepsX=linearstage(COM,2,1,delta_x*(nxs-1));
    end
end
fclose(fid5);
%stepsZ=linearstage(COM,1,-1,50);
end