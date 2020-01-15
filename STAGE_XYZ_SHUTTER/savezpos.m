function [newpos] = savezpos(direction,steps)
    zposfile='data/zstageposition.txt';
    if (direction==0)
        prevpos=0;
    else
        fidr=fopen(zposfile,'r');
        prevpos=fscanf(fidr,'%d');
        fclose(fidr);
    end
    fidr=fopen(zposfile,'w');
    newpos=prevpos+steps*direction;
    fprintf(fidr,'%d',newpos);
    fclose(fidr);
end