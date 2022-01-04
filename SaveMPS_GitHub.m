function[] = SaveMPS_GitHub(Path, VarStruct, Par)
% % % % init
TM = Par.TM;
SM = Par.SM;

Grid = [];
if strcmp(Par.Fmt, 'BP')
    for i = 1:length(TM)
        Grid.(['TM_', num2str(i)]) = [];
    end
    
    for i = 1:length(SM)
        Grid.(['SM_', num2str(i)]) = [];
    end
    
else % % % Grid
    for i = 1:length(TM)
        for j = 1:length(SM)
            Grid.(['TM_', num2str(i), '_SM_', num2str(j)]) = [];
        end
    end
end

% % % format data for saving
File = []; Unit = []; Dur = [];
c = 0;
for i = 1:length(VarStruct)
    for j = 1:length(VarStruct(i).Unit)
        c = c + 1;
        File{c} = VarStruct(i).Name;
        Unit{c} = VarStruct(i).Unit(j).Txt;
        
        bands = fieldnames(Grid);
        for k = 1:length(bands)
            Grid.(bands{k}) = [Grid.(bands{k}), VarStruct(i).Unit(j).(bands{k})];
        end
        
        Dur = [Dur, VarStruct(i).Unit(j).Dur];
    end
end

% % % % % save to table, excel
% % % File info data
Info_table = table(File', Unit', 'VariableNames', {'File', 'Unit'});

% % % MPS table data
MPS_data = cell2mat(struct2cell(Grid));
MPS_table = array2table(MPS_data', 'VariableNames', bands);

% % % Dur table data
Dur_table = table(Dur', 'VariableNames', {'Dur'});

% % % combine tables
T = [Info_table MPS_table Dur_table];

writetable(T, [Path.Output, Path.Filename]);
end
