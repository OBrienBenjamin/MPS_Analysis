% % % if problems:
% % % confirm 'mPraat-master' dir is in path

function [Samples] = LoadFilesExtract_GitHub(home, txt, UNT, Vow)
% % % only look for text grid files
Samples = [];
c = 0;

f = dir(home);
for i = 1:length(f)
    if ~isempty(strfind(f(i).name, txt))
        c = c + 1;
        
        % % path/to/audio/path
        path = [home, '/', f(i).name];
        
        Samples(c).Name = f(i).name(1:end-9);
        Samples(c).Unit = [];
        
        % % % mPraat function
        TG = tgRead(path);

        % % % make sure these tiers lineup with your TextGrid file
        lvl = UNT.TIER;
        
        a = 0;
        for j = 1:length(TG.tier{1, lvl}.Label)
            if isempty(find(TG.tier{1, lvl}.Label{j} == '_', 1))
                if UNT.CVC == 1 % % % CVC
                    if ~isempty(find(ismember(Vow, TG.tier{1, lvl}.Label{j}), 1))
                        a = a + 1;
                        cvc = []; for k = j-1:j+1; cvc = [cvc, TG.tier{1, lvl}.Label{k}]; end
                        Samples(c).Unit(a).Txt = cvc;
                        Samples(c).Unit(a).T1 = TG.tier{1, lvl}.T1(j-1);
                        Samples(c).Unit(a).T2 = TG.tier{1, lvl}.T2(j+1);
                        Samples(c).Unit(a).Dur = TG.tier{1, lvl}.T2(j+1) - TG.tier{1, lvl}.T1(j-1);
                    end
                else
                    a = a + 1;
                    Samples(c).Unit(a).Txt = TG.tier{1, lvl}.Label{j};
                    Samples(c).Unit(a).T1 = TG.tier{1, lvl}.T1(j);
                    Samples(c).Unit(a).T2 = TG.tier{1, lvl}.T2(j);
                    Samples(c).Unit(a).Dur = TG.tier{1, lvl}.T2(j) - TG.tier{1, lvl}.T1(j);
                end
            end
        end
    end
    
end
end



