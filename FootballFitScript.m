function FootballFitScript(varargin)

% Turn off warning about variable names being modified if you use
%readtable() to read in column headers that have spaces in them.
% "Warning: Variable names were modified to make them valid MATLAB
%identifiers."
warning('off', 'MATLAB:table:ModifiedVarnames');

%Optional inputs.
%PredFlag = 'Prediction' Controls whether a set of predictions is made.
%LoadNetFlag = 'LoadNet', 'Filename.mat' Controls whether a saved network
%is used.

%Flag parameters.
PredFlag = '';
LoadNetFlag = '';

if ~isempty(varargin) %Check for optional parameters.
    
    if any(strcmp(varargin,'Prediction')) %Prediction flag.
        
        PredFlag = 'Prediction';
        
    end
    
    if any(strcmp(varargin,'LoadNet')) %Prediction flag.
        
        LoadNetFlag = 'LoadNet';
        LoadNetFile = varargin{ vec2ind( strcmp( varargin', 'LoadNet' )...
            ) + 1 };
        LoadtrFile = varargin{ vec2ind( strcmp( varargin', 'LoadNet' )...
            ) + 2 };
        
    end
    
end

%Horse Fit Input Parameters.

%File parameters.
folder = 'Football';
predfile = 'testset.csv';

league = 'all';

if strcmp(league,'prem')
    
    recfile='http://www.football-data.co.uk/mmz4281/1617/E0.csv';
    websave([ folder '/FBallstats1617.csv'],recfile, 'Timeout', -1);
    
    %%Import football data from csv.
    filelist= {'FBallstats0910.csv', 'FBallstats1011.csv',...
        'FBallstats1112.csv', 'FBallstats1213.csv', 'FBallstats1314.csv'...
       , 'FBallstats1415.csv','FBallstats1516.csv','FBallstats1617.csv'};
    
elseif strcmp(league,'champ')
    
    recfile='http://www.football-data.co.uk/mmz4281/1617/E1.csv';
    websave([ folder '/FBallchampstats1617.csv'],recfile, 'Timeout', -1);
    
    %%Import football data from csv.
    filelist= {'FBallchampstats0910.csv', 'FBallchampstats1011.csv',...
        'FBallchampstats1112.csv', 'FBallchampstats1213.csv', ...
        'FBallchampstats1314.csv', ...
        'FBallchampstats1415.csv','FBallchampstats1516.csv',...
        'FBallchampstats1617.csv'};
    
elseif strcmp(league,'L1')
    
    recfile='http://www.football-data.co.uk/mmz4281/1617/E2.csv';
    websave([ folder '/FBallL1stats1617.csv'],recfile, 'Timeout', -1);
    
    %%Import football data from csv.
    filelist= {'FBallchampstats0910.csv', 'FBallL1stats1011.csv',...
        'FBallL1stats1112.csv', 'FBallL1stats1213.csv', ...
        'FBallL1stats1314.csv', ...
        'FBallL1stats1415.csv','FBallL1stats1516.csv',...
        'FBallL1stats1617.csv'};
    
elseif strcmp(league,'L2')
    
    recfile='http://www.football-data.co.uk/mmz4281/1617/E3.csv';
    websave([ folder '/FBallL2stats1617.csv'],recfile, 'Timeout', -1);
    
    %%Import football data from csv.
    filelist= {'FBallL2stats0910.csv', 'FBallL2stats1011.csv',...
        'FBallL2stats1112.csv', 'FBallL2stats1213.csv', ...
        'FBallL2stats1314.csv', ...
        'FBallL2stats1415.csv','FBallL2stats1516.csv',...
        'FBallL2stats1617.csv'};
    
elseif strcmp(league,'p&c')
    
    recfile='http://www.football-data.co.uk/mmz4281/1617/E0.csv';
    websave([ folder '/FBallstats1617.csv'],recfile, 'Timeout', -1);
    
    recfile='http://www.football-data.co.uk/mmz4281/1617/E1.csv';
    websave([ folder '/FBallchampstats1617.csv'],recfile, 'Timeout', -1);
    
    %%Import football data from csv.
    filelist= {'FBallchampstats0910.csv', 'FBallchampstats1011.csv',...
        'FBallchampstats1112.csv', 'FBallchampstats1213.csv', ...
        'FBallchampstats1314.csv', ...
        'FBallchampstats1415.csv','FBallchampstats1516.csv', ...
        'FBallstats0910.csv', 'FBallstats1011.csv',...
        'FBallstats1112.csv', 'FBallstats1213.csv',...
        'FBallstats1314.csv', ...
        'FBallstats1415.csv','FBallstats1516.csv', ...
        'FBallchampstats1617.csv',...
        'FBallstats1617.csv'};
    
elseif strcmp(league,'all')
    
    recfile='http://www.football-data.co.uk/mmz4281/1617/E0.csv';
    websave([ folder '/FBallstats1617.csv'],recfile, 'Timeout', -1);
    
    recfile='http://www.football-data.co.uk/mmz4281/1617/E1.csv';
    websave([ folder '/FBallchampstats1617.csv'],recfile, 'Timeout', -1);
    
    recfile='http://www.football-data.co.uk/mmz4281/1617/E2.csv';
    websave([ folder '/FBallL1stats1617.csv'],recfile, 'Timeout', -1);
    
    recfile='http://www.football-data.co.uk/mmz4281/1617/E3.csv';
    websave([ folder '/FBallL2stats1617.csv'],recfile, 'Timeout', -1);
    
    %%Import football data from csv.
    filelist= {'FBallchampstats0910.csv', 'FBallchampstats1011.csv',...
        'FBallchampstats1112.csv', 'FBallchampstats1213.csv', ...
        'FBallchampstats1314.csv', ...
        'FBallchampstats1415.csv', ...
        'FBallstats0910.csv', 'FBallstats1011.csv',...
        'FBallstats1112.csv', 'FBallstats1213.csv', ...
        'FBallstats1314.csv', ...
        'FBallstats1415.csv','FBallchampstats1617.csv',...
        'FBallstats1617.csv',...
        'FBallstats1516.csv','FBallchampstats1516.csv',...
        'FBallL1stats0910.csv', 'FBallL1stats1011.csv',...
        'FBallL1stats1112.csv', 'FBallL1stats1213.csv', ...
        'FBallL1stats1314.csv', ...
        'FBallL1stats1415.csv','FBallL1stats1516.csv',...
        'FBallL1stats1617.csv','FBallL2stats0910.csv',...
        'FBallL2stats1011.csv',...
        'FBallL2stats1112.csv', 'FBallL2stats1213.csv', ...
        'FBallL2stats1314.csv', ...
        'FBallL2stats1415.csv','FBallL2stats1516.csv',...
        'FBallL2stats1617.csv'};
    
end

%FTR Training.

%Fit parameters. 
inpvar = {'Div', 'HomeTeam', 'AwayTeam', 'Referee', 'B365H', 'B365D', ...
    'B365A', 'BWH', 'BWD', 'BWA', 'GBH', 'GBD', 'GBA', 'IWH', 'IWD', ...
    'IWA', 'LBH', 'LBD', 'LBA', 'SBH', 'SBD', 'SBA', 'WHH', 'WHD', ...
    'WHA', 'SJH', 'SJD', 'SJA', 'VCH', 'VCD', 'VCA', 'BSH', 'BSD', ...
    'BSA', 'Bb1X2', 'BbMxH', 'BbAvH', 'BbMxD', 'BbAvD', 'BbMxA', ...
    'BbAvA', 'BbOU', 'BbMx_2_5', 'BbAv_2_5', 'BbMx_2_5_1', 'BbAv_2_5_1'...
    , 'BbAH', 'BbAHh', 'BbMxAHH', 'BbAvAHH', 'BbMxAHA', 'BbAvAHA', 'PSH'...
    ,'PSD', 'PSA', 'PSCH', 'PSCD', 'PSCA'};

inpvar = {'Div', 'HomeTeam', 'AwayTeam', 'Referee', 'B365H', 'B365D', ...
    'B365A', 'BWH', 'BWD', 'BWA', 'GBH', 'GBD', 'GBA', 'IWH', 'IWD', ...
    'IWA', 'LBH', 'LBD', 'LBA', 'SBH', 'SBD', 'SBA', 'WHH', 'WHD', ...
    'WHA', 'SJH', 'SJD', 'SJA', 'VCH', 'VCD', 'VCA', 'BSH', 'BSD', ...
    'BSA', 'Bb1X2', 'BbMxH', 'BbAvH', 'BbMxD', 'BbAvD', 'BbMxA', ...
    'BbAvA', 'BbOU', 'BbMx_2_5', 'BbAv_2_5', 'BbMx_2_5_1', 'BbAv_2_5_1'...
    , 'BbAH', 'BbAHh', 'BbMxAHH', 'BbAvAHH', 'BbMxAHA', 'BbAvAHA', 'PSH'...
    ,'PSD', 'PSA'};

inpvar = {'Div', 'B365H', 'B365D', ...
    'B365A', 'LBH', 'LBD', 'LBA', 'WHH', 'WHD', ...
    'WHA', 'Bb1X2', 'BbMxH', 'BbAvH', 'BbMxD', 'BbAvD', 'BbMxA', ...
    'BbAvA', 'BbOU', 'BbMx_2_5', 'BbAv_2_5', 'BbMx_2_5_1', 'BbAv_2_5_1',...
    'BbMxAHH', 'BbAvAHH', 'BbMxAHA', 'BbAvAHA'};
targvar = 'FTR';
oddsvar = {'B365H', 'B365D', 'B365A'};

%Neural network settings.
NNsettings = struct('HiddenLayers', 50, 'tvtRatio', {.7 .15 .15}, ...
    'numNN', 10);

disp('Home-Away-Draw Analysis')
disp('--');

%Initialise fit class.
FootballNNFit = FootballNNFitClass;
FootballNNFit.Init( folder, filelist, predfile, inpvar, targvar, oddsvar...
   , NNsettings);

%Read data files.
FootballNNFit.NNReadFile;

%Prepare variables for Neural Network Training.
FootballNNFit.NNvarprep;

%Prepare inputs used for prediction.
if strcmp(PredFlag,'Prediction')
    
    FootballNNFit.NNpredprep;
    
end

%Check if network is being loaded.
if strcmp(LoadNetFlag, 'LoadNet')
    
    %Load previously trained network.
    FootballNNFit.nets = load(LoadNetFile); 
    FootballNNFit.tr = load(LoadtrFile);
    
else
    
    FootballNNFit.trainNN; %Train neural networks.
    
end

%Evaluate neural network performance.
FootballNNFit.evalneurnet(' Home-Away-Draw ');

%Calculate specific returns.
FootballNNFit.NNFootballreturns;

disp('Away Only Statistics')
disp('--');

FootballNNFit.optodds( FootballNNFit.RetA, 'Away Only');

%Prediction.
if strcmp(PredFlag,'Prediction')
    
    FootballNNFit.FootballNNpredict;
    
end

disp(' ')
disp('Over/Under 2.5 Analysis')
disp('--');

%2.5 Goal prediction
targvar = 'OU25';
oddsvar = {'BbAv_2_5', 'BbAv_2_5_1'};

%Neural network settings.
NNsettings = struct('HiddenLayers', 50, 'tvtRatio', {.7 .15 .15}, ...
    'numNN', 10);

%Initialise fit class.
Football25NNFit = FootballNNFitClass;

Football25NNFit.Init( folder, filelist, predfile, inpvar, targvar,...
    oddsvar, NNsettings);

%Read data files.
Football25NNFit.NNReadFile;

%Create 2.5 total goals target. (1 under, 2 over)
vec = ones(height(Football25NNFit.data),1);
vec(Football25NNFit.data.FTHG + Football25NNFit.data.FTAG > 2.5) = 2;
Football25NNFit.data.OU25 = vec;

%Prepare variables for Neural Network Training.
Football25NNFit.NNvarprep;

%Prepare inputs used for prediction.
if strcmp(PredFlag,'Prediction')
    
    Football25NNFit.NNpredprep;
    
end

%Check if network is being loaded.
if strcmp(LoadNetFlag, 'LoadNet')
    
    %Load previously trained network.
    Football25NNFit.nets = load(LoadNetFile); 
    Football25NNFit.tr = load(LoadtrFile);
    
else
    
    Football25NNFit.trainNN; %Train neural networks.
    
end

%Evaluate neural network performance.
Football25NNFit.evalneurnet('Over Under 2.5');

%Calculate specific returns.
Football25NNFit.NNFootball25returns;

%Prepare inputs used for prediction.
if strcmp(PredFlag,'Prediction')
    
    Football25NNFit.Football25NNpredict;
    
end

disp(' ')
disp('Asian Handicap Analysis')
disp('--');

%Asian Handicap prediction
targvar = 'AHResult';
oddsvar = {'BbAvAHH', 'BbAvAHA'};

%Neural network settings.
NNsettings = struct('HiddenLayers', 50, 'tvtRatio', {.7 .15 .15}, ...
    'numNN', 10);

%Initialise fit class.
FootballAHNNFit = FootballNNFitClass;

FootballAHNNFit.Init( folder, filelist, predfile, inpvar, targvar,...
    oddsvar, NNsettings);

%Read data files.
FootballAHNNFit.NNReadFile;

%Create AH Target.
vec = cell(height(FootballAHNNFit.data), 1);

vec(FootballAHNNFit.data.FTHG -...
    FootballAHNNFit.data.FTAG + FootballAHNNFit.data.BbAHh == 0) = {'SR'};

vec(FootballAHNNFit.data.FTHG -...
    FootballAHNNFit.data.FTAG + FootballAHNNFit.data.BbAHh >= 0.5) = {'H'};

vec(FootballAHNNFit.data.FTHG -...
    FootballAHNNFit.data.FTAG + FootballAHNNFit.data.BbAHh <= 0.5) = {'A'};

vec(FootballAHNNFit.data.FTHG -...
    FootballAHNNFit.data.FTAG + FootballAHNNFit.data.BbAHh == 0.25) =...
    {'HH'};

vec(FootballAHNNFit.data.FTHG -...
    FootballAHNNFit.data.FTAG + FootballAHNNFit.data.BbAHh == 0.25) = ...
    {'HA'};

FootballAHNNFit.data.AHResult = vec;

%Prepare variables for Neural Network Training.
FootballAHNNFit.NNvarprep;

%Prepare inputs used for prediction.
if strcmp(PredFlag,'Prediction')
    
    FootballAHNNFit.NNpredprep;
    
end

%Check if network is being loaded.
if strcmp(LoadNetFlag, 'LoadNet')
    
    %Load previously trained network.
    FootballAHNNFit.nets = load(LoadNetFile); 
    FootballAHNNFit.tr = load(LoadtrFile);
    
else
    
    FootballAHNNFit.trainNN; %Train neural networks.
    
end

%Evaluate neural network performance.
FootballAHNNFit.evalneurnet('Asian Handicap');

%Calculate specific returns.
FootballAHNNFit.NNFootballAHreturns;

%Prepare inputs used for prediction.
if strcmp(PredFlag,'Prediction')
    
    FootballAHNNFit.FootballAHNNpredict;
    
end

end