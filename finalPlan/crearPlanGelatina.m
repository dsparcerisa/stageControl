clearvars -except COMStage COMShutter
%%
% sigmaPoly_sinPP = [0.0097 0.24 0]; % settings 5 feb (3 MeV)
% sigmaPoly_sinPP = [0.0097 0.24 0]; % settings 5 feb (3 MeV)

% sigmaPoly_conPP = [0 0.26 0.63]; % settings 5 feb (3 MeV)
% sigmaPoly_conPP = [0 0.24 0.76]; % settings 6 feb (3 MeV)

sigmaPoly_feb17 = [0 0 2.5]; % Tentative 17 feb

%% Abrir la GUI
% stageControlStart(COMStage);

%% Alinear en posición 0 y medir la distancia (ANOTAR!)
distNarizAGelatina_cm = 12; % TENTATIVO, medir en posicion 0 mejor

% Create material list
Material = {'Air'; 'Copper'; 'Air'; 'Water'};
Thickness_cm = [4; 0.0020; 8; 0.1];
z = sum(Thickness_cm(1:(end-1)));
materialTable = table(Material, Thickness_cm);

% DISTANCIAS:
% Nariz-shutter: 6 mm;
% Anchura shutter: 27 mm;
% GELATINA:

plateDose = [ 5 10; 15 20; 25 30; 40 50 ];
NX = 2; NY = 4;
well2wellDist_cm = 1;
showPlate(plateDose)
title('Gelatina');

%% Create dose slice
E0 = 8;
dz = 0.001;
dxy = 0.01;
Nprot = 6.25e6; % 1 pC
targetTh = 0.001; % 10 um = 10^-5 m = 10^-3 cm
targetSPR = 1;
sizeX = 30;
sizeY = 30;
sigmaX = 0.001; % REVISAR
sigmaY = 0.001; % REVISAR
N0 = createGaussProfile(dxy, dxy, sizeX, sizeY, sigmaX, sigmaY);
doseSlice = getDoseMap_ThickTarget(E0, Nprot, materialTable, N0, sigmaPoly_feb17);
Xsum = sum(doseSlice.data, 2);
F = fit((doseSlice.getAxisValues('X'))', Xsum, 'gauss1', 'StartPoint', [max(Xsum) 0 1]);
doseSigma = F.c1 / sqrt(2);

%% Create plan
deltaXY = doseSigma * 1.9;
I_FC1 = 0.1; % nA
I_factor = 0.86; % Medir de nuevo
%PP_factor = 0.04; % PP2capas
PP_factor = 1;

I_muestra = I_FC1 * I_factor * PP_factor; % nA

[plan, totIrrTime, doseRate] = createStdIrrPlan( plateDose, doseSlice, I_muestra, deltaXY, 1, well2wellDist_cm);

fprintf('Total irradiation time in min: %f\n', totIrrTime/60);
fprintf('Dose rate: %f Gy/s\n', doseRate);

plan.name = 'Gelatina';
plan.mode = 'CONV';
plan.codFiltro = '1';
plan.E = E0;


plan.Z = -(z-distNarizAGelatina_cm)*ones(size(plan.X));
plan.I = I_FC1;
scatter(plan.X(:), plan.Y(:), 100, plan.Q(:))
set(gca, 'XDir', 'reverse', 'YDir', 'reverse');
dose =  getDoseFromPlan_ThickTarget(CartesianGrid2D(N0), plan, N0, I_factor, materialTable, sigmaPoly_feb17);
figure;
dose.plotSlice
set(gca, 'Ydir', 'reverse', 'Xdir', 'reverse')

%% Save plan
writePlan(plan, 'plans/plan_gelatina_feb17_prueba.txt'); % Z = 10, 80 pA

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
simRC = simulateRC(flip((dose.data)'+randn(size((dose.data)'))*0.3,2));
imshow(simRC)