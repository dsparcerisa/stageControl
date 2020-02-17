% Utilizar instrumentos ya conectados o abrirlos a mano con openInstruments
clearvars -except COMStage COMShutter
%% Abrir la GUI
% stageControlStart(COMStage);

sigmaPoly_sinPP = [0.0086 0.23 0]; % settings 6 feb (tras corregir la z)
% sigmaPoly_sinPP = [0.0097 0.24 0]; % settings 5 feb
sigmaPoly_conPP = [0 0.26 0.63]; % settings 5 feb

%% Alinear en posición 0 y medir la distancia (ANOTAR!)

modo = 2; % 1) placa, 2) cubeta

% PLATES
if (modo == 1)
    %beamExit2WellDistance = input('Measure distance between beam exit and well edge (cm): ');
    beamExit2WellDistance = 0.6 + 2.7 + 0.2;
    beamExit2WellBottomDistance = beamExit2WellDistance + 1.1;

else
% CUBETAS
    % distanciaAFondoCubeta = input('Distancia de la salida del haz al FONDO de la cubeta (cm): ');
    distanciaAFondoCubeta = 0.6 + 2.7 + 0.5 + 0.8;
end

% DISTANCIAS:
% Nariz-shutter: 6 mm;
% Anchura shutter: 27 mm;
% PLACAS
% Shutter-inicio pocillo: 2mm;
% 1.1 hasta el fondo del pocillo
% CUBETAS
% 0.5 cm hasta el borde del soporte azul
% 0.8 cm más hasta el fondo de la cubeta.



%% Create dose map
if (modo == 1)
    %% Plate
    
    plateDose = nan(8, 12);
    plateDose(2,:) = [nan nan nan 2 nan 8  nan nan nan 2 nan 8];
    plateDose(4,:) = [nan   1 nan 4 nan 12 nan   1 nan 4 nan 12];
%    plateDose(6,:) = [nan nan nan 2 nan 8  nan nan nan nan nan nan];
%    plateDose(8,:) = [nan   1 nan 4 nan 12 nan nan nan nan nan nan];
    NX = 12; NY = 8;
    well2wellDist_cm = 0.899;
    
else
    % %% Microcubeta
    plateDose = [nan 1; 2 4; 6 8; 10 12];
    NX = 2; NY = 4;
    well2wellDist_cm = 1.125;
end

showPlate(plateDose)
title('FLASH');

%% Choose Z and I to find a good match for simulation:
E0 = 3;
dz = 0.001;
dxy = 0.01;
targetTh = 0.001; % 10 um = 10^-5 m = 10^-3 cm
targetSPR = 1;
sizeX = 30;
sizeY = 30;
sigmaX = 0.001; % REVISADO 6-feb para usar polySigma
sigmaY = 0.001; % REVISADO 6-feb para usar polySigma
Nprot = 6.2422e6;
z = 10;

N0 = createGaussProfile(dxy, dxy, sizeX, sizeY, sigmaX, sigmaY);

doseSlice_1pC = getDoseMap(E0, z, dz, Nprot, targetTh, targetSPR, N0, sigmaPoly_sinPP); 

% Find real sigma of doseSlice
Xsum = sum(doseSlice_1pC.data, 2);
F = fit((doseSlice_1pC.getAxisValues('X'))', Xsum, 'gauss1', 'StartPoint', [max(Xsum) 0 1]);
doseSigma = F.c1 / sqrt(2);

%% Crear plan

%shotTime_ms = 0.75; %% VERIFICAR, pero hoy usamos este
shotTime_ms = 0.45; %% De lca calibración del 4-feb

if NX==12
    deltaXY = doseSigma * 1.9;
elseif NX == 2
    deltaXY = doseSigma;
end
I_FC1 = 7.1;
I_factor = 0.76;
I = I_factor * I_FC1;
PP_factor = 1;
I_muestra = I_FC1 * I_factor * PP_factor; % nA

if modo==1
    [plan, totIrrTime, doseRate] = createFlashIrrPlan( plateDose, doseSlice_1pC, I_muestra, deltaXY, 4, shotTime_ms );
else
    [plan, totIrrTime, doseRate] = createFlashIrrPlan( plateDose, doseSlice_1pC, I_muestra, deltaXY, 1, shotTime_ms );
end
fprintf('Total irradiation time in min: %f\n', totIrrTime/60);
fprintf('Dose rate: %f Gy/s\n', doseRate);

%% Calcular plan
if (modo==2)
    % Cubeta
    plan.name = 'FLASH Cubeta';
    plan.Z = -(z-distanciaAFondoCubeta)*ones(size(plan.X));
else
    % Plate
    plan.name = 'FLASH Placa 3 duplicados';
    plan.Z = -(z-beamExit2WellBottomDistance)*ones(size(plan.X));
end
plan.mode = 'FLASH';
plan.tRendija = shotTime_ms;
plan.E = E0;

plan.I = I_FC1;
scatter(plan.X(:), plan.Y(:), 100, plan.Q(:))
set(gca, 'XDir', 'reverse', 'YDir', 'reverse');

if modo==1
    % PLATE
    dose = getDoseFromPlan(CartesianGrid2D(N0), plan, dz, targetTh, targetSPR, N0, I_factor, beamExit2WellBottomDistance);
else
    % CUBETA
    dose = getDoseFromPlan(CartesianGrid2D(N0), plan, dz, targetTh, targetSPR, N0, I_factor, distanciaAFondoCubeta);
end
figure;
dose.crop([-(NX+1) 1 -(NY+1) 1]);
dose.plotSlice
set(gca, 'Ydir', 'reverse', 'Xdir', 'reverse')
colorbar

%% Save plan
if modo==1
% writePlan(plan, 'plans/plan_FLASH_feb6_V1_placa.txt'); 4 nA, Z = 7
%writePlan(plan, 'plans/plan_FLASH_feb6_V2_placa.txt'); % 8 nA, Z = 10
%writePlan(plan, 'plans/plan_FLASH_feb6_V3_placa.txt'); % 8 nA, Z = 10, con 2 duplicados
%writePlan(plan, 'plans/plan_FLASH_feb6_V4_placa.txt'); % Condiciones reales 6 feb, 2 dupls, deltaXY = 2.1*sigma
%writePlan(plan, 'plans/plan_FLASH_feb6_V5_placa.txt'); % Condiciones reales 6 feb, 2 dupls, deltaXY = 1.9*sigma
writePlan(plan, 'plans/plan_FLASH_feb6_V6_placa.txt'); % Corregir intensidad


else
writePlan(plan, 'plans/plan_FLASH_cubeta_feb6_V1.txt');
end
%% Calculate mean doses in all wells 

wellDiam = 6.35; % mm
wellRadius_cm = 0.1 * wellDiam / 2;

Nwells = sum(~isnan(plateDose(:)));
wells = {};

% Positions in reference with the center of the first spot
Xpos = well2wellDist_cm*(0:(-1):(-(NX-1)));
Ypos = well2wellDist_cm*(0:(-1):(-(NY-1)));
[x,y] = meshgrid(Xpos, Ypos);

Xwells = x(~isnan(plateDose(:)));
Ywells = y(~isnan(plateDose(:)));

meanWellDoses = nan(Nwells, 1);
stdWellDoses = nan(Nwells, 1);

for i=1:Nwells
    well = getWell(CartesianGrid2D(dose), wellRadius_cm, [Xwells(i) Ywells(i)]);
    wellDoses = getStats(well, dose);
    meanWellDoses(i) = mean(wellDoses);   
    stdWellDoses(i) = std(wellDoses);   
end

meanWellDoses
stdWellDoses

%% Estimate what the EBT3 will look like
dose.data(isnan(dose.data))=0;
datamat = dose.data+randn(size(dose.data))*0.3;
simRC = simulateRC(flip(datamat',2));
imshow(simRC)