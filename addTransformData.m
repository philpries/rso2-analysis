function data = addTransformData(data)

for i = 1:length(data)
    %rso2
    data{1,i}.rso2avg = fillmissing(data{1,i}.rso2avg,'linear','EndValues','nearest');
    %data{1,i}.rso2avg = data{1,i}.rso2avg - mean(data{1,i}.baseline,'omitnan');
    %cci, hr, map, eto2, etco2, fio2, spo2
    %cci
    data{1,i}.cci = fillmissing(data{1,i}.cci,'linear','EndValues','nearest');
    data{1,i}.cci = data{1,i}.cci - mean(data{1,i}.cci,'omitnan');
     
    %hr
    %normalize
    data{1,i}.hr = fillmissing(data{1,i}.hr,'linear','EndValues','nearest');
    data{1,i}.hr = data{1,i}.hr - mean(data{1,i}.hr,'omitnan');      
    
    %map
    data{1,i}.map = fillmissing(data{1,i}.map,'linear','EndValues','nearest');
    data{1,i}.map = data{1,i}.map - mean(data{1,i}.map,'omitnan'); 

    %etO2
    data{1,i}.eto2 = fillmissing(data{1,i}.eto2,'linear','EndValues','nearest');
    data{1,i}.eto2 = data{1,i}.eto2 - mean(data{1,i}.eto2,'omitnan');
    
    %etco2
    data{1,i}.etco2= fillmissing(data{1,i}.etco2,'linear','EndValues','nearest');
    %data{1,i}.et_raw_co2 = data{1,i}.etco2;
    data{1,i}.etco2 = data{1,i}.etco2 - mean(data{1,i}.etco2,'omitnan');

    %fio2 -
    data{1,i}.fio2 = fillmissing(data{1,i}.fio2,'linear','EndValues','nearest');
    % normalize around fiO2 = 0.4
    data{1,i}.fio2 = data{1,i}.fio2 - 40;
    
    %spo2
    data{1,i}.spo2 = fillmissing(data{1,i}.spo2,'linear','EndValues','nearest');
  %  normalize around spo02 = 95
    data{1,i}.spo2 = data{1,i}.spo2 - 95;
       
    %add sham variable
    data{1,i}.z_sham = rand(length(data{1,i}.rso2avg),1);
  
  %add MAC
    try
        data{1,i}.mac = data{1,i}.sev/2.2;
        data{1,i} = removevars(data{1,i},'sev');
        data{1,i}.mac = data{1,i}.mac - mean(data{1,i}.mac,'omitnan');
        data{1,i}.mac = fillmissing(data{1,i}.mac,'linear','EndValues','nearest');
    catch
        try
            data{1,i}.mac = data{1,i}.des/6.0;
            data{1,i} = removevars(data{1,i},'des');
            data{1,i}.mac = data{1,i}.mac - mean(data{1,i}.mac,'omitnan');
            data{1,i}.mac = fillmissing(data{1,i}.mac,'linear','EndValues','nearest');
        catch
            %no vapour for this patient
            data{1,i} = [];
        end
    end
end