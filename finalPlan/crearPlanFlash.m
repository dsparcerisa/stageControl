% Utilizar instrumentos ya conectados o abrirlos a mano con openInstruments

%% Abrir la GUI
stageControlStart(COMStage);

%% Alinear en posici�n 0 y medir la distancia (ANOTAR!)
% PLATES
% beamExit2WellDistance = input('Measure distance between beam exit and well edge (cm): ');
% beamExit2WellBottomDistance = beamExit2WellDistance + 1.1;

%% Alinear en posici�n 0 y medir la distancia (ANOTAR!)
% CUBETAS
distanciaAFondoCubeta = input('Distancia de la salida del haz al FONDO de la cubeta (cm): ');

%% Create dose map
%% Plate
% plateDose = nan(8, 12);
% plateDose(2,:) = [nan nan nan 2 nan 8  nan nan nan 2 nan 8];
% plateDose(4,:) = [nan   1 nan 4 nan 12 nan   1 nan 4 nan 12];
% plateDose(6,:) = [nan nan nan 2 nan 8  nan nan nan nan nan nan];
% plateDose(8,:) = [nan   1 nan 4 nan 12 nan nan nan nan nan nan];
% NX = 12; NY = 8;
% well2wellDist_cm = 0.899;


% %% Microcubeta
plateDose = [nan 1; 2 4; 6 8; 10 12];
showPlate(plateDose)
NX = 2; NY = 4;
well2wellDist_cm = 1.125;

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
sigmaX = 0.1; % REVISAR
sigmaY = 0.1; % REVISAR
% Partimos de un haz con sigma = 0.1 mm
Nprot = 6.2422e6;
z = 10;

N0 = createGaussProfile(dxy, dxy, sizeX, sizeY, sigmaX, sigmaY);
doseSlice_1pC = getDoseMap(E0, z, dz, Nprot, targetTh, targetSPR, N0); 

%% Find real sigma of doseSlice
Xsum = sum(doseSlice_1pC.data, 2);
F = fit((doseSlice_1pC.getAxisValues('X'))', Xsum, 'gauss1', 'StartPoint', [max(Xsum) 0 1]);
doseSigma = F.c1 / sqrt(2);

%% Crear plan

shotTime_ms = 0.75; %% VERIFICAR

if NX==12
    deltaXY = doseSigma * 2.1;
elseif NX == 2
    deltaXY = doseSigma * 2.1;
end

I_FC1 = 2.042; %% Ajustar
I_factor = 0.86;
I = I_factor * I_FC1;
PP_factor = 1;
I_muestra = I_FC1 * I_factor * PP_factor; % nA

[plan, totIrrTime, doseRate] = createFlashIrrPlan( plateDose, doseSlice_1pC, I_muestra, deltaXY, 4, shotTime_ms );
fprintf('Total irradiation time in min: %f\n', totIrrTime/60);
fprintf('Dose rate: %f Gy/s\n', doseRate);

%% Calcular plan
% Cubeta
plan.name = 'FLASH Cubeta';
% Plate
% plan.name = 'FLASH Placa 3 duplicados';
plan.mode = 'FLASH';
plan.tRendija = shotTime_ms;
plan.E = E0;

% Cubeta
plan.Z = -(z-distanciaAFondoCubeta)*ones(size(plan.X));
% Plate
% plan.Z = -(z-beamExit2WellBottomDistance)*ones(size(plan.X));

plan.I = I_FC1;
scatter(plan.X(:), plan.Y(:), 100, plan.Q(:))
set(gca, 'XDir', 'reverse', 'YDir', 'reverse');

% PLATE
% dose = getDoseFromPlan(CartesianGrid2D(N0), plan, dz, targetTh, targetSPR, N0, I_factor, beamExit2WellBottomDistance);

% CUBETA
dose = getDoseFromPlan(CartesianGrid2D(N0), plan, dz, targetTh, targetSPR, N0, I_factor, distanciaAFondoCubeta);

figure;
dose.crop([-11 1 -1 8]);
dose.plotSlice
set(gca, 'Ydir', 'reverse', 'Xdir', 'reverse')
colorbar

%% Save plan
% writePlan(plan, 'plans/plan_FLASH_plate.txt');
writePlan(plan, 'plans/plan_FLASH_cubeta.txt');

%% Calculate mean doses in all wells 

wellDiam = 6.35; % mm
wellRadius_cm = 0.1 * wellDiam / 2;

Nwells = sum(~isnan(plateDose(:)));
wells = {};

% Positions in reference with the center of the first spot
Xpos = well2wellDist_cm*(0:(-1):(-(NX-1)));
Ypos = well2wellDist_cm*(0:(NY-1));
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