function limits = findLimits(COM)
fprintf(COM,'C,S1M1000,I1M-0,I1M400,R'); % Move to beginning of Z and return 400 steps
response = readStatus(COM, 'X')

limits(5) = str2num(response);
fprintf(COM,'C,I1M0,R') % Move to maximum position of Z
response = readStatus(COM, 'X')
limits(6) = str2num(response);
midPos = round((limits(6)-limits(5))/2);
fprintf(COM, 'C, I1M-%i, R', midPos)
disp('Z axis done. Press any key to continue...');
pause

fprintf(COM,'C,S2M1000,I2M-0,I2M400,R'); % Move to beginning of X and return 400 steps
response = readStatus(COM, 'Y')
limits(1) = str2num(response);
fprintf(COM,'C,I2M0,R') % Move to maximum position of Z
response = readStatus(COM, 'Y')
limits(2) = str2num(response);
midPos = round((limits(2)-limits(1))/2);
fprintf(COM, 'C, I2M-%i, R', midPos)
disp('X axis done. Press any key to continue...');
pause

fprintf(COM,'C,S3M1000,I3M-0,I3M400,R'); % Move to beginning of Y and return 400 steps
response = readStatus(COM, 'Z')
limits(3) = str2num(response);
fprintf(COM,'C,I3M0,R') % Move to maximum position of Z
response = readStatus(COM, 'Z')
limits(4) = str2num(response)
midPos = round((limits(2)-limits(1))/2);
fprintf(COM, 'C, I3M-%i, R', midPos)
disp('Y axis done. Press any key to continue...');
pause
end

