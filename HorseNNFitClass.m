classdef HorseNNFitClass < NNFitClass
    
    methods
        
        %Calculate returns in the case of horse racing.
        function obj = NNHorsereturns(obj)
            
            disp('Accuracy statistics')
            disp('--');
            Res = zeros(length(obj.tr.testInd),1);
            Res(obj.vectargets == obj.YFit) = 1;
            
            disp(['Accuracy: ', num2str(100*sum(Res...
                (obj.YFit == 1))/length(Res(obj.YFit == 1))), '%']);
            
            disp(' ')
            
            disp('Returns statistics')
            disp('--');
            
            %Slice to test indices oddstest.R
            obj.oddstest = obj.odds(obj.tr.testInd);
            
            obj.Ret = zeros(length(obj.tr.testInd),1);
            obj.Ret(Res == 1 & obj.YFit==1) = ...
                obj.oddstest(Res == 1 & obj.YFit==1)-1;
            obj.Ret(Res == 0 & obj.YFit==1) = -1;
            disp(['Fixed Stake Returns per Bet: '...
                num2str(sum(obj.Ret)/...
                nnz(obj.Ret(:)))]);
            disp(['Number of Bets: ' num2str(nnz(obj.Ret(:)))]);
            disp(['Longest consecutive losses: ' ...
                num2str(NNFitClass.findlongestzeros(Res))]);
            disp(' ')
            
            obj.optodds( obj.Ret, 'All Results');
            
        end
        
        function obj = HorseNNpredict( obj )
            
            obj.NNpredict;
               
            obj.predtab.Prediction = obj.pred';
            
            disp('Future Result Predictions:')
            disp(sortrows(obj.predtab(obj.predtab.Prediction == 1,...
                [1:4 end])))
            
        end
        
    end
    
end