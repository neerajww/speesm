

function [interp_sigs] = gui_tvh_interpolate(mqhd,ndivs)
Fs = mqhd{1}.Fs;
Ts = 1/Fs;
len = min(length(mqhd{1}.v_am), length(mqhd{2}.v_am));

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
    for j = 1:ndivs
        v_syn_sig = zeros(size(sub_sigs{1}.v_am,1),1);
        for k = 1:nharm
            interp_sigs{i,j}.v_am(:,k) = alpha(i)*sub_sigs{1}.v_am(:,k) + ...
                                            (1-alpha(i))*sub_sigs{2}.v_am(:,k);
            interp_sigs{i,j}.v_fm(:,k) = alpha(j)*sub_sigs{1}.v_fm(:,k) + ...
                                            (1-alpha(j))*sub_sigs{2}.v_fm(:,k);
            v_syn_sig = v_syn_sig+interp_sigs{i,j}.v_am(:,k).*sin(cumsum(2*pi*interp_sigs{i,j}.v_fm(:,k)*Ts));
        end
        interp_sigs{i,j}.u_am = alpha(i)*sub_sigs{1}.u_am + ...
                                (1-alpha(i))*sub_sigs{2}.u_am;
        interp_sigs{i,j}.u_fm = alpha(j)*sub_sigs{1}.u_fm + ...
                                (1-alpha(j))*sub_sigs{2}.u_fm;

        u_syn_sig = interp_sigs{i,j}.u_am.*sin(cumsum(2*pi*interp_sigs{i,j}.u_fm)*Ts);

        % ----- synthesize complete signal
        interp_sigs{i,j}.sig = v_syn_sig + u_syn_sig; 
    end
end
