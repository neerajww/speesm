
function gui_analyze
close all;
clearvars;

% add path to dependencies
addpath('cbrewer/');
addpath('misc/legacy_STRAIGHT/src'); % download from https://github.com/HidekiKawahara/legacy_STRAIGHT
% addpath('/Users/neeks/Desktop/Documents/work/code/matlab_codes/others_codes/legacy_STRAIGHT/src'); % download from https://github.com/HidekiKawahara/legacy_STRAIGHT

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

doAnalyze = uicontrol(f,'Style','pushbutton','String','Analyze','Position',[470,575,70,15],...
            'Callback',@doAnalyze_Callback,'Enable','off','HorizontalAlignment','center','Units','normalized');

text_sel_NumComps = uicontrol(f,'Style','pushbutton','String','Choose Components (all or few from first 10)',...
            'Position',[550 575 220 15],'Enable','off','HorizontalAlignment','left','Units','normalized');

doRecons = uicontrol(f,'Style','pushbutton','String','Reconstruct','Position',[775,575,70,15],...
            'Callback',@doRecons_Callback,'Enable','off','HorizontalAlignment','center','Units','normalized');

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
                               
cbx = {};
for n = 1:10
    cbx{n} = uicontrol(f,'Style','checkbox','String',num2str(n),'Value', 0,...
                      'Position',[520+30*n 555-15*1 25 15],'Enable','off','Units','normalized');
end
cbx_all = uicontrol(f,'Style','checkbox','String','All','Value', 1,...
                          'Position',[500 555-15*1 25 15],'Enable','off','Units','normalized');
stopSound = uicontrol(f,'style','pushbutton',...
            'tag','playbut','String','Stop Sound','Position',[340,575,100,25],...
                                   'Callback',@stopSound_Callback,'Enable','off','Units','normalized');
        
ha{1} = axes(f,'Units','pixels','Position',[30,490,360,50],'Units','normalized');
ha{2} = axes(f,'Units','pixels','Position',[30,380,360,100],'Units','normalized');
ha{3} = axes(f,'Units','pixels','Position',[30,240,360,80],'Units','normalized');
ha{4} = axes(f,'Units','pixels','Position',[520,320,360,200],'Units','normalized');
ha{5} = axes(f,'Units','pixels','Position',[520,90,360,200],'Units','normalized');
ha{6} = axes(f,'Units','pixels','Position',[30,150,360,50],'Units','normalized');
ha{7} = axes(f,'Units','pixels','Position',[30,30,360,100],'Units','normalized');

halogo = axes('Units','pixels','Position',[820,20,50,25],'Units','normalized');
align([triaload,enableload],'top','None');
align([fileload_1],'left','None');
align([loadStatus_1],'left','None');
align([separator],'left','None');
align([or_text],'left','None');
align([doAnalyze,text_sel_NumComps,doRecons],'top','None');
align([saveSound],'top','None');
align([playA,playB],'top','None');

% Assign the a name to appear in the window title.
f.Name = 'SPEESM: Analysis-Synthesis';
img_logo = imread('tool_kit_logo.png');
imagesc(halogo,img_logo);
axes(halogo)
axis off

% Move the window to the center of the screen.
movegui(f,'center')

% Make the window visible.
f.Visible = 'on';

% initialize the global and local variable
global qhd

% params spectrogram 
hop_frac = 6;
wmsec = 10e-3;
db_down = 60;
wtype = 'hanning';    

% plotting params
FS = 'FontSize';
FSval = 8;
LW = 'LineWidth';
LWval = 0.5;
MS = 'MarkerSize';
MSval = 6;

% global variables
sound_path = '../sound/';
store_path = './data/analy_syn/';
    function enableload_Callback(source,eventdata)
        qhd.trial = 0;
        triaload.Enable = 'on';
        fileload_1.Enable = 'on';
        enableload.Enable = 'off';
        loadStatus_1.String = ['Waiting'];
        playA.Enable = 'off';
        playB.Enable = 'off';
        stopSound.Enable = 'off';   
        saveSound.Enable = 'off';
    end

    function triaload_Callback(source,eventdata)
        qhd.path = sound_path;
        qhd.file = 'MTalker_1_word_1.wav';
        qhd.trial = 1;
        triaload.Enable = 'off';
        enableload.Enable = 'on';
        % read an example file
        [qhd.sig, qhd.Fs] = audioread(fullfile(qhd.path,qhd.file));
        qhd.sig = resample(qhd.sig,16e3,qhd.Fs);
        qhd.Fs = 16e3;
        qhd.taxis = (0:length(qhd.sig)-1)/qhd.Fs;
        
        % plot waveform
        plot(ha{1},qhd.taxis,qhd.sig);
        set(get(ha{1}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{1}, 'ylabel'), 'string', 'amplitude');
%         set(get(ha{1}, 'title'), 'string', 'Original signal');
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
        set(get(ha{2}, 'title'), 'string', 'Spectrogram','FontSize',12);
        set(ha{2},FS,FSval,'box','on');
        axes(ha{2})
        axis xy
        axis tight
        cmap = cbrewer('seq','Blues',100);
        colormap(cmap);
        
        loadStatus_1.String = ['Loaded audio: ' qhd.file];
        loadStatus_1.Enable = 'on';
        enableload.Enable = 'on';
        
        fileload_1.Enable = 'off';
        getF0track.Enable = 'on';
        playA.Enable = 'on';
        playA_text.Enable = 'on';
        stopSound.Enable = 'on';
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
        qhd.sig = resample(qhd.sig,16e3,qhd.Fs);
        qhd.Fs = 16e3;
        qhd.taxis = (0:length(qhd.sig)-1)/qhd.Fs;
        
        % plot waveform
        for i = 1:7
            cla(ha{i});
        end
        plot(ha{1},qhd.taxis,qhd.sig);
        set(get(ha{1}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{1}, 'ylabel'), 'string', 'amplitude');
        set(get(ha{1}, 'title'), 'string', 'Original signal','FontSize',12);
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
        set(get(ha{2}, 'title'), 'string', 'Spectrogram','FontSize',12);
        set(ha{2},FS,FSval,'box','on');
        axes(ha{2})
        axis xy
        axis tight
        cmap = cbrewer('seq','Blues',100);
        colormap(cmap);
        
        % enable follow-up buttons
        loadStatus_1.String = ['Loaded audio: ' qhd.file];
        loadStatus_1.Enable = 'on';
        getF0track.Enable = 'on';
        fileload_1.Enable = 'off';
        loadStatus_1.Enable = 'on';
        enableload.Enable = 'on';

        playA.Enable = 'on';
        playA_text.Enable = 'on';
        stopSound.Enable = 'on';        
    end
        
    function getF0track_Callback(source,eventdata)
        % call STRAIGHT 
        temp = resample(qhd.sig,8e3,qhd.Fs);
        disp('Extracting F0 track ....');
        [f0] = exstraightsource(temp,8e3);
        disp('Extracted F0 track.');
        % equate Fs of qhd.f0 to qhd.Fs
        qhd.f0track = resample(f0,qhd.Fs,8e3);
        qhd.f0track(qhd.f0track<25) = 25;
        %             qhd.f0track{i}(qhd.f0track{i}>350) = 350;
        len = length(qhd.f0track);
        qhd.taxis = qhd.taxis(1:len);
        qhd.sig = qhd.sig(1:len);
        %         plot f0 track
        plot(ha{3},qhd.taxis,qhd.f0track);
        set(get(ha{3}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{3}, 'ylabel'), 'string', 'frequency [in Hz]');
        set(get(ha{3}, 'title'), 'string', 'Instantaneous F0 track','FontSize',12);
        set(ha{3},FS,FSval,'box','on');
        axes(ha{3})
        axis tight
        getF0track.Enable = 'off';
        doAnalyze.Enable = 'on';
        cbx_all.Enable = 'on';
        for i = 1:length(cbx)
            cbx{i}.Enable = 'on';
        end
        
   end    

    function doAnalyze_Callback(source,eventdata)
        % get the representation for each
        mu_f0 = mean(qhd.f0track(qhd.f0track>0));
        if mu_f0<150 
            qhd.uBW_am = 1950;
            qhd.uBW_fm = 1950;
            qhd.nu = 0.05;
            qhd.vBW_am = 80;
            qhd.vBW_fm = 80;
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
            
        % plot AM waveform
        cla(ha{4});
        for i = 1:10%size(qhd.v_am,2)
            plot(ha{4},qhd.taxis,(i-1)+qhd.v_am(:,i)./max(abs(qhd.v_am(:,i))));
            hold(ha{4},'on');
        end
        set(get(ha{4}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{4}, 'ylabel'), 'string', 'Normalized AM components');
        set(get(ha{4}, 'title'), 'string', 'Decomposition','FontSize',12);
        set(ha{4},FS,FSval,'box','on');
        axes(ha{4})
        axis tight
        
        % plot FM waveform
        cla(ha{5});
        for i = 1:10%size(qhd.v_am,2)
            plot(ha{5},qhd.taxis,qhd.v_fm(:,i)/1e3);
            hold(ha{5},'on');
        end
        set(get(ha{5}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{5}, 'ylabel'), 'string', 'FRREQUENCY [in kHz]');
        set(get(ha{5}, 'title'), 'string', 'Original signal','FontSize',12);
        set(ha{5},FS,FSval,'box','on');
        axes(ha{5})
        axis tight     
        % ----- enable recontruct
        doRecons.Enable = 'on';       
       
    end    

    function doRecons_Callback(source,eventdata)
        qhd.sel_comps = [];
        if cbx_all.Value == 1
            qhd.sel_comps = 1:qhd.nharm;
            qhd.file_tag = 'comp_all';
        else
            for i = 1:length(cbx)
                if cbx{i}.Value == 1
                    qhd.sel_comps = [qhd.sel_comps i];
                end
            qhd.file_tag = strrep(num2str(qhd.sel_comps),'  ','_');
            end
        end
 
        qhd = gui_tvh_synthesis(qhd);
        
        % plot AM waveform
        cla(ha{4});
        for i = qhd.sel_comps
            plot(ha{4},qhd.taxis,(i-1)+qhd.v_am(:,i)./max(abs(qhd.v_am(:,i))));
            hold(ha{4},'on');
        end
        set(get(ha{4}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{4}, 'ylabel'), 'string', 'Normalized AM components');
        set(get(ha{4}, 'title'), 'string', 'Estimated AM tracks','FontSize',12);
        set(ha{4},FS,FSval,'box','on');
        axes(ha{4})
        axis tight
        
        % plot FM waveform
        cla(ha{5});
        for i = qhd.sel_comps
            plot(ha{5},qhd.taxis,qhd.v_fm(:,i)/1e3);
            hold(ha{5},'on');
        end
        set(get(ha{5}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{5}, 'ylabel'), 'string', 'FRREQUENCY [in kHz]');
        set(ha{5},FS,FSval,'box','on');
        set(get(ha{5}, 'title'), 'string', 'Estimated FM tracks','FontSize',12);
        axes(ha{5})
        axis tight     
       
        % plot waveform
        plot(ha{6},qhd.taxis,qhd.syn_sig);
        set(get(ha{6}, 'xlabel'), 'string', 'time [in s]');
        set(get(ha{6}, 'ylabel'), 'string', 'amplitude');
%         set(get(ha{6}, 'title'), 'string', 'Original signal');
        set(ha{6},FS,FSval,'box','on');
        axes(ha{6})
        axis off
        axis tight
        
        % plot spectrogram
        [xSTFT] = tSTFT(qhd.syn_sig,qhd.Fs,wmsec,wtype,hop_frac,0);
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
        set(get(ha{7}, 'title'), 'string', 'Spectrogram','FontSize',12);
        set(ha{7},FS,FSval,'box','on');
        axes(ha{7})
        axis xy
        axis tight
        cmap = cbrewer('seq','Blues',100);
        colormap(cmap);
        % ----- enable saveSound
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
        clear sound; soundsc(qhd.syn_sig,qhd.Fs);
    end
    function play_voiced_Callback(source,eventdata)
        clear sound; soundsc(qhd.vsyn_sig,qhd.Fs);
    end
    function play_unvoiced_Callback(source,eventdata)
        clear sound; soundsc(qhd.usyn_sig,qhd.Fs);
    end
    function stopSound_Callback(source,eventdata)
        clear sound;
    end
    function saveSound_Callback(source,eventdata)
        audiowrite([store_path qhd.filename(1:end-4) '_' qhd.file_tag '.wav'],qhd.syn_sig/max(abs(qhd.syn_sig)),qhd.Fs);
    end
end

