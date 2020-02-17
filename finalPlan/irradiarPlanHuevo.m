% openInstruments

%% Cargar el plan de calibración de RC;
HuevoPlanPath = 'plans/plan_huevo_feb17_prueba.txt'; 

HuevoPlan = readPlan(HuevoPlanPath);

fprintf('INTENDED INTENSITY (FC1): %3.3f nA\n', HuevoPlan.I);


%% Irradiar plan
stageLimits = [-1 1 -1 1 -1 1]
tic
irradiatePlan(COMStage, COMShutter, HuevoPlan, [0 0 0], stageLimits, 0) % placa
toc