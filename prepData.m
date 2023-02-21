function data = prepData(data,varsToInclude)

for i = 1:length(data)
    vars = data{1,i}.Properties.VariableNames;
    for var = vars
        if ~any(contains(varsToInclude,var))
            try
                data{1,i} = removevars(data{1,i},var);
            end
        end
    end
end

