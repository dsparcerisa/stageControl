function [newpos] = saveradialpos(direction,steps)
    radialposfile='data/radialstageposition.txt';
    if (direction==0)
        prevpos=0;
    else
        fidr=fopen(radialposfile,'r');
        prevpos=fscanf(fidr,'%d');
        fclose(fidr);
    end
    fidr=fopen(radialposfile,'w');
    newpos=prevpos+steps*direction;
    fprintf(fidr,'%d',newpos);
    fclose(fidr);
end

