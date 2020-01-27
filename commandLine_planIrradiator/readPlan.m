function plan = readPlan(planFile)
%% Read name

ID = fopen(planFile);
tline = fgetl(ID);
tline = strtrim(tline(2:end));
fprintf('Reading plan with name %s\n', tline);
fclose(ID);

%% Read header

opts = delimitedTextImportOptions("NumVariables", 5);

% Specify range and delimiter
opts.DataLines = [3, 3];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["EMeV", "Zcm", "InA", "codFiltro", "numSpots"];
opts.VariableTypes = ["double", "double", "double", "string", "uint16"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "codFiltro", "WhitespaceRule", "trim");
opts = setvaropts(opts, "codFiltro", "EmptyFieldRule", "auto");
opts = setvaropts(opts, "numSpots", "TrimNonNumeric", true);
opts = setvaropts(opts, "numSpots", "ThousandsSeparator", ",");

% Import header
header = readtable(planFile, opts);
clear opts

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [5, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Xcm", "Ycm", "QpC"];
opts.VariableTypes = ["double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
dataTable = readtable(planFile, opts);


plan.E = header.EMeV;
plan.Z = header.Zcm;
plan.I = header.InA;
plan.codFiltro = header.codFiltro;
plan.numSpots = header.numSpots;
plan.X = dataTable.Xcm;
plan.Y = dataTable.Ycm;
plan.Q = dataTable.QpC;
plan.name = tline;

end

