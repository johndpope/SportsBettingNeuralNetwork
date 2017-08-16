classdef FootballNNFitClass < NNFitClass
    
    properties
        
        %Football specific variables.
        RetH; %Returns for specific results.
        RetA;
        RetD;
        RetO;
        RetU;
        
        %Conversions from number to result.
        hometarg; %HAD
        awaytarg;
        drawtarg;
        
        overtarg; %Over under 2.5
        undertarg;
        
        ahhometarg; %Asian Handicap.
        ahawaytarg;
        ahhalfhometarg;
        ahhalfawaytarg;
        ahsrtarg;
        
    end
    
    methods
        
        %Calculate returns in the case of horse racing.
        function obj = NNFootballreturns(obj)
            
            disp('Accuracy statistics')
            disp('--');
            Res = zeros(length(obj.tr.testInd),1);
            Res(obj.vectargets == obj.YFit) = 1;
            
            disp(['Accuracy: ', num2str(100*sum(Res...
                )/length(Res)), '%']);
            
            disp(' ')
            
            disp('Returns statistics B365')
            disp('--');
            
            %Slice to test indices oddstest.
            obj.oddstest = obj.odds(obj.tr.testInd, :);
            
            %Separate odds into different results.
            homeodds = obj.oddstest(:,strcmp( ...
                cellfun(@(x) x(end),obj.oddsvar,'un',0) ,'H'));
            drawodds = obj.oddstest(:,strcmp( ...
                cellfun(@(x) x(end),obj.oddsvar,'un',0) ,'D'));
            awayodds = obj.oddstest(:,strcmp( ...
                cellfun(@(x) x(end),obj.oddsvar,'un',0) ,'A'));
            
            obj.hometarg = mean(obj.vectargets(strcmp(obj.targraw(...
                obj.tr.testInd),'H')));
            obj.drawtarg = mean(obj.vectargets(strcmp(obj.targraw(...
                obj.tr.testInd),'D')));
            obj.awaytarg = mean(obj.vectargets(strcmp(obj.targraw(...
                obj.tr.testInd),'A')));
                       
            disp(['Home Win Test Success Rate: ', num2str(100*sum(...
                Res(...
                obj.YFit == obj.hometarg))/...
                length(Res(obj.YFit == obj.hometarg))),...
                '%']);
            disp(['Away Win Test Success Rate: ', num2str(100*sum(...
                Res(...
                obj.YFit == obj.awaytarg))/...
                length(Res(obj.YFit == obj.awaytarg))), '%']);
            disp(['Draw Test Success Rate: ', num2str(100*sum(Res(...
                obj.YFit == obj.drawtarg))/...
                length(Res(obj.YFit == obj.drawtarg))), '%']);
            disp(' ')
            
            obj.Ret = -1*ones(length(obj.tr.testInd),1);
            obj.Ret(Res == 1 & obj.YFit==obj.hometarg) = ...
                homeodds(Res == 1 & obj.YFit==obj.hometarg)-1;
            obj.Ret(Res == 1 & obj.YFit==obj.awaytarg) = ...
                awayodds(Res == 1 & obj.YFit==obj.awaytarg)-1;
            obj.Ret(Res == 1 & obj.YFit==obj.drawtarg) = ...
                drawodds(Res == 1 & obj.YFit==obj.drawtarg)-1;
            
            disp(['Fixed Stake Returns per Bet: '...
                num2str(sum(obj.Ret)/...
                nnz(obj.Ret(:)))]);
            disp(['Number of Bets: ' num2str(nnz(obj.Ret(:)))]);
            disp(['Longest consecutive losses: ' ...
                num2str(NNFitClass.findlongestzeros(Res))]);
            disp(' ')
            
            obj.RetH = zeros(length(obj.tr.testInd),1);
            obj.RetH(Res == 1 & obj.YFit==obj.hometarg) = ...
                homeodds(Res == 1 & obj.YFit==obj.hometarg)-1;
            obj.RetH(Res == 0 & obj.YFit==obj.hometarg) = -1;
            disp(['Home Fixed Stake Returns per Bet: ' num2str(...
                sum(obj.RetH)...
                /sum(obj.RetH(:)~=0))]);
            disp(['Number of Bets: ' num2str(nnz(obj.RetH(:)~=0))]);
            disp(['Home longest consecutive losses: ' num2str(...
                NNFitClass.findlongestzeros(Res(...
                obj.YFit == obj.hometarg)))]);
            disp(' ')
            
            obj.RetA = zeros(length(obj.tr.testInd),1);
            obj.RetA(Res == 1 & obj.YFit==obj.awaytarg) = ...
                awayodds(Res == 1 & obj.YFit==obj.awaytarg)-1;
            obj.RetA(Res == 0 & obj.YFit==obj.awaytarg) = -1;
            disp(['Away Fixed Stake Returns per Bet: ' num2str(...
                sum(obj.RetA)...
                /sum(obj.RetA(:)~=0))]);
            disp(['Number of Bets: ' num2str(nnz(obj.RetA(:)~=0))]);
            disp(['Home longest consecutive losses: ' num2str(...
                NNFitClass.findlongestzeros(Res(...
                obj.YFit == obj.awaytarg)))]);
            disp(' ')
            
            obj.RetD = zeros(length(obj.tr.testInd),1);
            obj.RetD(Res == 1 & obj.YFit==obj.drawtarg) = ...
                drawodds(Res == 1 & obj.YFit==obj.drawtarg)-1;
            obj.RetD(Res == 0 & obj.YFit==obj.drawtarg) = -1;
            disp(['Draw Fixed Stake Returns per Bet: ' num2str(...
                sum(obj.RetD)...
                /sum(obj.RetD(:)~=0))]);
            disp(['Number of Bets: ' num2str(nnz(obj.RetD(:)~=0))]);
            disp(['Home longest consecutive losses: ' num2str(...
                NNFitClass.findlongestzeros(Res(...
                obj.YFit == obj.drawtarg)))]);
            disp(' ')
            
            oddstemp = zeros(length(obj.oddstest),1);           
            %Prepare oddstest for analysis.
            oddstemp(obj.YFit == obj.hometarg) = ...
                homeodds(obj.YFit == obj.hometarg);
            oddstemp(obj.YFit == obj.awaytarg) = ...
                awayodds(obj.YFit == obj.awaytarg);
            oddstemp(obj.YFit == obj.drawtarg) = ...
                drawodds(obj.YFit == obj.drawtarg);
            
            obj.oddstest = oddstemp;
            
            obj.optodds( obj.Ret, 'All Results' );
            
        end
        
        %Calculate returns in the case of horse racing.
        function obj = NNFootball25returns(obj)
            
            disp('Accuracy statistics')
            disp('--');
            Res = zeros(length(obj.tr.testInd),1);
            Res(obj.vectargets == obj.YFit) = 1;
            
            disp(['Accuracy: ', num2str(100*sum(Res...
                )/length(Res)), '%']);
            
            disp(' ')
            
            disp('Returns statistics B365')
            disp('--');
            
            %Slice to test indices oddstest.
            obj.oddstest = obj.odds(obj.tr.testInd, :);
            
            %Separate odds into different results.
            overodds = obj.oddstest(:,strcmp( ...
                cellfun(@(x) x(end),obj.oddsvar,'un',0) ,'1'));
            underodds = obj.oddstest(:,strcmp( ...
                cellfun(@(x) x(end),obj.oddsvar,'un',0) ,'5'));
                       
            obj.overtarg = 2;
            obj.undertarg = 1;
                       
            disp(['Over 2.5 Test Success Rate: ', num2str(100*sum(...
                Res(...
                obj.YFit == obj.overtarg))/...
                length(Res(obj.YFit == obj.overtarg))),...
                '%']);
            disp(['Under 2.5 Test Success Rate: ', num2str(100*sum(...
                Res(...
                obj.YFit == obj.undertarg))/...
                length(Res(obj.YFit == obj.undertarg))), '%']);

            disp(' ')
            
            obj.Ret = -1*ones(length(obj.tr.testInd),1);
            obj.Ret(Res == 1 & obj.YFit==obj.overtarg) = ...
                overodds(Res == 1 & obj.YFit==obj.overtarg)-1;
            obj.Ret(Res == 1 & obj.YFit==obj.undertarg) = ...
                underodds(Res == 1 & obj.YFit==obj.undertarg)-1;
            %%%HERE
            disp(['Fixed Stake Returns per Bet: '...
                num2str(sum(obj.Ret)/...
                nnz(obj.Ret(:)))]);
            disp(['Number of Bets: ' num2str(nnz(obj.Ret(:)))]);
            disp(['Longest consecutive losses: ' ...
                num2str(NNFitClass.findlongestzeros(Res))]);
            disp(' ')
            
            obj.RetO = zeros(length(obj.tr.testInd),1);
            obj.RetO(Res == 1 & obj.YFit==obj.overtarg) = ...
                overodds(Res == 1 & obj.YFit==obj.overtarg)-1;
            obj.RetO(Res == 0 & obj.YFit==obj.overtarg) = -1;
            disp(['Over 2.5 Stake Returns per Bet: ' num2str(...
                sum(obj.RetO)...
                /sum(obj.RetO(:)~=0))]);
            disp(['Number of Bets: ' num2str(nnz(obj.RetO(:)~=0))]);
            disp(['Over 2.5 longest consecutive losses: ' num2str(...
                NNFitClass.findlongestzeros(Res(...
                obj.YFit == obj.overtarg)))]);
            disp(' ')
            
            obj.RetU = zeros(length(obj.tr.testInd),1);
            obj.RetU(Res == 1 & obj.YFit==obj.undertarg) = ...
                underodds(Res == 1 & obj.YFit==obj.undertarg)-1;
            obj.RetU(Res == 0 & obj.YFit==obj.undertarg) = -1;
            disp(['Under Fixed Stake Returns per Bet: ' num2str(...
                sum(obj.RetU)...
                /sum(obj.RetU(:)~=0))]);
            disp(['Number of Bets: ' num2str(nnz(obj.RetU(:)~=0))]);
            disp(['Home longest consecutive losses: ' num2str(...
                NNFitClass.findlongestzeros(Res(...
                obj.YFit == obj.undertarg)))]);
            disp(' ')
                      
            %Prepare oddstest for analysis.
            oddstemp(obj.YFit == obj.overtarg) = ...
                overodds(obj.YFit == obj.overtarg);
            oddstemp(obj.YFit == obj.undertarg) = ...
                underodds(obj.YFit == obj.undertarg);
            
            obj.oddstest = oddstemp;
            
            obj.optodds( obj.Ret, 'Over Under 2.5 All Results' );
            
        end
        
         %Calculate returns in the case of horse racing.
        function obj = NNFootballAHreturns(obj)
            
            disp('Accuracy statistics')
            disp('--');
            Res = zeros(length(obj.tr.testInd),1);
            Res(obj.vectargets == obj.YFit) = 1;
            
            disp(['Accuracy: ', num2str(100*sum(Res...
                )/length(Res)), '%']);
            
            disp(' ')
            
            disp('Returns statistics B365')
            disp('--');
            
            %Slice to test indices oddstest.
            obj.oddstest = obj.odds(obj.tr.testInd, :);
            
            %Separate odds into different results.
            ahhomeodds = obj.oddstest(:,strcmp( ...
                cellfun(@(x) x(end),obj.oddsvar,'un',0) ,'H'));
            ahawayodds = obj.oddstest(:,strcmp( ...
                cellfun(@(x) x(end),obj.oddsvar,'un',0) ,'A'));
            ahhalfhomeodds = ahhomeodds/2;
            ahhalfawayodds = ahawayodds/2;
            ahsrodds = zeros(size(ahhomeodds));
            
            obj.ahhometarg = mean(obj.vectargets(strcmp(obj.targraw(...
                obj.tr.testInd),'H')));

            obj.ahawaytarg = mean(obj.vectargets(strcmp(obj.targraw(...
                obj.tr.testInd),'A')));
            
            obj.ahhalfhometarg = mean(obj.vectargets(strcmp(obj.targraw(...
                obj.tr.testInd),'HH')));

            obj.ahhalfawaytarg = mean(obj.vectargets(strcmp(obj.targraw(...
                obj.tr.testInd),'HA')));
            
            obj.ahsrtarg = mean(obj.vectargets(strcmp(obj.targraw(...
                obj.tr.testInd),'SR')));
          
            disp(['Test Success Rate: ', num2str(100*sum(...
                Res/ length(Res))), '%']);
            disp(' ')
            
            obj.Ret = -1*ones(length(obj.tr.testInd),1);
            obj.Ret(Res == 1 & obj.YFit==obj.ahhometarg) = ...
                ahhomeodds(Res == 1 & obj.YFit==obj.ahhometarg)-1;
            obj.Ret(Res == 1 & obj.YFit==obj.ahawaytarg) = ...
                ahawayodds(Res == 1 & obj.YFit==obj.ahawaytarg)-1;
            obj.Ret(Res == 1 & obj.YFit==obj.ahhalfhometarg) = ...
                ahhalfhomeodds(Res == 1 & obj.YFit==obj.ahhalfhometarg)...
                /2-1;
            obj.Ret(Res == 1 & obj.YFit==obj.ahhalfawaytarg) = ...
                ahhalfawayodds(Res == 1 & obj.YFit==obj.ahhalfawaytarg)...
                -1;
            obj.Ret(Res == 1 & obj.YFit==obj.ahsrtarg) = 0;
            
            disp(['Fixed Stake Returns per Bet: '...
                num2str(sum(obj.Ret)/...
                nnz(obj.Ret(:)))]);
            disp(['Number of Bets: ' num2str(nnz(obj.Ret(:)))]);
            disp(['Longest consecutive losses: ' ...
                num2str(NNFitClass.findlongestzeros(Res))]);
            disp(' ')
                        
            oddstemp = zeros(length(obj.oddstest),1);           
            %Prepare oddstest for analysis.
            oddstemp(obj.YFit == obj.ahhometarg) =...
                ahhomeodds(obj.YFit == obj.ahhometarg);
            oddstemp(obj.YFit == obj.ahawaytarg) =...
                ahawayodds(obj.YFit == obj.ahawaytarg);
            oddstemp(obj.YFit == obj.ahhalfhometarg) =...
                ahhalfhomeodds(obj.YFit == obj.ahhalfhometarg);
            oddstemp(obj.YFit == obj.ahhalfhometarg) = ...
                ahhalfhomeodds(obj.YFit == obj.ahhalfhometarg);
            oddstemp(obj.YFit == obj.ahsrtarg) = ...
                ahsrodds(obj.YFit == obj.ahsrtarg);
            
            obj.oddstest = oddstemp;
            
            obj.optodds( obj.Ret, 'Asian Handicap All Results' );
            
        end
        
        function obj = FootballNNpredict( obj )
            
            obj.NNpredict;
           
            %Convert to results strings.
            obj.pred(...
                obj.pred == obj.hometarg)...
                = 'H';
            obj.pred(...
                obj.pred == obj.awaytarg)...
                = 'A';
            obj.pred(...
                obj.pred == obj.drawtarg)...
                = 'D';
            
            obj.predtab.Prediction = char(obj.pred');
            
            disp('Future Result Predictions:')
            disp(sortrows(obj.predtab(:, [1:4 end])))
            
        end
        
        function obj = Football25NNpredict( obj )
            
            obj.NNpredict;
            
            predvec = cell(length(obj.pred), 1);
            %Convert to results strings.
            predvec(...
                obj.pred == obj.overtarg)...
                = {'Over'};
            predvec(...
                obj.pred == obj.undertarg)...
                = {'Under'};
            
            obj.predtab.Prediction = predvec;
            
            disp('Future Result Predictions:')
            disp(sortrows(obj.predtab(:, [1:4 end])))
            
        end
        
                function obj = FootballAHNNpredict( obj )
            
            obj.NNpredict;
            
            %Convert to results strings.
            obj.pred(...
                obj.pred == obj.ahhometarg)...
                = deal('H');
            obj.pred(...
                obj.pred == obj.ahawaytarg)...
                = deal('A');
            
            if any(obj.pred == obj.ahhalfhometarg)
                
                obj.pred(...
                    obj.pred == obj.ahhalfhometarg)...
                    = deal('HH');
                
            end
            
            if any(obj.pred == obj.ahhalfawaytarg)
                
                obj.pred(...
                    obj.pred == obj.ahhalfawaytarg)...
                    = deal('HA');
                
            end
            
            if any(obj.pred == obj.ahsrtarg)
                obj.pred(...
                    obj.pred == obj.ahsrtarg)...
                    = deal('SR');
            end
            
            obj.predtab.Prediction = char(obj.pred');
            
            disp('Future Result Predictions:')
            disp(sortrows(obj.predtab(:, [1:4 end])))
            
        end
        
    end
    
end