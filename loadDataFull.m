function allData = loadDataFull

dataDir = dir('file:///Users/philpries/Documents/University/Residency/Research Project/Data Files/Useable Data/');
dirFlags = [dataDir.isdir];
subFolders = dataDir(dirFlags);

allData ={};

for i = 57:57%1:length(subFolders)
    disp(i);
    
    subFiles = dir(strcat(subFolders(i).folder,'/',subFolders(i).name));
    
    %load foresight data--------------------------------------------------
    foresight = strcat(subFiles(3).folder,'/',subFiles(3).name);
    
    %load foresight data
    opts = detectImportOptions(foresight,'Sheet','Cleaned');
    opts.VariableNames = {'Time','Ch1','Ch2','Avg'};
    opts =setvartype(opts,'Time',{'duration'});
    opts =setvartype(opts,'Avg',{'double'});
    opts.DataRange = 'B5';
    foresightData = readtable(foresight,opts);
    %foresightData = rmmissing(foresightData,'DataVariables','Time');
    %foresightData = rmmissing(foresightData,'DataVariables','Avg');
    if isempty(foresightData) %no avg rso2 (just onesided) or no baseline values
        continue
    end
    foresightData = table2timetable(foresightData);
    foresightData.Time = round(foresightData.Time,'seconds');
    
    %load other data (hemodynamics, ventilation, etc.)--------------------
    subj= strcat(subFiles(4).folder,'/',subFiles(4).name);
    opts = detectImportOptions(subj,'Sheet','Cleaned');
    opts.DataRange = 'A4';
    opts =setvartype(opts,'double');
    opts =setvartype(opts,'Time',{'duration'});
    subjData = readtable(subj,opts);
    subjData(:,1) = [];%remove date
    subjData = rmmissing(subjData,'DataVariables','Time');
    subjData = table2timetable(subjData);
    subjData.Time = round(subjData.Time,'seconds');
    
    fullData = synchronize(foresightData,subjData,'intersection');
    
    %re-name variables/re-format/keep only relevant variables
    fullData = timetable2table(fullData,'ConvertRowTimes',false);
    variables = fullData.Properties.VariableNames;
    
    for x = 1:length(variables)
        var = string(variables(x));
        switch var
            case 'Avg'
                fullData.Properties.VariableNames{var} = 'rso2avg';
            %case 'Ch1'
            %    fullData.Properties.VariableNames{var} = 'rso2ch1';
            %case 'Ch2'
            %    fullData.Properties.VariableNames{var} = 'rso2ch2';
            case 'HR'
                fullData.Properties.VariableNames{var} = 'hr';
            case {'ART_MEAN','ABP_MEAN'}
                fullData.Properties.VariableNames{var} = 'map';
            case {'SpO_','SpO_L'}
                fullData.Properties.VariableNames{var} = 'spo2';
            case 'CO__ET'
                fullData.Properties.VariableNames{var} = 'etco2';
            case 'O__INSP'
                fullData.Properties.VariableNames{var} = 'fio2';
            case 'O__ET'
                fullData.Properties.VariableNames{var} = 'eto2';
            case 'CCI'
                fullData.Properties.VariableNames{var} = 'cci';
            case 'DES_ET'
                fullData.Properties.VariableNames{var} = 'des';
            case 'SEV_ET'
                fullData.Properties.VariableNames{var} = 'sev';
            otherwise
                fullData = removevars (fullData,variables(x));
        end        
    end
    
    allData{i} = fullData;    
end
allData = allData(~cellfun('isempty',allData));










