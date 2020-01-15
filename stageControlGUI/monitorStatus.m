function [status, posX, posY, posZ] = monitorStatus(COM)
% 0: off, 1: ready, 2: moving

step2cm = 2.5 / 10000;
posX = nan;
posY = nan;
posZ = nan;

statusLetter = readStatus(COM,'V');

switch statusLetter
    case 'R'
        status = 1;
        posX = step2cm * str2double(readStatus(COM,'X'));
        posY = step2cm * str2double(readStatus(COM,'Y'));
        posZ = step2cm * str2double(readStatus(COM,'Z'));     
    case 'B'
        status = 2;
        posX = step2cm * str2double(readStatus(COM,'X'));
        posY = step2cm * str2double(readStatus(COM,'Y'));        
    otherwise
        status = 0;
end

end

