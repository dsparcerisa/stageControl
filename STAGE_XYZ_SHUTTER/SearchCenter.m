function SearchCenter(COM)

    
    searchr=0;
    
    while searchr==0
        searchr=input('Set current position as reference? (0 No, 1 Yes): ');
        if searchr==0
            motor=input('Motor? (1 (Z), 2 (X), 3 (Y)): ');
            distance=input('Distance (mm)? (include sing)');
            stepsZ=linearstage(COM,motor,sign(distance),abs(distance));
        end
    end
    
    xcenter=steps2mm(savexpos(1,0));
    xcenterfile='data/xcenter.txt';
    fid=fopen(xcenterfile,'w');    
    fprintf(fid,'%f',xcenter);
    fclose(fid);
    ycenter=steps2mm(saveypos(1,0));
    ycenterfile='data/ycenter.txt';
    fid=fopen(ycenterfile,'w');
    fprintf(fid,'%f',ycenter);
    fclose(fid);
    zcenter=steps2mm(savezpos(1,0));
    zcenterfile='data/zcenter.txt';
    fid=fopen(zcenterfile,'w');
    fprintf(fid,'%f',zcenter);
    fclose(fid);
    disp('Reference position has been stored');

end