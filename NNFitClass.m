%Class for neural network fitting.
classdef NNFitClass < handle
    
    properties
        
        %File parameters.
        folder; %Folder containing relevant data files.
        filelist; %List of files to train with.
        predfile; %File to use for predictions.
        
        %Fit parameters.
        inpvar; %Variables used for fitting.
        targvar; %Target variable.
        targraw; %Raw target table.
        oddsvar; %Variable to use to calulcate odds.
        
        %Network results.
        YFit; %Neural network outputs.
        
        %Analysis results.
        Ret; %Returns predicted by analysis.
        
        %Input variable parameters.
        data; %unfiltered raw data.
        inputraw; %Raw input for neural network.
        inputs; %Processed input varaibles for neural network training.
        inputvars; %Variables present in process inputs
        targets; %Target variables fro neural network fitting.
        vectargets; %Vectorised form of targets for processing.
        predtab; %Table of variables to predict.
        pred; %Processed variables for prediction.
        odds; %Odds used to evaluate performance.
        oddstest; %Odds for test inputs.
        
        %Neural network parameters.
        cats; %Categories created in preprocessing.
        nets; %Trained neural networks.
        tr; %Training record.
        NNsettings; %Neural network training settings.
        
    end
    
    methods
        
        function obj = Init( obj, folder, filelist, predfile, inpvar,...
                targvar, oddsvar, NNsettings) %Initialisation function.
            
            %User input parameters.
            
            %File parameters.
            obj.folder = folder;
            obj.filelist = filelist;
            obj.predfile = predfile;
            
            %Fit parameters.
            obj.inpvar = inpvar;
            obj.targvar = targvar;
            obj.oddsvar = oddsvar;
            
            %Neural network parameters.
            obj.NNsettings= NNsettings;
            
        end
        
        function obj = NNReadFile(obj)
            
            %%Import data from csv.
            obj.data = NNFitClass.readincsv(obj.folder, obj.filelist);
            
        end
        
        %Prepare variables for neural network training.
        function obj = NNvarprep(obj)
            
            %Input file and data processing.
            
            if isempty(intersect(obj.inpvar, obj.oddsvar))
                
                %Produce sliced inputs and outputs.
                obj.inputraw = obj.data(:, [obj.inpvar obj.oddsvar ...
                    obj.targvar]);
                
            else
                
                %Produce sliced inputs and outputs.
                obj.inputraw = obj.data(:, [obj.inpvar obj.targvar]);
                
            end
            
            %Remove columns with more than 50% NaNs.
            obj.inputraw(:, sum(cellfun(@(x) any(isnan(x)),...
                table2cell(obj.inputraw)),1)/...
                height(obj.inputraw) > 0.2) = [];
            
            %Remove missing entries.
            %For backward compatibility manual method used.
            obj.inputraw(any(cellfun(@(x) any(isnan(x)), ...
                table2cell(obj.inputraw)),2),:) = [];
            
            %Remove empty entries.
            %For backward compatibility manual method used.
            obj.inputraw(any(cellfun(@(x) any(isempty(x)), ...
                table2cell(obj.inputraw)),2),:) = [];
            
            %Change variables to categorical then numeric.
            obj.catconv;
            
            %Separate arrays to inputs and targets.
            obj.inputs = obj.inputraw;
            obj.inputs.(obj.targvar) = [];
            obj.targets = obj.inputraw.(obj.targvar);
            
            %Create odds variables.
            obj.odds = obj.inputraw{:,obj.oddsvar};
            
            %Replace target NaNs with distinct numeric value.
            obj.targets(isnan(obj.targets)) = max(obj.targets) + 1;
            
            %Replace target zeros with distinct numeric value.
            obj.targets(obj.targets == 0) = max(obj.targets) + 1;
            
            obj.targets(obj.targets < 0) = max(obj.targets) + 1 ...
                - obj.targets(obj.targets < 0);
            
            %Copy present variable names.
            obj.inputvars = obj.inputraw.Properties.VariableNames(:);
            
            %Format for neural network training.
            obj.inputs = table2array(obj.inputs)';
            obj.targets = full(ind2vec(obj.targets'));
            
        end
        
        %Prepare prediction variables for neural network prediction.
        function obj = NNpredprep(obj)
            
            %File to predict.
            obj.predtab = readtable([obj.folder '/' obj.predfile]);
            
            %Process inputs for prediction.
            sharedvars = intersect(obj.inputraw.Properties.VariableNames...
                ,obj.predtab.Properties.VariableNames, 'stable');
            obj.pred = obj.predtab(:, sharedvars);
            
            if ismember(obj.targvar, obj.pred.Properties.VariableNames)
                
                obj.pred.(obj.targvar) = []; %Remove empty target column if
                %included.
                
            end
            
            %Change variables to categorical then numeric.
            obj.predconv;
            
        end
        
        %Train neural network.
        function obj = trainNN(obj)
            
            Hlnum = obj.NNsettings.HiddenLayers;
            
            % Create a Pattern Recognition Network
            net = patternnet(Hlnum);
            
            % Set up Division of Data for Training, Validation, Testing
            [net.divideParam.trainRatio, net.divideParam.valRatio,...
                net.divideParam.testRatio ] = obj.NNsettings.tvtRatio;
            
            numNN = obj.NNsettings.numNN;
            
            %Train seriess of neural networks and average predictions.
            obj.nets = cell(1, numNN);
            
            for i=1:numNN
                
                disp(['Training ' num2str(i) '/' ...
                    num2str(numNN)])
                
                [obj.nets{i}, obj.tr] = train( net, obj.inputs,...
                    obj.targets, 'useParallel','yes');
                
            end
            
        end
        
        %Evaluate the neural network fit.
        function obj = evalneurnet(obj, titlestr)
            
            [wdth, ~] = size(obj.inputs(:,obj.tr.testInd));
            aveperf = zeros(wdth,1);
            
            for j = 1:wdth+1
                
                inputint = obj.inputs(:,obj.tr.testInd);
                if j <= wdth
                    
                    %Remove one input to calculate inpact on mse.
                    inputint(j,:) = mean(inputint(j,:));
                    
                end
                
                % Test the Network
                numNN = obj.NNsettings.numNN;
                y2Total = zeros(size(obj.targets(:,obj.tr.testInd)));
                
                for i=1:numNN
                    
                    neti = obj.nets{i};
                    y2 = neti(inputint);
                    y2Total = y2Total + y2;
                    
                end
                
                outputs = y2Total / numNN;
                aveperf(j) = mse(obj.nets{1},obj.targets(:, ...
                    obj.tr.testInd),outputs);
            end
            
            varnam = [obj.inputvars(1:end-1)' 'All'];
            
            %Plot average MSE for each input variable.
            figure, plot(aveperf(isfinite(aveperf)));
            xlabel('Input');
            ylabel('Average Mean Squared Error');
            title([titlestr ' Variable Importance']);
            set(gca,'XTick', 1:length(varnam(isfinite(aveperf))))
            set(gca,'XTickLabel', varnam(isfinite(aveperf)))
            set(gca, 'XTickLabelRotation', 45);
            
            %Convert outputs to correct format.
            obj.vectargets = obj.targets(:,obj.tr.testInd);
            [ ~, obj.vectargets] = max(obj.vectargets);
            obj.vectargets = obj.vectargets';
            
            obj.YFit = outputs;
            [ ~, obj.YFit] = max(obj.YFit); %Convert from ratio, to indices
            obj.YFit = obj.YFit';
            
            disp('Precision Statistics')
            disp('--');
            
            disp(['Performance: ' num2str(aveperf(end))]);
            disp(' ')
            
        end
        
        function obj = optodds( obj, RetPort, titlestring )
            yy = 1:50;
            portval = cell(size(yy));
            prf = zeros(size(yy));
            dd = zeros(size(yy));

            for y=yy
                
                [portval{y}, prf(y), dd(y)] = ...
                    NNFitClass.portstrat(RetPort, y);
                
            end
            
            %Find optimal portfolio.
            [ ~, I ] = max(prf./(dd+1));            
            disp(['Fixed Stake Returns per Bet: '...
                num2str(sum(RetPort)/nnz(RetPort(:)))]);
            disp(['Number of Bets: ' num2str(nnz(RetPort(:)))]);
            disp(['Longest consecutive losses: ' ...
                num2str(NNFitClass.findlongestzeros(RetPort + ...
                ones(size(RetPort))))]);
            
            portval = portval{I(1)};
            
            figure, plot(portval)
            ylabel('Portfolio Value')
            title([ titlestring ' Portfolio Value'])

            disp(['Optimum bet batch size: ' num2str(I(1))])
            
            
            disp(' ')
            
        end
        
        function obj = NNpredict(obj)
            
            
            
            %If too many inputs are empty throw error.
            if any(sum(cellfun(@(x) any(isnan(x)),...
                    table2cell(obj.inputraw)),1)/...
                    height(obj.inputraw) > 0.5)
                
                error(...
                    'Columns in input predictions contain more than 50% NaNs.')
                
            end

            obj.pred = table2array(obj.pred)';
            
            [ wdth, ~] = size(obj.targets);
            [~, hgt] = size(obj.pred);
            y2Total = zeros(wdth, hgt);
            
            numNN = obj.NNsettings.numNN;
            
            for i=1:numNN
                
                neti = obj.nets{i};
                y2 = neti(obj.pred);
              
                y2Total = y2Total + y2;

            end
            
            %Convert from ratio, to indices.
            obj.pred = y2Total / numNN;
            
            [ ~, obj.pred] = max(obj.pred);
            
        end
        
        function obj = catconv(obj)
            
            nnV = ...
                obj.inputraw.Properties.VariableNames(...
                ~varfun(@isnumeric,obj.inputraw,'output','uniform'));
            
            %Store raw targets.
            obj.targraw = obj.inputraw.(obj.targvar);
            
            %Preallocate category vector.
            obj.cats = struct;
            
            for i=1:length(nnV)
                
                catvar = categorical(obj.inputraw.(nnV{i}));
                
                [obj.cats(:).(nnV{i})] = categories(catvar);
                
                obj.inputraw.(nnV{i}) = grp2idx(catvar);
                
            end
            
        end
        
        function obj = predconv(obj)
            
            nnV = ...
                obj.pred.Properties.VariableNames(...
                ~varfun(@isnumeric,obj.pred,'output','uniform'));
            
            for i=1:length(nnV)
                
                obj.pred.(nnV{i}) = grp2idx(...
                    categorical(obj.pred.(nnV{i}), ...
                    obj.cats.(nnV{i})));
                
            end
            
        end
        
    end
    
    methods(Static)
        
        %Function to process lists of csv files in to tables.
        function data = readincsv(folder, filelist)
            
            data = readtable([folder '/' filelist{1}]);
            
            for i = 2:length(filelist)
                
                data = outerjoin(data,...
                    readtable([folder '/' filelist{i}]),...
                    'MergeKeys', true);
                
            end
            
        end
        
        %Change variables to categorical then numeric.
        
        function lgt = findlongestzeros(A)
            try
                is=find(diff([0 A'])==1);
                ie=find(diff([A' 0])==-1);
                lgt = ie-is+1;
                lgt = max(lgt);
            catch
                disp('Longest zeros error');
                lgt = NaN;
            end
            
        end
        
        function [portval, prf, dd] = portstrat(RetPort, nn)
            portval = zeros(size(RetPort));
            portval(1) = 1;

            for d=1:nn:length(RetPort)
                
                portval(d:d+nn-1) = portval(d);
                
                if d + nn - 1 < length(RetPort)
                    
                    portval(d+nn) = portval(d) + portval(d)*...
                        sum(RetPort(d:d+nn-1))/nn;
                    
                end
                
            end
            
            %Calculate profit drawdown ratio.
            prf = portval(end);
            if length(portval) > 1 && all(portval > 0)
                dd = maxdrawdown(portval);
            else
                dd=0;
            end
        end
        
    end
    
end