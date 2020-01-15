function [newpos] = savexpos(direction,steps)
    xposfile='data/xstageposition.txt';
    if (direction==0)
        prevpos=0;
    else
        fidr=fopen(xposfile,'r');
        prevpos=fscanf(fidr,'%d');
        fclose(fidr);
    end
    fidr=fopen(xposfile,'w');
    newpos=prevpos+steps*direction;
    fprintf(fidr,'%d',newpos);
    fclose(fidr);
end

