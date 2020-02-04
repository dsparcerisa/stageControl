clear all; close all

modo = 2; % 1) placa, 2) cubeta

%% Abrir la GUI
stageControlStart(COMStage);

%% Alinear en posición 0 y medir la distancia (ANOTAR!)
if modo==1 % placa
    beamExit2WellDistance = input('Measure distance between beam exit and well edge (cm): ');
    beamExit2WellBottomDistance = beamExit2WellDistance + 1.1;
elseif modo==2 % cubeta
    distanciaAFondoCubeta = input('Distancia de la salida del haz al FONDO de la cubeta (cm): ');
end

%% Plate
if modo==1 % placa
    plateDose = nan(8, 12);
    plateDose(2,:) = [nan nan nan 2 nan 8  nan nan nan nan nan nan];
    plateDose(4,:) = [nan   1 nan 4 nan 12 nan nan nan nan nan nan];
    NX = 12; NY = 8;
    well2wellDist_cm = 0.899;
    
else % Microcubeta
    plateDose = [nan 1; 2 4; 6 8; 10 12];
    showPlate(plateDose)
    NX = 2; NY = 4;
    well2wellDist_cm = 1.125;
end

showPlate(plateDose)
title('CONV');
%% Create dose slice
E0 = 3;
z = 10;
dz = 0.001;
dxy = 0.01;
Nprot = 6.25e6; % 1 pC
targetTh = 0.001; % 10 um = 10^-5 m = 10^-3 cm
targetSPR = 1;
sizeX = 30;
sizeY = 30;
sigmaX = 0.1; % REVISAR
sigmaY = 0.1; % REVISAR
N0 = createGaussProfile(dxy, dxy, sizeX, sizeY, sigmaX, sigmaY);
doseSlice = getDoseMap(E0, z, dz, Nprot, targetTh, targetSPR, N0);

%% Find real sigma of doseSlice
Xsum = sum(doseSlice.data, 2);
F = fit((doseSlice.getAxisValues('X'))', Xsum, 'gauss1', 'StartPoint', [max(Xsum) 0 1]);
doseSigma = F.c1 / sqrt(2);

%% Create plan
deltaXY = doseSigma * 2.1;
I_FC1 = 2.1; % nA
I_factor = 0.86;
PP_factor = 6.7e-4; % PP100
I_muestra = I_FC1 * I_factor * PP_factor; % nA

[plan, totIrrTime, doseRate] = createStdIrrPlan( plateDose, doseSlice, I_muestra, deltaXY, 4);
fprintf('Total irradiation time in min: %f\n', totIrrTime/60);
fprintf('Dose rate: %f Gy/s\n', doseRate);

if modo==1 % Plate
    plan.name = 'CONV Placa';
else % Cubeta
    plan.name = 'FLASH Cubeta';
end
plan.mode = 'CONV';
plan.codFiltro = 'PP100';
plan.E = E0;

if modo==1
    % Plate
    plan.Z = -(z-beamExit2WellBottomDistance)*ones(size(plan.X));
else
    % Cubeta
    plan.Z = -(z-distanciaAFondoCubeta)*ones(size(plan.X));
end

plan.I = I_FC1;
scatter(plan.X(:), plan.Y(:), 100, plan.Q(:))
set(gca, 'XDir', 'reverse', 'YDir', 'reverse');

if modo==1 % PLATE
    dose = getDoseFromPlan(CartesianGrid2D(N0), plan, dz, targetTh, targetSPR, N0, I_factor, beamExit2WellBottomDistance);
else % CUBETA
    dose = getDoseFromPlan(CartesianGrid2D(N0), plan, dz, targetTh, targetSPR, N0, I_factor, distanciaAFondoCubeta);
end

figure;
dose.plotSlice
set(gca, 'Ydir', 'reverse', 'Xdir', 'reverse')

%% Save plan
if (modo==1)
    writePlan(plan, 'plans/plan_CONV_plate.txt');
else
    writePlan(plan, 'plans/plan_CONV_cubeta.txt');
end

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
simRC = simulateRC(flip((dose.data)'+randn(size((dose.data)'))*0.3,2));
imshow(simRC)