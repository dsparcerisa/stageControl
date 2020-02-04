% Utilizar instrumentos ya conectados o abrirlos a mano con openInstruments

%% Abrir la GUI
stageControlStart(COMStage);

stageLimits = [-10.2 0.3 -0.3 10.2 -7.5 0]; % DEFINE!!

%% Elegir modo
modo = 1; % 1) placa, 2) cubeta

%% Alinear en posición 0 y medir la distancia (ANOTAR!)

if (modo==1) % Plate
    beamExit2WellDistance = input('Measure distance between beam exit and well edge (cm): ');
    beamExit2WellBottomDistance = beamExit2WellDistance + 1.1;
elseif (modo ==2) % CUBETAS
    distanciaAFondoCubeta = input('Distancia de la salida del haz al FONDO de la cubeta (cm): ');
end

%% Alinear manualmente con el aspa y la lámina radioluminiscente;
disp('Press any key when beam is on');
Configure_shutter(COMShutter,'t',10);
Shutter(COMShutter,'n',10);

%% When beam is in position, continue
readStatus(COMStage, 'N'); % Set zero position here

disp('Remember to put pepperPot back on the shutter!!!');

% Pocillo 0,0 desde el ASPA:
X_2_poc00 = [9.55 6.3 0]; 

%% Cargar el plan de calibración de RC;
if (modo==1) % Plate
    FlashPlanPath = 'plans/plan_CONV_plate.txt';
elseif (modo==2) % cubeta
    FlashPlanPath = 'plans/plan_CONV_cubeta.txt';
end

FlashPlan = readPlan(FlashPlanPath);

fprintf('INTENDED INTENSITY (FC1): %3.3f nA\n', FlashPlan.I);

%% Simular plan y crear radiocrómica de prueba
dxy = 0.01;
sizeX = 30;
sizeY = 30;
doseCanvas = createEmptyCG2D(dxy, sizeX, sizeY);
dz = 0.01;
targetTh = 0.001;
targetSPR = 1;
sigmaXY = 0.01; %% REVISAR
N0 = createGaussProfile(dxy, dxy, sizeX, sizeY, sigmaXY, sigmaXY);
factorImuestra = 0.86; % Estimación para 3 MeV

if (modo==1) % Plate
    dosePlan = getDoseFromPlan(doseCanvas, FlashPlan, dz, targetTh, targetSPR, N0, factorImuestra, beamExit2WellBottomDistance);
    dosePlan.crop([-11 1 -1 8]); 
elseif (modo==2) % Cubeta
    dosePlan = getDoseFromPlan(doseCanvas, FlashPlan, dz, targetTh, targetSPR, N0, factorImuestra, distanciaAFondoCubeta);
    dosePlan.crop([-2 1 -1 5]);
end

%% Plot
if (modo==1) % Plate
    subplot(2,1,1); % placa
else
    subplot(1,2,1); % cubeta
end
dosePlan.plotSlice
set(gca,'YDir','reverse','XDir','reverse');
colorbar
title('Dose distribution (Gy)');
if (modo==1) % Plate
    subplot(2,1,2); % placa
else
    subplot(1,2,2); % cubeta
end
imshow(simulateRC(flip(dosePlan.data',2)));
title('Expected RC film');

%% Irradiar plan
COMStage = []; COMShutter = [];
tic
if (modo==1) % Plate
    irradiatePlan(COMStage, COMShutter, FlashPlan, X_2_poc00, stageLimits, beamExit2WellBottomDistance) % placa 
else
    irradiatePlan(COMStage, COMShutter, FlashPlan, X_2_poc00, stageLimits, distanciaAFondoCubeta) % cubeta
end
toc