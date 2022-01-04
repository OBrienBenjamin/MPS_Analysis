function [VarStruct] = CalcMPS_GitHub(VarStruct, Par, FEAT, Path)
newFs = 16000; % % % new sampling frequency

TM = Par.TM;
SM = Par.SM;
Type = Par.Type;
Args = []; % keep this --> don't change / remove

for i = 1:length(VarStruct)
    % % % load audio file (.wav format ONLY)
    [snd, fs] = audioread([Path.Home, VarStruct(i).Name, '.wav']);
    
    for j = 1:length(VarStruct(i).Unit)
        fprintf('unit: %d\n', j);
        % start frame
        first =  floor(VarStruct(i).Unit(j).T1 * fs);
        
        if VarStruct(i).Unit(j).T1 == 0; first = 1; end
        
        % end frame
        last = floor(VarStruct(i).Unit(j).T2 * fs);
        
        if last > length(snd(:,1)); last = length(snd(:,1)); end
        
        % need to resample waveform
        [p, q] = rat(newFs / fs);
        rsSnd = resample(snd(first:last, 1), p, q);
        
        % % % % Adeen Flinker function
        % % % transform audio signal to time-frequency representation
        [sndTF] = STM_CreateTF(rsSnd, newFs, 'gauss');
        
        % % % remove spectral 'leak'
        sndTF.TF = sndTF.TF - mean(mean(sndTF.TF));
        
        % % % calc MPS
        switch Par.Fmt
            case 'BP' % % % bandpass
                
                % % % Temporal Modulation (in Hz; across x-axis)
                for k = 1:length(TM)
                    % % % % Adeen Flinker function
                    [MPS] = STM_Filter_Mod(sndTF, TM(k,:), [], Args, Type);
                    
                    % % % identify non-zeroes (vertically)
                    ids = [];
                    for l = 1:length(MPS.new_MS(1,:));  if MPS.new_MS(1,l) ~= 0; ids = [ids, l]; end; end
                    
                    % % % check that values are within range
                    add = [];
                    for l = 1:length(ids)
                        if round(abs(MPS.x_axis(ids(l))), 2) >= TM(k, 1) && round(abs(MPS.x_axis(ids(l))), 2) <= TM(k, 2)
                            add = [add, MPS.orig_MS(:, ids(l)).^2];
                        end
                    end
                    VarStruct(i).Unit(j).(['TM_', num2str(k)]) = sum(add(:)) / sum(MPS.orig_MS(:).^2);
                end
                
                % % % Spectral Modulation (in cyc/oct; across y-axis)
                for k = 1:length(SM)
                    % % % % Adeen Flinker function
                    [MPS] = STM_Filter_Mod(sndTF, [], SM(k,:), Args, Type);
                    
                    % identify non-zeroes (horizontally)
                    ids = [];
                    for l = 1:length(MPS.new_MS(:,1));  if MPS.new_MS(l,1) ~= 0; ids = [ids, l]; end; end
                    
                    % % % check that values are within range
                    add = [];
                    for l = 1:length(ids)
                        if round(abs(MPS.y_axis(ids(l))), 2) >= SM(k, 1) && round(abs(MPS.y_axis(ids(l))), 2) <= SM(k, 2)
                            add = [add, MPS.orig_MS(ids(l),:).^2];
                        end
                    end
                    VarStruct(i).Unit(j).(['SM_', num2str(k)]) = sum(add(:)) / sum(MPS.orig_MS(:).^2);
                end
            case 'GD' % % % Grid
                for k = 1:length(TM)
                    for l = 1:length(SM)
                        % % % % Adeen Flinker function
                        [MPS] = STM_Filter_Mod(sndTF, TM(k,:), SM(l,:), Args, Type);
                        
                        % % % find all non-zeros
                        tm = []; sm = [];
                        for m = 1:length(MPS.new_MS(:,1)) % % % horizontally (sm)
                            for n = 1:length(MPS.new_MS(m,:)); % % % vertically (tm)
                                if MPS.new_MS(m,n) ~= 0
                                    tm = [tm, n]; sm = [sm, m];
                                end
                            end
                        end
                        
                        add = [];
                        for n = 1:length(tm)
                            % % % check that's in range (tm)
                            if round(abs(MPS.x_axis(tm(n))), 2) >= TM(k, 1) && round(abs(MPS.x_axis(tm(n))), 2) <= TM(k, 2)
                                % % % check that's in range (sm)
                                if round(abs(MPS.y_axis(sm(n))), 2) >= SM(l, 1) && round(abs(MPS.y_axis(sm(n))), 2) <= SM(l, 2)
                                    add = [add, MPS.orig_MS(sm(n), tm(n)).^2];
                                end
                            end
                        end

                        VarStruct(i).Unit(j).(['TM_', num2str(k), '_SM_', num2str(l)]) = sum(add(:)) / sum(MPS.orig_MS(:).^2);
                    end
                end
        end
        
        % % % add duration
        VarStruct(i).Unit(j).Dur = length(snd(first:last, 1)) / fs;
        
        % % % save audio file?
        if FEAT.SAV == 1;
            audiowrite([Path.Output, VarStruct(i).Name, '_', VarStruct(i).Unit(j).Txt, '.wav'], rsSnd, newFs)
        end
    end
    
    fprintf('audio file: %d\n', i);
end
end
