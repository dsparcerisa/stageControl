function status = stageControl_setPosition(app, position)
% moves stage to defined position
if app.isWithinLimits(position)
    message = sprintf('Move to position -> (X: %3.2f  Y: %3.2f  Z: %3.2f)\n', position(1), position(2), position(3));
    app.logLine(message);
    % Wait for stage
    pause(2)
    app.updatePosition(position);
    status = true;
else
    message = 'ERROR: Target position is not within defined limits';
    app.logLine(message);
    status = false;
end
end


