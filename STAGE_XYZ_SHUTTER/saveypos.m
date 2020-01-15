function [newpos] = saveypos(direction,steps)
    yposfile='data/ystageposition.txt';
    if (direction==0)
        prevpos=0;
    else
        fidr=fopen(yposfile,'r');
        prevpos=fscanf(fidr,'%d');
        fclose(fidr);
    end
    fidr=fopen(yposfile,'w');
    newpos=prevpos+steps*direction;
    fprintf(fidr,'%d',newpos);
    fclose(fidr);
end

