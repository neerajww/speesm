
function gui_main
close all;

% SIMPLE_GUI2 Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.

%  Create and then hide the UI as it is being constructed.
% f = figure('units','normalized','outerposition',[0 0 1 1]);
f = figure('Visible','off','Position',[360,400,200,200],'MenuBar','None','ToolBar','None'); %[cx,cy,width,height]

% Construct the components.
text_1 = uicontrol(f,'Style','text','String','Speesm: a prism for speech',...
            'Position',[25,150,150,20],'Units','normalized');
prog_1   = uicontrol(f,'Style','pushbutton',...
            'String','Analyze','Position',[25,100,150,50],...
            'Callback',@prog_1_Callback,'units','normalize');

prog_2   = uicontrol(f,'Style','pushbutton',...
            'String','Time/Pitch-Scaling','Position',[25,50,150,50],...
            'Callback',@prog_2_Callback,'units','normalize');

prog_3   = uicontrol(f,'Style','pushbutton',...
            'String','Morphing','Position',[25,0,150,50],...
            'Callback',@prog_3_Callback,'units','normalize');

align([prog_1, prog_2, prog_3],'left','None');
% Assign the a name to appear in the window title.
f.Name = 'SPEESM: a prism for speech?';

% Move the window to the center of the screen.
movegui(f,'center')

store_path = './data/analy_syn/';
store_path_F0 = './data/f0_tracks/';

if ~exist(store_path, 'dir')
   mkdir(store_path)
end
    
if ~exist(store_path_F0, 'dir')
   mkdir(store_path_F0)
end

% Make the window visible.
f.Visible = 'on';
    %%%%%
    function prog_1_Callback(source,eventdata)
        gui_analyze;
    end
    %%%%%
    function prog_2_Callback(source,eventdata)
        gui_time_pitch_scaling;
    end
    %%%%%
    function prog_3_Callback(source,eventdata)
        gui_morphing;
    end
    %%%%%
end

