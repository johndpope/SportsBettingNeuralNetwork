function HorseFitScript(varargin)

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
folder = 'Horse Racing';
filelist= {'RBDResults2016.csv'};
predfile = 'testset.csv';

%Fit parameters.
inpvar = {'Country', 'Track', 'Going', 'Type', 'Distance', 'Class',...
    'Time', 'OR', 'Weight', 'Age', 'Jockey', 'Horse', 'HeadGear',...
    'Trainer', 'SPFav', 'IndustrySP', 'BetfairSP'};

inpvar = {'Country', 'Track', 'Going', 'Type', 'Distance',...
    'Time', 'OR', 'Weight', 'Age', 'Jockey', 'Horse', 'HeadGear',...
    'Trainer', 'SPFav', 'IndustrySP', 'BetfairSP'};

targvar = 'Place';
oddsvar = 'IndustrySP';

%Neural network settings.
NNsettings = struct('HiddenLayers', 50, 'tvtRatio', {.7 .15 .15}, ...
    'numNN', 5);

%Initialise fit class.
HorseNNFit = HorseNNFitClass;
HorseNNFit.Init( folder, filelist, predfile, inpvar, targvar, oddsvar, ...
    NNsettings);

%Read data files.
HorseNNFit.NNReadFile;

%Process Place target variable to account for non-numeric entries while,
%maintaining raw numeric values.
HorseNNFit.data.Place = str2double(HorseNNFit.data.Place);

%Prepare variables for Neural Network Training.
HorseNNFit.NNvarprep;

%Prepare inputs used for prediction.
if strcmp(PredFlag,'Prediction')
    
    HorseNNFit.NNpredprep;
    
end

%Check if network is being loaded.
if strcmp(LoadNetFlag, 'LoadNet')
    
    HorseNNFit.nets = load(LoadNetFile); %Load previously trained network.
    HorseNNFit.tr = load(LoadtrFile);
    
else
    
    HorseNNFit.trainNN; %Train neural networks.
    
end


%Evaluate neural network performance.
HorseNNFit.evalneurnet('Horse Racing');

%Calculate specific returns for horse racing scenario.
HorseNNFit.NNHorsereturns;

if any(HorseNNFit.Ret(HorseNNFit.vectargets ~= 1)>0)
    disp('Non-favourite Statistics')
    disp('--');
    
    HorseNNFit.optodds(HorseNNFit.Ret(HorseNNFit.vectargets ~= 1),...
        'Non-favourite');
    
end

%Prepare inputs used for prediction.
if strcmp(PredFlag,'Prediction')
    
    HorseNNFit.HorseNNpredict;
    
end

end