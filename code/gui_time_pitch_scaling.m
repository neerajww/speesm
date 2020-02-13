
function gui_time_pitch_scaling
close all;
clearvars;

% add path to dependencies
addpath('cbrewer/');
addpath('misc/legacy_STRAIGHT/src'); % download from https://github.com/HidekiKawahara/legacy_STRAIGHT
% addpath('/Users/neeks/Desktop/Documents/work/code/matlab_codes/others_codes/legacy_STRAIGHT/src'); % download from https://github.com/HidekiKawahara/legacy_STRAIGHT

% initialize the global variable
global qhd
qhd.alpha_tsm = 1;
qhd.alpha_psm = 1;

% Initialize the layout and button/axis/text handles etc.
f = figure('Visible','off','Position',[360,800,900,600],'MenuBar','None','ToolBar','None'); %[cx,cy,width,height]

enableload = uicontrol(f,'Style','pushbutton','String','Load File','Position',[10,575,70,25],...
            'Callback',@enableload_Callback,'Units','normalized');

or_text = uicontrol(f,'Style','text','String','or','Position',[75,570,40,25],...
            'Callback',@enableload_Callback,'Units','normalized');
triaload = uicontrol(f,'Style','pushbutton','String','Load Example','Position',[110,575,70,25],...
            'Callback',@triaload_Callback,'Units','normalized');

fileload_1 = uicontrol(f,'Style','pushbutton','String','Select File','Position',[10,550,70,25],...
            'Callback',@fileload_1_Callback,'Units','normalized','Enable','off');

getF0track = uicontrol(f,'Style','pushbutton','String','Get F0 track','Position',[210,575,70,25],...
            'Callback',@getF0track_Callback,'Enable', 'off','Units','normalized');

sel_input_type = uicontrol(f,'Style','popupmenu','Position',[550,350,100,200],...
                'String',{'Use Slider','Enter Number'},'Units','normalized','Enable','off');
        
text_tsm_factor = uicontrol(f,'Style','text','String','Enter time-scaling factor:',...
            'Position',[700 550 120 15],'Enable','off','HorizontalAlignment','left','Units','normalized');
enter_tsm_factor = uicontrol(f,'Style','Edit',...
            'String',num2str(qhd.alpha_tsm),...
            'Position',[775 550 20 15],'Enable','off','HorizontalAlignment','center','Units','normalized');
tsm_slider = uicontrol(f,'Style','Slider',...
            'Position',[550 300 15 200],'Value',1,'Max',2,'Min',.5,'SliderStep',[0.05,.05],...
            'Enable','off','HorizontalAlignment','left','Units','normalized');
        
text_psm_factor = uicontrol(f,'Style','text','String','Enter pitch-scaling factor:',...
            'Position',[700 500 120 15],'Enable','off','HorizontalAlignment','left','Units','normalized');
enter_psm_factor = uicontrol(f,'Style','Edit',...
            'String',num2str(qhd.alpha_psm),...
            'Position',[775 500 20 15],'Enable','off','HorizontalAlignment','center','Units','normalized');
psm_slider = uicontrol(f,'Style','Slider',...
            'Position',[610 300 15 200],'Value',1,'Max',2,'Min',.5,'SliderStep',[0.05,.05],...
            'Enable','off','HorizontalAlignment','left','Units','normalized');

doScale = uicontrol(f,'Style','pushbutton','String','Scale','Position',[775,575,70,15],...
            'Callback',@doScale_Callback,'Enable','off','HorizontalAlignment','center','Units','normalized');

loadStatus_1 = uicontrol(f,'Style','text','String','Empty',...
            'Position',[100 550 400 20],'Enable','off','HorizontalAlignment','left','Units','normalized');
        
separator   = uicontrol(f,'Style','pushbutton','Position',[450,225,5,300],...
             'Enable','off','Units','normalized');

playA = uicontrol(f,'style','pushbutton','tag','playbut','Position',[400,500,15,15],...
                                   'Callback',@playA_Callback,'Enable','off','Units','normalized','CData',imread('spkr_logo.png'));
playA_text = uicontrol(f,'Style','text','String','Original',...
            'Position',[400 480 40 20],'Enable','off','HorizontalAlignment','left','Units','normalized');
            
playB = uicontrol(f,'style','pushbutton','tag','playbut','Position',[400,160,15,15],...
                                   'Callback',@playB_Callback,'Enable','off','Units','normalized','CData',imread('spkr_logo.png'));
playB_text = uicontrol(f,'Style','text','String','Reconstructed',...
            'Position',[400 140 100 20],'Enable','off','HorizontalAlignment','left','Units','normalized');
saveSound = uicontrol(f,'style','pushbutton','tag','playbut','String','Save .WAV',...
            'Position',[400,120,60,15],'Callback',@saveSound_Callback,'Enable','off','Units','normalized');
play_voiced = uicontrol(f,'style','pushbutton','tag','playbut','Position',[500,40,15,15],...
                                   'Callback',@play_voiced_Callback,'Enable','off','Units','normalized','CData',imread('spkr_logo.png'));
play_voiced_text = uicontrol(f,'Style','text','String','Voiced Only',...
            'Position',[500 20 100 20],'Enable','off','HorizontalAlignment','left','Units','normalized');
play_unvoiced = uicontrol(f,'style','pushbutton','tag','playbut','Position',[600,40,15,15],...
                                   'Callback',@play_unvoiced_Callback,'Enable','off','Units','normalized','CData',imread('spkr_logo.png'));
play_unvoiced_text = uicontrol(f,'Style','text','String','Unvoiced Only',...
            'Position',[600 20 100 20],'Enable','off','HorizontalAlignment','left','Units','normalized');
                               
stopSound = uicontrol(f,'style','pushbutton',...
            'tag','playbut','String','Stop Sound','Position',[340,575,100,25],...
                                   'Callback',@stopSound_Callback,'Enable','off','Units','normalized');

ha{1} = axes(f,'Units','pixels','Position',[30,490,360,50],'Units','normalized');
ha{2} = axes(f,'Units','pixels','Position',[30,380,360,100],'Units','normalized');
ha{3} = axes(f,'Units','pixels','Position',[30,240,360,80],'Units','normalized');
ha{4} = axes(f,'Units','pixels','Position',[520,300,20,200],'Units','normalized');
ha{5} = axes(f,'Units','pixels','Position',[640,300,20,200],'Units','normalized');
ha{6} = axes(f,'Units','pixels','Position',[30,150,360,50],'Units','normalized');
ha{7} = axes(f,'Units','pixels','Position',[30,30,360,100],'Units','normalized');

halogo = axes('Units','pixels','Position',[820,20,50,25],'Units','normalized');
align([triaload,enableload],'top','None');
align([fileload_1],'left','None');
align([loadStatus_1],'left','None');
align([separator],'left','None');
align([or_text],'left','None');
align([doScale],'top','None');
align([text_tsm_factor,enter_tsm_factor],'top','None');
align([saveSound],'top','None');
align([playA,playB],'top','None');

% Assign the a name to appear in the window title.
f.Name = 'SPEESM: Time/Pitch-Scaling';
img_logo = imread('tool_kit_logo.png');
imagesc(halogo,img_logo);
axes(halogo)
axis off

% Move the window to the center of the screen.
movegui(f,'center')

% Make the window visible.
f.Visible = 'on';

% initialize params spectrogram 
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

plot(ha{4},0.5*ones(6,1),[.5,.75,1,1.25,1.5,2],'-+','color','k');
set(ha{4},FS,FSval,'box','on');
text(ha{4},-2,0.5,'.5x',FS,10)
text(ha{4},-2,0.75,'.75x',FS,10)
text(ha{4},-2,1,'1x',FS,10)
text(ha{4},-2,1.25,'1.25x',FS,10)
text(ha{4},-2,1.5,'1.5x',FS,10)
text(ha{4},-2,2.0,'2x',FS,10)
axes(ha{4})
axis off
axis tight

plot(ha{5},0.5*ones(6,1),[.5,.75,1,1.25,1.5,2],'-+','color','k');
set(ha{5},FS,FSval,'box','on');
text(ha{5},2,0.5,'.5x',FS,10)
text(ha{5},2,0.75,'.75x',FS,10)
text(ha{5},2,1,'1x',FS,10)
text(ha{5},2,1.25,'1.25x',FS,10)
text(ha{5},2,1.5,'1.5x',FS,10)
text(ha{5},2,2.0,'2x',FS,10)
axes(ha{5})
axis off
axis tight

% global variables
sound_path = '../sound/';
store_path = './data/analy_syn/';
    function enableload_Callback(source,eventdata)
        qhd.trial = 0;
        loadStatus_1.String = ['Waiting'];
        % enable buttons
        triaload.Enable = 'on';
        fileload_1.Enable = 'on';
        enableload.Enable = 'off';
        % disable buttons
        doScale.Enable = 'off';
        sel_input_type.Enable = 'off';
        text_tsm_factor.Enable = 'off';
        enter_tsm_factor.Enable = 'off';
        tsm_slider.Enable = 'off';
        text_psm_factor.Enable = 'off';
        enter_psm_factor.Enable = 'off';
        psm_slider.Enable = 'off';
        playB.Enable = 'off';
        playB_text.Enable = 'off';
        play_voiced.Enable = 'off';
        play_unvoiced.Enable = 'off';
        play_voiced_text.Enable = 'off';
        play_unvoiced_text.Enable = 'off';
        saveSound.Enable = 'off';           
        stopSound.Enable = 'off';   
    end

    function triaload_Callback(source,eventdata)
        qhd.path = sound_path;
        qhd.file = 'MTalker_1_word_1.wav';
        qhd.trial = 1;
        triaload.Enable = 'off';
        enableload.Enable = 'on';
        % read an example file
        [qhd.sig, qhd.Fs] = audioread(fullfile(qhd.path,qhd.file));
        qhd.sig = qhd.sig/max(abs(qhd.sig));
        qhd.sig = resample(qhd.sig,16e3,qhd.Fs);
        qhd.Fs = 16e3;
        qhd.taxis = (0:length(qhd.sig)-1)/qhd.Fs;
        % plot waveform
        plot(ha{1},qhd.taxis,qhd.sig);
        set(get(ha{1}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{1}, 'ylabel'), 'string', 'amplitude');
        set(ha{1},FS,FSval,'box','on');
        axes(ha{1})
        axis off
        axis tight
        % plot spectrogram
        [xSTFT] = tSTFT(qhd.sig,qhd.Fs,wmsec,wtype,hop_frac,0);
        nframes = size(xSTFT,2);
        nfft = size(xSTFT,1);
        wlen = wmsec*qhd.Fs;
        hop  = fix((wlen-1)/hop_frac);
        staxis = (0:nframes-1)*hop/qhd.Fs;
        faxis = 0.001*(1:nfft/2-1)*qhd.Fs/nfft; %% in kHz

        max_mag = max(max(20*log10(abs(xSTFT(fix(faxis*nfft/qhd.Fs/.001)+1,:)))));
        clims = [-db_down 0];
        ylim(ha{2},[0 8])
        imagesc(ha{2},staxis,faxis,20*log10(abs(xSTFT(fix(faxis*nfft/qhd.Fs/.001)+1,1:length(staxis))))-max_mag,clims);
        set(get(ha{2}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{2}, 'ylabel'), 'string', 'frequency [in kHz]');
        set(get(ha{2}, 'title'), 'string', 'Spectrogram');
        set(ha{2},FS,FSval,'box','on');
        axes(ha{2})
        axis xy
        axis tight
        cmap = cbrewer('seq','Blues',100);
        colormap(cmap);
        % enable buttons
        loadStatus_1.String = ['Loaded audio: ' qhd.file];
        loadStatus_1.Enable = 'on';
        enableload.Enable = 'on';
        getF0track.Enable = 'on';
        playA.Enable = 'on';
        playA_text.Enable = 'on';
        stopSound.Enable = 'on';
        % disable buttons
        fileload_1.Enable = 'off';
    end

    function fileload_1_Callback(source,eventdata)
        if ~qhd.trial
            [qhd.file,qhd.path] = uigetfile('*.wav');
            if isequal(qhd.file,0)
            disp('User selected Cancel');
            else
            disp(['User selected ', fullfile(qhd.path,qhd.file)]);
            end
        end
        % load the selected file
        [qhd.sig, qhd.Fs] = audioread(fullfile(qhd.path,qhd.file));
        qhd.sig = qhd.sig/max(abs(qhd.sig));
        qhd.sig = resample(qhd.sig,16e3,qhd.Fs);
        qhd.Fs = 16e3;
        qhd.taxis = (0:length(qhd.sig)-1)/qhd.Fs;
        
        % plot waveform
        plot(ha{1},qhd.taxis,qhd.sig);
        set(get(ha{1}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{1}, 'ylabel'), 'string', 'amplitude');
        set(get(ha{1}, 'title'), 'string', 'Original signal');
        set(ha{1},FS,FSval,'box','on');
        axes(ha{1})
        axis off
        axis tight
        % plot spectrogram
        [xSTFT] = tSTFT(qhd.sig,qhd.Fs,wmsec,wtype,hop_frac,0);
        nframes = size(xSTFT,2);
        nfft = size(xSTFT,1);
        wlen = wmsec*qhd.Fs;
        hop  = fix((wlen-1)/hop_frac);
        staxis = (0:nframes-1)*hop/qhd.Fs;
        faxis = 0.001*(1:nfft/2-1)*qhd.Fs/nfft; %% in kHz

        max_mag = max(max(20*log10(abs(xSTFT(fix(faxis*nfft/qhd.Fs/.001)+1,:)))));
        clims = [-db_down 0];
        ylim(ha{2},[0 8])
        imagesc(ha{2},staxis,faxis,20*log10(abs(xSTFT(fix(faxis*nfft/qhd.Fs/.001)+1,1:length(staxis))))-max_mag,clims);
        set(get(ha{2}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{2}, 'ylabel'), 'string', 'frequency [in kHz]');
        set(get(ha{2}, 'title'), 'string', 'Spectrogram');
        set(ha{2},FS,FSval,'box','on');
        axes(ha{2})
        axis xy
        axis tight
        cmap = cbrewer('seq','Blues',100);
        colormap(cmap);
        loadStatus_1.String = ['Loaded audio: ' qhd.file];
        % enable buttons
        loadStatus_1.Enable = 'on';
        getF0track.Enable = 'on';
        loadStatus_1.Enable = 'on';
        enableload.Enable = 'on';
        playA.Enable = 'on';
        playA_text.Enable = 'on';
        stopSound.Enable = 'on';    
        % disable buttons
        fileload_1.Enable = 'off';
    end
        
    function getF0track_Callback(source,eventdata)
        % call STRAIGHT to get F0 track
        temp = resample(qhd.sig,8e3,qhd.Fs);
        disp('Extracting F0 track ....');
        [f0] = exstraightsource(temp,8e3);
        disp('Extracted F0 track.');
        % equate Fs of qhd.f0 to qhd.Fs
        qhd.f0track = resample(f0,qhd.Fs,8e3);
        qhd.f0track(qhd.f0track<25) = 25;
        len = length(qhd.f0track);
        if len>length(qhd.sig)
            qhd.f0track = qhd.f0track(1:length(qhd.sig));
        else
            qhd.taxis = qhd.taxis(1:len);
            qhd.sig = qhd.sig(1:len);
        end
        % plot f0 track
        plot(ha{3},qhd.taxis,qhd.f0track);
        set(get(ha{3}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{3}, 'ylabel'), 'string', 'frequency [in Hz]');
        set(get(ha{3}, 'title'), 'string', 'Instantaneous F0 track');
        set(ha{3},FS,FSval,'box','on');
        axes(ha{3})
        axis tight
        getF0track.Enable = 'off';
        % do analysis
        mu_f0 = mean(qhd.f0track(qhd.f0track>0));
        if 1%mu_f0<150 
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
        qhd.x = qhd.sig; 
        qhd.filename = qhd.file;
        qhd.f0 = qhd.f0track;
        qhd.nharm = 14; % custom choice
        qhd = gui_tvh_analysis(qhd);
        % enable buttons
        doScale.Enable = 'On';
        sel_input_type.Enable = 'On';
        text_tsm_factor.Enable = 'On';
        enter_tsm_factor.Enable = 'On';
        tsm_slider.Enable = 'On';
        text_psm_factor.Enable = 'On';
        enter_psm_factor.Enable = 'On';
        psm_slider.Enable = 'On';
    end  

    function doScale_Callback(source,eventdata)
        idx = sel_input_type.Value;
        switch(sel_input_type.String{idx})
            case 'Use Slider'
                qhd.alpha_tsm = tsm_slider.Value;
                qhd.alpha_psm = psm_slider.Value;
                qhd.file_tag = 'comp_all';
        end
        qhd = gui_tvh_tsm_psm_synthesis(qhd);
        % plot waveform
        plot(ha{6},qhd.mod_taxis,qhd.mod_syn_sig);
        set(get(ha{6}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{6}, 'ylabel'), 'string', 'amplitude');
        set(ha{6},FS,FSval,'box','on');
        axes(ha{6})
        axis off
        axis tight
        % plot spectrogram
        [xSTFT] = tSTFT(qhd.mod_syn_sig,qhd.Fs,wmsec,wtype,hop_frac,0);
        nframes = size(xSTFT,2);
        nfft = size(xSTFT,1);
        wlen = wmsec*qhd.Fs;
        hop  = fix((wlen-1)/hop_frac);
        staxis = (0:nframes-1)*hop/qhd.Fs;
        faxis = 0.001*(1:nfft/2-1)*qhd.Fs/nfft; %% in kHz

        max_mag = max(max(20*log10(abs(xSTFT(fix(faxis*nfft/qhd.Fs/.001)+1,:)))));
        clims = [-db_down 0];
        ylim(ha{7},[0 8])
        imagesc(ha{7},staxis,faxis,20*log10(abs(xSTFT(fix(faxis*nfft/qhd.Fs/.001)+1,1:length(staxis))))-max_mag,clims);
        set(get(ha{7}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{7}, 'ylabel'), 'string', 'frequency [in kHz]');
        set(get(ha{7}, 'title'), 'string', 'Spectrogram');
        set(ha{7},FS,FSval,'box','on');
        axes(ha{7})
        axis xy
        axis tight
        cmap = cbrewer('seq','Blues',100);
        colormap(cmap);
        % ----- enable buttons
        playB.Enable = 'on';
        playB_text.Enable = 'on';
        play_voiced.Enable = 'on';
        play_unvoiced.Enable = 'on';
        play_voiced_text.Enable = 'on';
        play_unvoiced_text.Enable = 'on';
        saveSound.Enable = 'on';   
    end

    function playA_Callback(source,eventdata)
        clear sound; soundsc(qhd.sig,qhd.Fs);
    end
    function playB_Callback(source,eventdata) 
        clear sound; soundsc(qhd.mod_syn_sig,qhd.Fs);
    end
    function play_voiced_Callback(source,eventdata)
        clear sound; soundsc(qhd.mod_vsyn_sig,qhd.Fs);
    end
    function play_unvoiced_Callback(source,eventdata)
        clear sound; soundsc(qhd.mod_usyn_sig,qhd.Fs);
    end
    function stopSound_Callback(source,eventdata)
        clear sound;
    end
    function saveSound_Callback(source,eventdata)
        audiowrite([store_path qhd.filename(1:end-4) '_' qhd.file_tag '.wav'],...
            qhd.mod_syn_sig/max(abs(qhd.mod_syn_sig)),qhd.Fs);
    end
end

