function [desatData,controlData,desatCountTable,controlCountTable] = classificationModelTSF_slopes_forKfoldCV_eventLevelSplit(data)
%%%CLASSIFICATION MODEL TIME SERIES FINDER(TSF)------------------------

%modifiable header variables
desatLength = 300;%seconds
sampleFrequency = 0.5;%hz
leadupLength = 0;%seconds, time prior to desat start to include in time series
desatThreshold = 0.15;%percentage deviation of rso2
desatSlopeRun = 300;%seconds

%---------------------------------------------------------------------
%static variables based on above
postDesatLength = round(desatLength * sampleFrequency);
preDesatLength = round(leadupLength * sampleFrequency);

%totalSequenceLength = preDesatLength + postDesatLength;

desatData = {};
controlData = {};

desatCountTable =[[1:length(data)]' zeros(length(data),1)];
controlCountTable =[[1:length(data)]' zeros(length(data),1)];

desatCount_discrete=0;
controlCount_discrete=0;
for i = 1:length(data)
    disp(i);
    
    [changePoints,slopes]=getSlopes(data{1,i}.rso2avg,postDesatLength,length(data{1,i}.rso2avg)*0.05);
  
    desats = slopes <= -0.02;
    controls = slopes >= 0.02;
    desatIndices = find(desats);
    controlIndices = find(controls);
    
    desatCountTable(i,2)=length(desatIndices);
    controlCountTable(i,2)=length(controlIndices);
    
    %add desats (negative slopes)
    for d = 1:length(desatIndices)
        desatCount_discrete = desatCount_discrete + 1;
        desatCount = 0;
        index = changePoints(desatIndices(d));
        eventStart = index-preDesatLength;
        if (eventStart <= 0)
            eventStart = 1;
        end
        eventFinish = eventStart + postDesatLength;
        
        while eventStart > 0 && eventFinish < (changePoints(desatIndices(d)+1) - preDesatLength)
            
            sample = data{1,i}(eventStart:eventFinish-1,:);            
            if ~any(ismissing(sample),'all')
                desatCount = desatCount + 1;
                %add sequence of data from 'windowLength' seconds prior to desat,
                %up until first 'desatLength' of seconds of desat

                desatData{desatCount_discrete,desatCount}= sample;
            end            
            
            eventStart = eventStart + 1;
            eventFinish = eventFinish + 1;
        end
    end
       
    %add controls
    for c = 1:length(controlIndices)
        controlCount_discrete = controlCount_discrete + 1;
        controlCount = 0;
        index = changePoints(controlIndices(c));
        eventStart = index-preDesatLength;
        if (eventStart <= 0)
            eventStart = 1;
        end
        eventFinish = eventStart + postDesatLength;
        while eventStart > 0 && eventFinish < (changePoints(controlIndices(c)+1) - preDesatLength)
            
            sample = data{1,i}(eventStart:eventFinish-1,:);            
            if ~any(ismissing(sample),'all')
                controlCount = controlCount + 1;
                %add sequence of data from 'windowLength' seconds prior to desat,
                %up until first 'desatLength' of seconds of desat
                controlData{controlCount_discrete,controlCount}= sample;
            end            
            
            eventStart = eventStart + 1;
            eventFinish = eventFinish + 1;
        end
    end  
end