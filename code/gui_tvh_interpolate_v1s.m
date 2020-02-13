


function [interp_sigs] = gui_tvh_interpolate_v1(mqhd,ndivs)
Fs = mqhd{1}.Fs;
Ts = 1/Fs;
% len = min(length(mqhd{1}.v_am), length(mqhd{2}.v_am));

len = max(length(mqhd{1}.v_am), length(mqhd{2}.v_am));
nharm = min(mqhd{1}.nharm, mqhd{2}.nharm);

sub_sigs = cell(2,1);

for i = 1:2
    sub_sigs{i}.v_am = mqhd{i}.v_am(1:len,1:nharm);
    sub_sigs{i}.v_fm = mqhd{i}.v_fm(1:len,1:nharm);
    sub_sigs{i}.u_am = mqhd{i}.u_am(1:len);
    sub_sigs{i}.u_fm = mqhd{i}.u_fm(1:len);
end

% ----- synthesize am and fm voiced
alpha = linspace(0,1,ndivs);
interp_sigs = cell(length(alpha),length(alpha));

for i = 1:ndivs
    len = length(mqhd{1}.sig);
end
