data = load("data_allPatients_expanded.mat");

data=data.data;

data=prepData(data,{'hr','cci','map','etco2','fio2','eto2','spo2','rso2avg','des','sev'});
data = addTransformData(data);
%remove empty (if patients removed for not having vapour pressures)
data = data(~cellfun('isempty',data));
dataSize = length(data);
[desatData,controlData,desatCountTable,controlCountTable] = classificationModelTSF_slopes_forKfoldCV_eventLevelSplit(data);

removeIndices = [];
[heightDesatData,~]=size(desatData);
[heightControlData,~]=size(controlData);
for i = 1:heightDesatData
    if isempty(desatData{i,1})
        removeIndices = [removeIndices i];
    end
end
keepIndices = setdiff(1:heightDesatData,removeIndices);
desatData = desatData(keepIndices,:);
removeIndices = [];
for i = 1:heightControlData
    if isempty(controlData{i,1})
        removeIndices = [removeIndices i];
    end
end
keepIndices = setdiff(1:heightControlData,removeIndices);
controlData = controlData(keepIndices,:);

%update counts
[heightDesatData,~]=size(desatData);
[heightControlData,~]=size(controlData);



clear data
k = 5;

desats = 1:heightDesatData;
desats = desats(randperm(heightDesatData));
rDesats = desats(1,heightDesatData-rem( heightDesatData, k )+1:heightDesatData);
desats = reshape(desats(1:floor(heightDesatData/k)*k),k,[]);

controls = 1:heightControlData;
controls = controls(randperm(heightControlData));
rControls =  controls(1,heightControlData-rem( heightControlData, k )+1:heightControlData);
controls = reshape(controls(1:floor(heightControlData/k)*k),k,[]);

indices = 1:k;
while ~isempty(rControls)
    controls(length(rControls),floor(heightControlData/k)+1)= rControls(1);
    rControls = rControls(2:length(rControls));
end
while ~isempty(rDesats)
    desats(length(rDesats),floor(heightDesatData/k)+1)= rDesats(1);
    rDesats = rDesats(2:length(rDesats));
end
for i = indices
    
    rows = indices;
    controlDataTestSet = controls(i,:);
    desatDataTestSet = desats(i,:);
    rows = rows(rows~=i);
    if (i < k)
        controlDataValSet = controls(i+1,:);
        desatDataValSet = desats(i+1,:);
        rows = rows(rows~=i+1);
        controlDataTrainSet = controls(rows,:); 
        desatDataTrainSet = desats(rows,:);
    else
        controlDataValSet = controls(1,:);
        desatDataValSet = desats(1,:);
        rows = rows(rows~=1);
        controlDataTrainSet = controls(rows,:); 
        desatDataTrainSet = desats(rows,:);
    end
    
    controlDataVal = controlData(controlDataValSet(controlDataValSet~=0),:);
    controlDataTest = controlData(controlDataTestSet(controlDataTestSet~=0),:);
    controlDataTrain = controlData(controlDataTrainSet(controlDataTrainSet~=0),:);   
    
    desatDataVal = desatData(desatDataValSet(desatDataValSet~=0),:);
    desatDataTest = desatData(desatDataTestSet(desatDataTestSet~=0),:);
    desatDataTrain = desatData(desatDataTrainSet(desatDataTrainSet~=0),:);
       
    controlDataTest = controlDataTest(~cellfun('isempty',controlDataTest));
    desatDataTest = desatDataTest(~cellfun('isempty',desatDataTest));
    controlDataTrain = controlDataTrain(~cellfun('isempty',controlDataTrain));
    desatDataTrain = desatDataTrain(~cellfun('isempty',desatDataTrain));
    controlDataVal = controlDataVal(~cellfun('isempty',controlDataVal));
    desatDataVal = desatDataVal(~cellfun('isempty',desatDataVal));
        
    [xTrain,yTrain]=prepForRocket(desatDataTrain', controlDataTrain',{'rso2avg','baseline','et_raw_co2'});
    [xVal,yVal]=prepForRocket(desatDataVal', controlDataVal',{'rso2avg','baseline','et_raw_co2'});
    [xTest,yTest]=prepForRocket(desatDataTest', controlDataTest',{'rso2avg','baseline','et_raw_co2'});

    disp('saving files for rocket');
    save(strcat('xTest',num2str(i),'.mat'),'xTest');
    save(strcat('xTrain',num2str(i),'.mat'),'xTrain');
    save(strcat('yTest',num2str(i),'.mat'),'yTest');
    save(strcat('yTrain',num2str(i),'.mat'),'yTrain');
    save(strcat('xVal',num2str(i),'.mat'),'xVal');
    save(strcat('yVal',num2str(i),'.mat'),'yVal');
    
end

disp('total downslope events:');
disp(sum(desatCountTable(:,2)));
disp('from ___ patients:');
disp(sum(desatCountTable(:,2)>0));
disp('total upslope events:');
disp(sum(controlCountTable(:,2)));
disp('from ___ patients:');
disp(sum(controlCountTable(:,2)>0));

disp('total events for model:');
disp(length(xTrain)+length(xTest)+length(xVal));