function [steps] = linearstage(COM,id,direction,distance)
    mm2steps=1000/2.5;
    if direction==1 
        strdir='';
    elseif direction==-1
        strdir='-';
    elseif direction==0
        strdir='';
        if distance~=0
            distance
            display('wrong distance for 0 direction!')
            pause
        end
    else
        direction
        display('wrong direction!')
        pause
    end
    steps=round(distance*mm2steps);
    if steps>0
    status='';
    nb=1;
    while nb>0
        nb=COM.BytesAvailable;
        if nb>0
            status=fscanf(COM,'%c',nb);
        end
    end    
    fprintf(1,'Moving stage #%d: %d steps %f mm, direction: %d\n',id,steps,distance,direction);
    command=strcat('C,I',num2str(id),'M',strdir,num2str(steps),',R');%Set steps to move (2.5 mm / 1000 steps)
    fprintf(COM,command);

    %% Save X positions
%     if id==1
%         savezpos(direction,steps);
%     elseif id==2 
%         savexpos(direction,steps);
%     elseif id==3 
%         saveypos(direction,steps);
%     else
%         id
%         disp('Wrong stage ID');
%     end
    %fprintf(COM,'C,V,R'); 
    status='';
    nstatus=0;
    disp('Reading status of linear stage');
    while nstatus<1
        nb=COM.BytesAvailable;
        if nb>0
            status=fscanf(COM,'%c',nb)
            if numel(strfind(status,'^'))==1
                nstatus=nstatus+1;
                status='';
            end
        end
    end
    disp('done moving linear stage');
    end
end

