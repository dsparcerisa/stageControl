% Add path to consider 
stageControlPath = '../stageControlGUI';
addpath(stageControlPath);

% Start instruments
startInstruments

% Read plan
plan = readPlan('plan.txt');

%% Data necessary for irradiation
PPfactor = 5e-4;

Ifactor = 0.81;

I_FC1_nA = 2; 
I_muestra_nA = I_FC1_nA * Ifactor * PPfactor;

plan.t_s = plan.Q ./ I_muestra_nA / 1000;

%% Center stage
autoCenter(s2);   
[~, ~, ~, Zpos] = monitorStatus(COM);

%% Align in Z position
% align manually and then set here
Zpos = 0;

%% Irradiate plan
tic
for i=1:numel(plan.X)
    abspos = [plan.X(i) plan.Y(i) Zpos];
    finished = stageControl_moveToAbsPos(s2, absPos);
    finished = ConfigureShutter(s1,'t',plan.t_s(i));
    finished = Shutter(s1,'n');
    fprintf('Irradiated spot %i\n', i);
end
toc