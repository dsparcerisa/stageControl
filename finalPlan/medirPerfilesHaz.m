% Utilizar instrumentos ya conectados o abrirlos a mano con openInstruments

%% Abrir la GUI
stageControlStart(COMStage);

%% Alinear en posición 0 y medir la distancia (ANOTAR!)
beamExit2WellDistance = input('Measure distance between beam exit and well edge (cm): ');
beamExit2WellBottomDistance = beamExit2WellDistance + 1.1;

%% Alinear manualmente con el aspa y la lámina radioluminiscente;
disp('Press any key when beam is on');
Configure_shutter(COMShutter,'t',10);
Shutter(COMShutter,'n',10);

%% When beam is in position, continue
readStatus(COMStage, 'N'); % Set zero position here

% Pocillo 0,0 desde el ASPA:
X_2_poc00 = [9.55 6.3 0]; 

% Pocillo 0 0 al centro de la placa:
poc00_2_PlateCtr = [-0.899*5.5 -0.899*3.5 0];

% ASPA al centro de la placa:
X_2_PlateCtr = X2poc00 + poc00toplateCtr;

%% Cargar el plan de medida de haces:
commissioningPlanFlashPath = 'plans/plan_COM_Flash.txt';
commissioningPlanFlash = readPlan(commissioningPlanFlashPath);

tic
irradiatePlan(COMStage, COMShutter, plan, globalVector)
toc