% Utilizar instrumentos ya conectados o abrirlos a mano con openInstruments

%% Abrir la GUI
stageControlStart(COMStage);

stageLimits = [-9.8 0.3 -0.3 9.8 -7.5 0]; % DEFINE!!

%% Alinear en posición 0 y medir la distancia (ANOTAR!)
beamExit2RCdistance = input('Measure distance between beam exit and well edge (cm): ');

%% Alinear manualmente con el aspa y la lámina radioluminiscente;
disp('Press any key when beam is on');
Configure_shutter(COMShutter,'t',10);
Shutter(COMShutter,'n',10);

%% When beam is in position, continue
readStatus(COMStage, 'N'); % Set zero position here

% Pocillo 0,0 desde el ASPA:
X_2_poc00 = [9.55 6.3 0]; 

%% Cargar el plan de calibración de RC;
RCCalibrationPlanPath = 'plans/plan_calibrationRC.txt';
RCCalibrationPlan = readPlan(RCCalibrationPlanPath);

%% Simular plan y crear radiocrómica de prueba
dxy = 0.01;
sizeX = 30;
sizeY = 30;
doseCanvas = createEmptyCG2D(dxy, sizeX, sizeY);
dz = 0.01;
targetTh = 0.001;
targetSPR = 1;
sigmaXY = 0.1;
N0 = createGaussProfile(dxy, dxy, sizeX, sizeY, sigmaXY, sigmaXY);
factorImuestra = 0.86; % Estimación para 3 MeV
dosePlanRC = getDoseFromPlan(doseCanvas, RCCalibrationPlan, dz, targetTh, targetSPR, N0, factorImuestra, beamExit2RCdistance);
dosePlanRC.crop([-11 1 -1 8]);
%% Plot
subplot(2,1,1);
dosePlanRC.plotSlice
set(gca,'YDir','reverse','XDir','reverse');
colorbar
title('Dose distribution (Gy)');
subplot(2,1,2);
imshow(simulateRC(flip(dosePlanRC.data',2)));
title('Expected RC film');

%% Irradiar plan
COMStage = []; COMShutter = [];
tic
irradiatePlan(COMStage, COMShutter, RCCalibrationPlan, X_2_poc00, stageLimits, beamExit2RCdistance)
toc