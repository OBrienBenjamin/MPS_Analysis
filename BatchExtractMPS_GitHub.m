% % % The script completes the following 
% % % (1) loads audio / textgrid files in a directory 
% % % (2) identifies the phonetic tier desired and makes audio extractions
% % % (3) calculates the MPS for each audio extraction at desired intervals

% % % Parameters 
% % % filter : Band (ex. 1-2 Hz or 0.5-1 cyc/oct) or Grid (intersection of 1-2 Hz & 0.5-1 cyc/oct)
% % % phonetic tier: phone, CVC, word, sentence - depends on TextGrid
% % % option to save audio excerpts

% % % % /path/to/dir/of/samples
Path.Home = '/Users/benji/Desktop/MPS_Analysis/Quebec/';

% % % % /path/to/output/
Path.Output = '/Users/benji/Desktop/MPS_Analysis/';

% % % name of output file
Path.Filename = 'MPS_Analysis_SEN_Grid.xlsx';

% % % MPS filtering: band-pass ('BP') or grid ('GD')
Type.Fmt = 'GD';

% % % Tier to analyse
UNT.TIER = 6;
UNT.CVC = 0; % % % To analyse CVC set to 1, otherwise 0

% % % Do you want to save (1) or not (0) each recording?
Feat.SAV = 0;

% % % make sure the format is 'TextGrid' (CASE SENSITIVE)
TXT = 'TextGrid';

% % % your list of vowels (for CVC) 
% % % an example
Type.Vow = {'a', 'e', 'E', 'i', 'O', 'o', 'y', '9', '9~', '@', 'u', 'a~', 'o~', 'e~'};

% % % MPS parameters
Type.Type = 'bandpass';
Type.TM = [[1., 2.]; [2., 4.]; [4., 8.]; [8., 16.]; [16., 32.];];
Type.SM = [[0.25, 0.5]; [0.5, 1.]; [1., 2.]; [2., 4.]];

% % % % % % % % % % % % % % % % % %
% % % % % % DO NOT TOUCH % % % %
% % % % % % % % % % % % % % % % % %

% % % Load and extract
[Samp] = LoadFilesExtract_GitHub(Path.Home, TXT, UNT, Type.Vow);

% % % % % Calculate MPS
[Samp] = CalcMPS_GitHub(Samp, Type, Feat, Path);

% % % % output to excel
SaveMPS_GitHub(Path, Samp, Type);

