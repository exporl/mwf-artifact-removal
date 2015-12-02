
% get results for all subjects 

clear

artifact_type = 'muscle'; %blinks, muscle
% taumax = 3;
% gevd = 1;

for subject = 1:9

switch subject
    case 1
        name = 'alex';
    case 2
        name = 'anneleen';
    case 3
        name = 'hanneke';
    case 4
        name = 'jan-peter';
    case 5
        name = 'jeroen';
    case 6
        name = 'jonas';
    case 7
        name = 'lorenz';
    case 8
        name = 'otto';
    case 9
        name = 'steven';
end

% iterate over MWF modalities: MWF, MWF+GEVD, MWF+lags, MWF+GEVD+lags
taumax = 0; gevd = 0;
script_MWF_GEVD_lags
resultSER(subject,1) = SER; 
resultARR(subject,1) = ARR;

taumax = 0; gevd = 1;
script_MWF_GEVD_lags
resultSER(subject,2) = SER; 
resultARR(subject,2) = ARR;

taumax = 3; gevd = 0;
script_MWF_GEVD_lags
resultSER(subject,3) = SER; 
resultARR(subject,3) = ARR;

taumax = 3; gevd = 1;
script_MWF_GEVD_lags
resultSER(subject,4) = SER; 
resultARR(subject,4) = ARR;
end

if (strcmp(artifact_type,'muscle'))
    name = 'olivia';
    
    taumax = 0; gevd = 0;
    script_MWF_GEVD_lags
    resultSER(10,1) = SER;
    resultARR(10,1) = ARR;
    
    taumax = 0; gevd = 1;
    script_MWF_GEVD_lags
    resultSER(10,2) = SER;
    resultARR(10,2) = ARR;
    
    taumax = 3; gevd = 0;
    script_MWF_GEVD_lags
    resultSER(10,3) = SER;
    resultARR(10,3) = ARR;
    
    taumax = 3; gevd = 1;
    script_MWF_GEVD_lags
    resultSER(10,4) = SER;
    resultARR(10,4) = ARR;
end

difference = [resultSER(:,2)-resultSER(:,1), resultSER(:,3)-resultSER(:,1), resultSER(:,4)-resultSER(:,1)];
