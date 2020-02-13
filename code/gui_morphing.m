
function gui_morphing
close all;
clear all;

clearvars;
% add path to dependencies
addpath('cbrewer/');
addpath('/Users/neeks/Desktop/Documents/work/code/matlab_codes/others_codes/legacy_STRAIGHT/src'); % download from https://github.com/HidekiKawahara/legacy_STRAIGHT

% SIMPLE_GUI2 Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.

%  Create and then hide the UI as it is being constructed.
% f = figure('units','normalized','outerposition',[0 0 1 1]);
f = figure('Visible','off','Position',[360,800,900,600],'MenuBar','None','ToolBar','None'); %[cx,cy,width,height]

% Construct the components.
global qhd mqhd
qhd.ndivs = 3;
mqhd = cell(2,1);

enableload   = uicontrol(f,'Style','pushbutton',...
            'String','Enable Load','Position',[100,575,70,25],...
            'Callback',@enableload_Callback);

triaload   = uicontrol(f,'Style','pushbutton',...
            'String','Load Trial','Position',[10,575,70,25],...
            'Callback',@triaload_Callback);

fileload_1   = uicontrol(f,'Style','pushbutton',...
            'String','Load Anchor A','Position',[10,550,70,25],...
            'Callback',@fileload_1_Callback,'Enable','off');

fileload_2   = uicontrol(f,'Style','pushbutton',...
            'String','Load Anchor B','Position',[10,520,70,25],...
            'Callback',@fileload_2_Callback,'Enable','off');

getF0track = uicontrol(f,'Style','pushbutton',...
            'String','Get F0 track','Position',[10,200,70,25],...
            'Callback',@getF0track_Callback,'Enable', 'off');

loadStatus_1 = uicontrol(f,'Style','text',...
            'String','Waiting',...
            'Position',[100 550 400 20],'Enable','off','HorizontalAlignment','left');
loadStatus_2 = uicontrol('Style','text',...
            'String','Waiting',...
            'Position',[100 520 400 20],'Enable','off','HorizontalAlignment','left');
        
separator   = uicontrol(f,'Style','pushbutton',...
             'Position',[440,50,10,500],...
             'Enable','off');

text_stepsize = uicontrol(f,'Style','pushbutton',...
            'String','Enter Steps:',...
            'Position',[470 550 70 15],'Enable','off','HorizontalAlignment','left');

enter_stepsize = uicontrol(f,'Style','Edit',...
            'String',num2str(qhd.ndivs),...
            'Position',[550 550 30 15],'Enable','off','HorizontalAlignment','center');

doMorph = uicontrol(f,'Style','pushbutton',...
            'String','Generate Morphs','Position',[600 550 70 15],...
            'Callback',@doMorph_Callback,'Enable','off','HorizontalAlignment','center');

playA = uicontrol(f,'style','pushbutton',...
            'tag','playbut','String','Play A','Position',[360,550,60,15],...
                                   'Callback',@playA_Callback,'Enable','off');
playB = uicontrol(f,'style','pushbutton',...
            'tag','playbut','String','Play B','Position',[360,520,60,15],...
                                   'Callback',@playB_Callback,'Enable','off');
stopSound = uicontrol(f,'style','pushbutton',...
            'tag','playbut','String','Stop Sound','Position',[340,575,100,25],...
                                   'Callback',@stopSound_Callback,'Enable','off');
saveSound = uicontrol(f,'style','pushbutton',...
            'tag','playbut','String','Save Morphs','Position',[700,550,100,15],...
                                   'Callback',@saveSound_Callback,'Enable','off');
        
ha{1} = axes(f,'Units','pixels','Position',[30,410,180,100]);
ha{2} = axes(f,'Units','pixels','Position',[30,270,180,100]);
ha{3} = axes(f,'Units','pixels','Position',[240,410,180,100]);
ha{4} = axes(f,'Units','pixels','Position',[240,270,180,100]);
ha{5} = axes(f,'Units','pixels','Position',[30,50,180,100]);
ha{6} = axes(f,'Units','pixels','Position',[240,50,180,100]);

% make the morphing grid
xloc_1 = 500;
xloc_2 = 800;
yloc_1 = 100;

grid = cell(qhd.ndivs,qhd.ndivs);
stepLoc = (xloc_2-xloc_1)/qhd.ndivs;
alpha = linspace(0,1,qhd.ndivs);

for loop_1 = 1:qhd.ndivs
    for loop_2 = 1:qhd.ndivs
        grid{loop_1,loop_2} = uicontrol('Style','pushbutton',...
            'String',[num2str(alpha(loop_1),'%0.1f') 'A,' num2str(alpha(loop_2),'%2.2f') 'B'] ,...
            'Position',[xloc_1+stepLoc*(loop_1-1) yloc_1+stepLoc*(loop_2-1) 40 40],'Enable','off','HorizontalAlignment','left','Visible','off','Units','pixels');
        grid{loop_1,loop_2}.Units = 'normalized';
    end
end


halogo = axes('Units','pixels','Position',[820,550,50,25]);
align([triaload,enableload],'top','None');
align([fileload_1,fileload_2],'left','None');
align([loadStatus_1,loadStatus_2],'left','None');
align([enter_stepsize,enter_stepsize,doMorph,saveSound],'top','None');

% Initialize the UI.
% Change units to normalized so components resize automatically.
enableload.Units = 'normalized';
triaload.Units = 'normalized';
fileload_1.Units = 'normalized';
fileload_2.Units = 'normalized';
getF0track.Units = 'normalized';
loadStatus_1.Units = 'normalized';
loadStatus_2.Units = 'normalized';
separator.Units = 'normalized';
text_stepsize.Units = 'normalized';
enter_stepsize.Units = 'normalized';
doMorph.Units = 'normalized';
playA.Units = 'normalized';
playB.Units = 'normalized';
stopSound.Units = 'normalized';
saveSound.Units = 'normalized';

for j = 1:6
    ha{j}.Units = 'normalized';
end    
halogo.Units = 'normalized';

% Assign the a name to appear in the window title.
f.Name = 'SPEESM: Speech morphing';
img = imread('tool_kit_logo.png');
% img = rgb2gray(img);
imagesc(halogo,img);
axes(halogo)
axis off

% Move the window to the center of the screen.
movegui(f,'center')

% Make the window visible.
f.Visible = 'on';

% params spectrogram 
hop_frac = 6;
wmsec = 10e-3;
db_down = 60;
wtype = 'hanning';    

% plotting params
FS = 'FontSize';
FSval = 6;
LW = 'LineWidth';
LWval = 0.5;
MS = 'MarkerSize';
MSval = 6;

% global variables
sound_path = '../sound/';
store_path = './data/analy_syn/';
store_path_F0 = './data/f0_tracks/';

fpanel_1 = figure('Visible','off','Position',[360,800,400,400],'MenuBar','None','ToolBar','None');
        

    function enableload_Callback(source,eventdata)
        qhd.trial = 0;
        triaload.Enable = 'on';
        fileload_1.Enable = 'on';
        fileload_2.Enable = 'on';
        enableload.Enable = 'off';
        loadStatus_1.String = ['Waiting'];
        loadStatus_2.String = ['Waiting'];
        
        playOrig.Enable = 'off';
        playSynthesis.Enable = 'off';
        playVoiced.Enable = 'off';
        playUnvoiced.Enable = 'off';
        playA.Enable = 'off';
        playB.Enable = 'off';
        stopSound.Enable = 'off';   
        text_stepsize.Enable = 'off';
        enter_stepsize.Enable = 'off';
        saveSound.Enable = 'off';
    end

    function triaload_Callback(source,eventdata)
        qhd.path = sound_path;
%         qhd.file{1} = 'RMS_cv_bearpear_20_180.wav';
%         qhd.file{2} = 'RMS_hc_bearpear1_20_180.wav';
        qhd.file{1} = 'MTalker_1_word_1.wav';
        qhd.file{2} = 'FTalker_1_word_1.wav';
%         qhd.file{1} = 'words/test_matt_BLADE.wav';
%         qhd.file{2} = 'words/test_audra_BLADE.wav';
        
%         qhd.file{1} = 'words/ashi_initialstress.wav';
%         qhd.file{2} = 'words/asi_initialstress.wav';
        
%         qhd.file{2} = 'MTalker_1_word_2.wav';
        qhd.trial = 1;
        triaload.Enable = 'off';
        enableload.Enable = 'on';
        
        for i = 1:2
            [qhd.sig{i}, qhd.Fs] = audioread(fullfile(qhd.path,qhd.file{i}));
            qhd.sig{i} = resample(qhd.sig{i},16e3,qhd.Fs);
            qhd.Fs = 16e3;
            qhd.taxis{i} = (0:length(qhd.sig{i})-1)/qhd.Fs;
        
            % plot waveform
            plot(ha{i},qhd.taxis{i},qhd.sig{i});
            set(get(ha{i}, 'xlabel'), 'string', 'time [in s]');
            set(get(ha{i}, 'ylabel'), 'string', 'amplitude');
            set(get(ha{i}, 'title'), 'string', 'Original signal');
            set(ha{i},FS,FSval,'box','on');
            axes(ha{i})
            axis tight
            % plot spectrogram
            [xSTFT] = tSTFT(qhd.sig{i},qhd.Fs,wmsec,wtype,hop_frac,0);
            nframes = size(xSTFT,2);
            nfft = size(xSTFT,1);
            wlen = wmsec*qhd.Fs;
            hop  = fix((wlen-1)/hop_frac);
            staxis = (0:nframes-1)*hop/qhd.Fs;
            faxis = 0.001*(1:nfft/2-1)*qhd.Fs/nfft; %% in kHz

            max_mag = max(max(20*log10(abs(xSTFT(fix(faxis*nfft/qhd.Fs/.001)+1,:)))));
            clims = [-db_down 0];
            ylim(ha{i+2},[0 8])
            imagesc(ha{i+2},staxis,faxis,20*log10(abs(xSTFT(fix(faxis*nfft/qhd.Fs/.001)+1,1:length(staxis))))-max_mag,clims);
            set(get(ha{i+2}, 'xlabel'), 'string', 'time [in s]');
            set(get(ha{i+2}, 'ylabel'), 'string', 'frequency [in kHz]');
            set(get(ha{i+2}, 'title'), 'string', 'Spectrogram');
            set(ha{i+2},FS,FSval,'box','on');
            axes(ha{i+2})
            axis xy
            axis tight
            cmap = cbrewer('seq','Blues',100);
            colormap(cmap);
        end
        loadStatus_1.String = ['Loaded audio: ' qhd.file{1}];
        loadStatus_2.String = ['Loaded audio: ' qhd.file{2}];
        loadStatus_1.Enable = 'on';
        loadStatus_2.Enable = 'on';
        enableload.Enable = 'on';
        
        fileload_1.Enable = 'off';
        fileload_2.Enable = 'off';
        getF0track.Enable = 'on';
        playA.Enable = 'on';
        playB.Enable = 'on';
        stopSound.Enable = 'on';
    end

    function fileload_1_Callback(source,eventdata)
        qhd.file{1} = 'a';
        if ~qhd.trial
            [qhd.file{1},qhd.path] = uigetfile('*.wav');
            if isequal(qhd.file{1},0)
            disp('User selected Cancel');
            else
            disp(['User selected ', fullfile(qhd.path,qhd.file{1})]);
            end
        end
        % read audio
        [qhd.sig{1}, qhd.Fs] = audioread(fullfile(qhd.path,qhd.file{1}));
        qhd.sig{1} = resample(qhd.sig{1},16e3,qhd.Fs);
        qhd.Fs = 16e3;
        qhd.taxis{1} = (0:length(qhd.sig{1})-1)/qhd.Fs;
        % plot waveform
        plot(ha{1},qhd.taxis{1},qhd.sig{1});
        set(get(ha{1}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{1}, 'ylabel'), 'string', 'amplitude');
        set(get(ha{1}, 'title'), 'string', 'Original signal');
        set(ha{1},FS,FSval,'box','on');
        axes(ha{1})
        axis tight
        % plot spectrogram
        [xSTFT] = tSTFT(qhd.sig{1},qhd.Fs,wmsec,wtype,hop_frac,0);
        nframes = size(xSTFT,2);
        nfft = size(xSTFT,1);
        wlen = wmsec*qhd.Fs;
        hop  = fix((wlen-1)/hop_frac);
        staxis = (0:nframes-1)*hop/qhd.Fs;
        faxis = 0.001*(1:nfft/2-1)*qhd.Fs/nfft; %% in kHz

        max_mag = max(max(20*log10(abs(xSTFT(fix(faxis*nfft/qhd.Fs/.001)+1,:)))));
        clims = [-db_down 0];
        ylim(ha{3},[0 8])
        imagesc(ha{3},staxis,faxis,20*log10(abs(xSTFT(fix(faxis*nfft/qhd.Fs/.001)+1,1:length(staxis))))-max_mag,clims);
        set(get(ha{3}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{3}, 'ylabel'), 'string', 'frequency [in kHz]');
        set(get(ha{3}, 'title'), 'string', 'Spectrogram');
        set(ha{3},FS,FSval,'box','on');
        axes(ha{3})
        axis xy
        axis tight
        cmap = cbrewer('seq','Blues',100);
        colormap(cmap);
        % enable follow-up buttons
        loadStatus_1.String = ['Loaded audio: ' qhd.file{1}];
        fileload.Enable = 'off';
    end

    function fileload_2_Callback(source,eventdata)
        qhd.file{2} = 'a';
        if ~qhd.trial
            [qhd.file{2},qhd.path] = uigetfile('*.wav');
            if isequal(qhd.file{2},0)
            disp('User selected Cancel');
            else
            disp(['User selected ', fullfile(qhd.path,qhd.file{2})]);
            end
        end
        % read audio
        [qhd.sig{2}, qhd.Fs] = audioread(fullfile(qhd.path,qhd.file{2}));
        qhd.sig{2} = resample(qhd.sig{2},16e3,qhd.Fs);
        qhd.Fs = 16e3;
        qhd.taxis{2} = (0:length(qhd.sig{2})-1)/qhd.Fs;
        % plot waveform
        plot(ha{2},qhd.taxis{2},qhd.sig{2});
        set(get(ha{2}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{2}, 'ylabel'), 'string', 'amplitude');
        set(get(ha{2}, 'title'), 'string', 'Original signal');
        set(ha{2},FS,FSval,'box','on');
        axes(ha{2})
        axis tight
        % plot spectrogram
        [xSTFT] = tSTFT(qhd.sig{2},qhd.Fs,wmsec,wtype,hop_frac,0);
        nframes = size(xSTFT,2);
        nfft = size(xSTFT,1);
        wlen = wmsec*qhd.Fs;
        hop  = fix((wlen-1)/hop_frac);
        staxis = (0:nframes-1)*hop/qhd.Fs;
        faxis = 0.001*(1:nfft/2-1)*qhd.Fs/nfft; %% in kHz

        max_mag = max(max(20*log10(abs(xSTFT(fix(faxis*nfft/qhd.Fs/.001)+1,:)))));
        clims = [-db_down 0];
        ylim(ha{3},[0 8])
        imagesc(ha{4},staxis,faxis,20*log10(abs(xSTFT(fix(faxis*nfft/qhd.Fs/.001)+1,1:length(staxis))))-max_mag,clims);
        set(get(ha{4}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{4}, 'ylabel'), 'string', 'frequency [in kHz]');
        set(get(ha{4}, 'title'), 'string', 'Spectrogram');
        set(ha{4},FS,FSval,'box','on');
        axes(ha{4})
        axis xy
        axis tight
        cmap = cbrewer('seq','Blues',100);
        colormap(cmap);
        % enable follow-up buttons
        loadStatus_2.String = ['Loaded audio: ' qhd.file{2}];
        loadStatus_2.Enable = 'off';
        getF0track.Enable = 'on';
        getF0track.Enable = 'on';
        fileload.Enable = 'off';
    end

        
    function getF0track_Callback(source,eventdata) 
       for i = 1:2
            % call STRAIGHT 
            temp = resample(qhd.sig{i},8e3,qhd.Fs);
            disp('Extracting F0 track ....');
            [f0] = exstraightsource(temp,8e3);
            disp('Extracted F0 track.');
            % equate Fs of qhd.f0 to qhd.Fs
            qhd.f0track{i} = resample(f0,qhd.Fs,8e3);
            qhd.f0track{i}(qhd.f0track{i}<25) = 25;
%             qhd.f0track{i}(qhd.f0track{i}>350) = 350;
            len = length(qhd.f0track{i});
            qhd.taxis{i} = qhd.taxis{i}(1:len);
            qhd.sig{i} = qhd.sig{i}(1:len);
    %         plot f0 track
            plot(ha{i+4},qhd.taxis{i},qhd.f0track{i});
            set(get(ha{i+4}, 'xlabel'), 'string', 'time [in s]');
            set(get(ha{i+4}, 'ylabel'), 'string', 'frequency [in Hz]');
            set(get(ha{i+4}, 'title'), 'string', 'Instantaneous F0 track');
            set(ha{i+4},FS,FSval,'box','on');
            axes(ha{i+4})
            axis tight
            getF0track.Enable = 'off';
       end
       text_stepsize.Enable = 'on';
       enter_stepsize.Enable = 'on';
       doMorph.Enable = 'on';
   end    

    function doMorph_Callback(source,eventdata)
        % get the representation for each
        for i = 1:2
            mu_f0 = mean(qhd.f0track{i}(qhd.f0track{i}>0));
            if mu_f0<150 
                qhd.uBW_am = 1950;
                qhd.uBW_fm = 1950;
                qhd.nu = 0.05;
                qhd.vBW_am = 60;
                qhd.vBW_fm = 60;
                qhd.iq_times = 1;
                qhd.ftimes = 2;
            else
                qhd.uBW_am = 1950;
                qhd.uBW_fm = 1950;
                qhd.nu = 0.1;
                qhd.vBW_am = 100;
                qhd.vBW_fm = 100;
                qhd.iq_times = 1;
                qhd.ftimes = 2;
            end
            % do qhd analysis
            qhd.x = qhd.sig{i}; 
            qhd.filename = qhd.file{i};
            qhd.f0 = qhd.f0track{i};
            qhd.nharm = 14; % custom choice
            mqhd{i} = gui_tvh_analysis(qhd);
            mqhd{i}.f0_track = qhd.f0;
       end
        % do the morphing
        qhd.ndivs = str2double(enter_stepsize.String);
        [qhd.interp_sigs] = gui_tvh_interpolate_v1(mqhd,qhd.ndivs);
        
        % make the grod to play the morphs
        % clear any previous grids
        % f = figure('Visible','off','Position',[360,800,900,600]); %[cx,cy,width,height]
        if ishandle(fpanel_1)
            close(fpanel_1);
        end
        fpanel_1 = figure('Visible','on','Position',[360,800,700,700],'MenuBar','None','ToolBar','None'); %[cx,cy,width,height]        
        xloc_1 = 100;
        xloc_2 = 600;
        yloc_1 = 100;
        
        grid = cell(qhd.ndivs,qhd.ndivs);
        stepLoc = (xloc_2-xloc_1)/qhd.ndivs;
        alpha = linspace(0,1,qhd.ndivs);
        size(qhd.interp_sigs)
        disp(mqhd{1}.Fs)
        size(qhd.interp_sigs{1,1}.sig)
        for m = 1:qhd.ndivs
            for n = 1:qhd.ndivs
                if m ==n
                    grid{m,n} = uicontrol(fpanel_1,'Style','pushbutton',...
                        'String',[num2str(alpha(m),'%0.1f') ',' num2str(alpha(n),'%0.1f')] ,...
                        'Position',[xloc_1+stepLoc*(m-1) yloc_1+stepLoc*(n-1) 60 60],...
                        'Enable','on','HorizontalAlignment','left','Units','pixels',...
                        'callback',{@playMorph_Callback,m,n});
    %                     'Callback',playMorph_Callback(qhd.interp_sigs{m,n}.sig,mqhd{1}.Fs));
                    grid{m,n}.Units = 'normalized';
                end
            end
        end
        textAxis_x   = uicontrol(fpanel_1,'Style','pushbutton',...
            'String','AM','Position',[80,50,300,20],...
            'Enable','off','Units','normalized');
        textAxis_y   = uicontrol(fpanel_1,'Style','pushbutton',...
            'String','FM','Position',[50,100,20,300],...
            'Enable','off','Units','normalized');
        % ----- enable saveSound
        saveSound.Enable = 'on';
    end    

    function makeGrid(source,eventdata)
        val = enter_stepsize.String;
        disp(val)
    end
    function playA_Callback(source,eventdata)
        clear sound; soundsc(qhd.sig{1},qhd.Fs);
    end
    function playB_Callback(source,eventdata) 
        clear sound; soundsc(qhd.sig{2},qhd.Fs);
    end
    function playMorph_Callback(source,eventdata,m,n)
        disp(m)
        disp(n)
        clear sound; soundsc(qhd.interp_sigs{m,n}.sig/max(abs(qhd.interp_sigs{m,n}.sig)),qhd.Fs);
    end
    function stopSound_Callback()
        clear sound;
    end

    function saveSound_Callback(source,eventdata)
        for m = 1:qhd.ndivs
            for n = 1:qhd.ndivs
                audiowrite([store_path mqhd{1}.filename(1:end-4) '_' mqhd{2}.filename(1:end-4) ...
                    '_grid_' num2str(m) '_' num2str(n) '.wav'],qhd.interp_sigs{m,n}.sig/max(abs(qhd.interp_sigs{m,n}.sig)),qhd.Fs);
            end
        end
        clear sound;
    end
end

