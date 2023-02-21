function [x,y] = prepForRocket(desatData,controlData,varsToRemove)

for i = 1:length(desatData)
    %sort column names 
    desatData{1,i} = desatData{1,i}(:,sort(desatData{1,i}.Properties.VariableNames));    
end

for i = 1:length(controlData)
    controlData{1,i}= controlData{1,i}(:,sort(controlData{1,i}.Properties.VariableNames));
end

x =[desatData controlData];
y = zeros(1,length(x));
y(1,1:length(desatData)) = 1;


%remove unwanted vars
for i = 1:length(x)
    vars = x{1,i}.Properties.VariableNames;
    for var = vars
        if any(contains(varsToRemove,var))
            try
                x{1,i} = removevars(x{1,i},var);
            end
        end
    end
end


%reshape to fit into rocket

y =y';
x=x';

if ~isempty(x)
    numVars = width(x{1,1});
    for i = 1:length(x)
        temp = table2array(x{i,1});
        for j = 1:numVars        
            x{i,j} = temp(:,j);        
        end
    end
end

%shuffle
order = randperm(length(y));
y=y(order);
x=x(order,:);



