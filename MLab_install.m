%MLab Installation script
%
%   This script installs MLab on your computer. It can be executed with or
%   without Matlab's java desktop.
%
%   --- PRE-REQUISITES
%
%   - Matlab (R2014b or higher)
%   - Internet connection
%
%   --- FOOTPRINT
%
%   During the installation process only one folder called "MLab" is
%   created. It contains all MLab programs, and also all the plugins you
%   may install afterwards.
%
%   Note that after successful install, MLab is automaticaally started and
%   a configuration file called "MLab.mat" is created in Matlab's prefdir.
%   A configuration file called "MLab.[Plugin name].mat" may also be
%   created each time you install a plugin.
%
%   NB: This installation file will self-destruct after installation is
%   complete.
%
%   A word on startup.m files.
%
%   See also ML.uninstall, prefdir

% --- PARAMETERS ----------------------------------------------------------

% URL of the git repository
repo = 'https://github.com/MLab-repo/MLab.git';

% Display pause time
dpt = 0.1;

% --- CHECKS --------------------------------------------------------------

% Matlab version
if verLessThan('matlab', '8.5.0')
    warning('MLab:Version', 'Your version of Matlab is too old. R2014b or higher is requested for MLab.');
    return;
end

% --- PREPARATION ---------------------------------------------------------

% Default installation folder
root = [pwd filesep 'MLab' filesep];

% Startup files
fname_startup = fullfile(matlabroot, 'toolbox', 'local', 'startup.m');
fname_startup_MLab = fullfile(matlabroot, 'toolbox', 'local', 'startup_MLab.m');

% --- USER INPUT ----------------------------------------------------------

while true
    
    clc
    Notes = {};
    
    cws = get(0,'CommandWindowSize');
    
    if usejava('desktop')
        fprintf('\n--- [\b<strong>MLab installation</strong>]\b %s\n\n', repmat('-', [1 cws(1)-23]));
        fprintf('You are about to install [\bMLab]\b on this computer.\n\n');
        fprintf('Install location:\n\t<strong>%s</strong>\n\n', root);
    else
        fprintf('\n--- \033[1;33;40mMLab installation\033[0m %s\n\n', repmat('-', [1 cws(1)-23]));
        fprintf('You are about to install \033[1;33;40mMLab\033[0m on this computer.\n\n');
        fprintf('Install location:\n\t\033[1m%s\033[0m\n\n', root);
    end
    
    % Check for MLab folder existence
    if exist(root, 'dir')
        if usejava('desktop')
            fprintf('[\b<strong>WARNING !</strong>]\b This folder already exists.\n');
            fprintf('\t<strong>Installation will totally erase existing content !</strong>\n\n');
        else
            fprintf('\033[1;31;40mWARNING !\033[0m This folder already exists.\n');
            fprintf('\t\033[1mInstallation will totally erase existing content !\033[0m\n\n');
        end
    else
        if usejava('desktop')
            Notes{end+1} = '* The [\bMLab]\b folder will be created automatically.';
        else
            Notes{end+1} = '* The \033[1;33;40mMLab\033[0m folder will be created automatically.';
        end
    end
    
    % Check for MLab configuration files
    cfiles = dir([prefdir filesep 'MLab*.mat']);
    if numel(cfiles)
        s = '* The following configuration files have been found:\n';
        for i = 1:numel(cfiles)
            s = [s '\t' cfiles(i).name '\n'];
        end
        s = [s '  They will be updated during installation.\n'];
        Notes{end+1} = s;
    end
    
    % Display notes
    if numel(Notes)
        
        if usejava('desktop')
            fprintf('<strong>Notes</strong>\n');
        else
            fprintf('\033[1mNotes\033[0m\n');
        end
        
        for i = 1:numel(Notes)
            fprintf([Notes{i} '\n']);
        end
    end
    
    % Display possible actions
    fprintf('Please choose an action:\n\n');
    
    if usejava('desktop')
        fprintf('\t[[\b<strong>i</strong>]\b]- Install MLab\n');
        fprintf('\t[[\b<strong>c</strong>]\b]- Change install location\n');
        fprintf('\t[[\b<strong>q</strong>]\b]- Quit\n\n');
    else
        fprintf('\t[\033[1;33;40mi\033[0m]- Install MLab\n');
        fprintf('\t[\033[1;33;40mc\033[0m]- Change install location\n');
        fprintf('\t[\033[1;33;40mq\033[0m]- Quit\n\n');
    end
    
    switch lower(input('?> ', 's'))
        
        case 'q'
            if usejava('desktop')
                fprintf('\n[\bInstallation aborted.]\b\n\n');
            else
                fprintf('\n\033[1;33;40mInstallation aborted.\033[0m\n\n');
            end
            return
            
        case 'c'
            fprintf('\nPlease enter the install location\n');
            tmp = input('?> ', 's');
            if ~isempty(tmp)
                root = tmp;
                if ~strcmp(root(end), filesep), root(end+1) = filesep; end
                [~, ld] = fileparts(root(1:end-1));
                if ~strcmp(ld, 'MLab')
                    root = [root 'MLab'];
                end
                root = [root filesep];
            end
            
        case 'i'
            break;
    end
end

% --- PREVIOUS MLAB INSTANCE ----------------------------------------------

if exist(root, 'dir')
    
    if usejava('desktop')
        fprintf('\n[\b<strong>Warning !</strong>]\b This folder already exists:\n\t<strong>%s</strong>\n\n', root);
    else
        fprintf('\n\033[1;33;40mWarning !\033[0m This folder already exists:\n\t\033[1m%s\033[0m\n\n', root);
    end
    fprintf('Are you sure you want to remove all its content and perform\na fresh install ? [Y/n]\n');
    
    while true
        
        tmp = lower(input('?> ', 's'));
        switch tmp
            case 'n'
                if usejava('desktop')
                    fprintf('\n[\bInstallation aborted.]\b\n\n');
                else
                    fprintf('\n\033[33;40mInstallation aborted.\033[0m\n\n');
                end
                return
            case {'', 'y'}
                break;
            otherwise
                fprintf('%s', repmat(char(8), [1 numel(tmp)+4]));
        end
    end
    
end

% --- INSTALLATION --------------------------------------------------------

% --- Header diplay

clc
if usejava('desktop')
    fprintf('\n--- [\b<strong>MLab installation</strong>]\b %s\n\n', repmat('-', [1 cws(1)-23]));
else
    fprintf('\n--- \033[1;33;40mMLab installation\033[0m %s\n\n', repmat('-', [1 cws(1)-23]));
end

% --- Startup

% Manage write permissions
sdir = fullfile(matlabroot, 'toolbox', 'local');
[status, fa] = fileattrib(sdir);
upca = false;
if isunix && ~fa.OtherWrite
    fprintf('Root access is needed to create the startup.m file.\n');
    unix(['sudo chmod o+w ' sdir]);
    upca = true;
else
    fileattrib(sdir, '+w', 'a');
end

fprintf('Creating startup files ...'); tic

% Create startup_MLab.m
[fid, msg] = fopen(fname_startup_MLab, 'w');

if fid<0
    if usejava('desktop')
        fprintf('\n[\b<strong>Error !</strong> The startup file could not be created.]\b\n\n');
    else
        fprintf('\n--- \033[1;33;40mError ! The startup file could not be created.\033[0m\n\n');
    end
    error('ML:install:fopenError', msg);
end

fprintf(fid, '%s', ['% === MLab startup ========================================================' newline ...
    '%' newline ...
    '% This code has been generated automatically, please do not modify it.' newline ...
    '% If you want to add custom startup instructions, please modify the file' newline ...
    '%' newline ...
    '% ' fname_startup newline ...
    '%' newline ...
    '% but be sure to keep the line running the startup_MLab script.' newline ...
    '%' newline ...
    '% =========================================================================' newline ...
    newline ...
    'if exist([prefdir filesep ''MLab.mat''], ''file'')' newline ...
    char(9) 'tmp = load([prefdir filesep ''MLab.mat'']);' newline ...
    char(9) 'addpath(genpath(tmp.config.path), ''-end'');' newline ...
    char(9) 'if tmp.config.startup.autostart' newline ...
    char([9 9]) 'ML.start' newline ...
    char(9) 'end' newline ...
    'end']);

fclose(fid);

% Create startup.m
cmd = 'if exist(''startup_MLab'')==2, startup_MLab; end';
if exist(fname_startup, 'file')
    
    % Check the content
    C = textscan(fileread(fname_startup), '%s', 'Delimiter', newline);
    if ~any(cellfun(@(x) strcmp(strtrim(x), cmd), C{1}))
        fid = fopen(fname_startup, 'a');
        fprintf(fid, '%s', [newline '% MLab startup' newline cmd]);
        fclose(fid);
    end
    
else
    fid = fopen(fname_startup, 'w');
    fprintf(fid, '%s', ['% MLab startup' newline cmd]);
    fclose(fid);
end

% Set write permissions back to the initial state
if upca
    unix(['sudo chmod o-w ' sdir]);
end

% Update
rehash toolboxcache

fprintf(' %.2f sec\n', toc);

% --- MLab folder

% Remove MLab folder
if exist(root, 'dir')
    fprintf('Removing existing MLab ...'); tic
    warning off
    rmdir(root, 's');
    warning on
    fprintf(' %.2f sec\n', toc);
    pause(dpt);
end

% Create MLab folder
fprintf('Creating MLab folder ...'); tic
mkdir(root);
fprintf(' %.2f sec\n', toc);
pause(dpt);

% Clone repository
fprintf('Cloning repository ...'); tic
cloneCMD = org.eclipse.jgit.api.Git.cloneRepository;
cloneCMD.setDirectory(java.io.File(root));
cloneCMD.setURI(repo);
cloneCMD.call;
fprintf(' %.2f sec\n', toc);
pause(dpt);

% Create Plugins folder
fprintf('Creating MLab plugins folder ...'); tic
mkdir([root 'Plugins']);
fprintf(' %.2f sec\n', toc);
pause(dpt);

% --- Configuration file

cfname = [prefdir filesep 'MLab.mat'];
if exist(cfname, 'file')
    
    fprintf('Modifying MLab configuration file ...'); tic
    tmp = load(cfname);
    oldconf = tmp.config;
    
    % Reset to default configuration
    cpwd = pwd;
    cd(root);
    ML.Config.default;
    
    tmp = load(cfname);
    config = tmp.config;
    
    % Maintain changes
    if isfield(oldconf, 'user')
        config.user = oldconf.user;
    end
    
    save(cfname, 'config');
    cd(cpwd);
    
    fprintf(' %.2f sec\n', toc);
    pause(dpt);
    
else
    
    ctmp = pwd;
    cd(root);
    ML.Config.default;
    cd(ctmp);
    
end

% --- Custom icon
if isunix
    
    fprintf('Customizing MLab folder icon ...'); tic
    
    unix(['gvfs-set-attribute -t string ' root ' metadata::custom-icon file:///' root 'Images/Icons/MLab.png']);
    
    fprintf(' %.2f sec\n', toc);
    
end

% --- Installation file self-destruction

fprintf('Self-destruction of the installer ...'); tic

% Definition
fname = [mfilename('fullpath') '.m'];

% Close installation file in the editor
if usejava('desktop') && matlab.desktop.editor.isEditorAvailable
    tmp = matlab.desktop.editor.getActive;
    if strcmp(fname, tmp.Filename), tmp.close; end
end

% Remove installation file
delete(fname);

fprintf(' %.2f sec\n', toc);
pause(dpt);

% --- FINAL MESSAGE -------------------------------------------------------

if usejava('desktop')
    
    fprintf('%s\n%s Your [\b<strong>MLab</strong>]\b install is successful !%s\n%s\n', ...
        [char(9484) repmat(char(9472), [1 cws(1)-3]) char(9488)], char(9474), ...
        [repmat(' ', [1 cws(1)-37]) char(9474)], ...
        [char(9492) repmat(char(9472), [1 cws(1)-3]) char(9496)]);
    
    fprintf('\nYou can start [\bMLab]\b by <a href="matlab:startup;">clicking here</a>.\n');
    
else
    
    fprintf('%s\n%s Your \033[1;33;40mMLab\033[0m install is successful !%s\n%s\n', ...
        [char(9484) repmat(char(9472), [1 cws(1)-3]) char(9488)], char(9474), ...
        [repmat(' ', [1 cws(1)-37]) char(9474)], ...
        [char(9492) repmat(char(9472), [1 cws(1)-3]) char(9496)]);
    
    fprintf('\nYou can start \033[1;33;40mMLab\033[0m by excuting the "startup" command.\n');
    
end
                                                                                          