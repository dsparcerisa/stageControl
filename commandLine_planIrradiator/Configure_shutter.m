function Configure_shutter(COM,A,value)
% set Shutter ON time (seconds) for normal irradiation
    fprintf(1,'Configurating Shutter %f seconds\n',value)
    fprintf(COM,strcat(A,num2str(value)));
    disp('done configurating Shutter');
end