


function [interp_sigs] = gui_tvh_interpolate_v1(mqhd,ndivs)
Fs = mqhd{1}.Fs;
Ts = 1/Fs;

nharm = min(mqhd{1}.nharm, mqhd{2}.nharm);

% ----- synthesize am and fm voiced
alpha = linspace(0,1,ndivs);
interp_sigs = cell(length(alpha),length(alpha));

for i = 1:ndivs
    len_new = alpha(i)*length(mqhd{1}.x) + (1-alpha(i))*length(mqhd{2}.x);
    disp(i)
    for j = 1:2
        alpha_tsm = len_new/length(mqhd{j}.x);
        if (alpha_tsm>0 && alpha_tsm~=1)
            Fs = mqhd{j}.Fs;
            Ts = 1/Fs;
            % do tsm and do psm
            taxis_1 = (0:size(mqhd{j}.v_am,1)-1)*(alpha_tsm)*1/Fs;
            taxis_2 = 0:1/Fs:taxis_1(end);

            temp_new_v_am = zeros(length(taxis_2),size(mqhd{j}.v_am,2));
            temp_new_v_fm = temp_new_v_am;

            % stretch the voiced segment

            for k = 1:nharm
                temp_new_v_am(:,k) = interp1(taxis_1(:),mqhd{j}.v_am(:,k),taxis_2(:));
                temp_new_v_fm(:,k) = interp1(taxis_1(:),mqhd{j}.v_fm(:,k),taxis_2(:));
            end

            % stretch the unvoiced segment
            temp_new_u_am = interp1(taxis_1(:),mqhd{j}.u_am,taxis_2(:));
            temp_new_u_fm = interp1(taxis_1(:),mqhd{j}.u_fm,taxis_2(:));

            mqhd{j}.mod_v_am = temp_new_v_am;
            mqhd{j}.mod_v_fm = temp_new_v_fm;

            mqhd{j}.mod_u_am = temp_new_u_am;
            mqhd{j}.mod_u_fm = temp_new_u_fm;

            v_syn_sig = zeros(size(mqhd{j}.mod_v_am,1),1);
            for k = 1:nharm
                v_syn_sig = v_syn_sig+mqhd{j}.mod_v_am(:,k).*sin(cumsum(2*pi*mqhd{j}.mod_v_fm(:,k)*Ts));
            end
            u_syn_sig = mqhd{j}.mod_u_am.*sin(cumsum(2*pi*mqhd{j}.mod_u_fm)*Ts);
            % ----- synthesize complete signal
            mqhd{j}.mod_syn_sig = v_syn_sig + u_syn_sig;
            mqhd{j}.mod_vsyn_sig = v_syn_sig;
            mqhd{j}.mod_usyn_sig = u_syn_sig;
            mqhd{j}.mod_taxis = taxis_2;    
            disp('if')
            size(mqhd{j}.mod_v_am,1)
        else
            mqhd{j}.mod_v_am = mqhd{j}.v_am;
            mqhd{j}.mod_v_fm = mqhd{j}.v_fm;
            mqhd{j}.mod_u_am = mqhd{j}.u_am;
            mqhd{j}.mod_u_fm = mqhd{j}.u_fm;
            disp('else')
            size(mqhd{j}.mod_v_am,1)
        end
    end
    disp('-----')
    size(mqhd{1}.mod_v_am,1)
    size(mqhd{2}.mod_v_am,1)
    disp('-----')
    len = min(length(mqhd{1}.mod_v_am), length(mqhd{2}.mod_v_am));
    sub_sigs = cell(2,1);
    for j = 1:2
        sub_sigs{j}.v_am = mqhd{j}.mod_v_am(1:len,1:nharm);
        sub_sigs{j}.v_fm = mqhd{j}.mod_v_fm(1:len,1:nharm);
        sub_sigs{j}.u_am = mqhd{j}.mod_u_am(1:len);
        sub_sigs{j}.u_fm = mqhd{j}.mod_u_fm(1:len);
    end
    disp('-----')
    size(sub_sigs{1}.v_am,1)
    size(sub_sigs{2}.v_am,1)
    disp('-----')
   
    % interpolate
    v_syn_sig = zeros(size(sub_sigs{1}.v_am,1),1);
    for k = 1:nharm
        interp_sigs{i,i}.v_am(:,k) = alpha(i)*sub_sigs{1}.v_am(:,k) + ...
                                        (1-alpha(i))*sub_sigs{2}.v_am(:,k);
        interp_sigs{i,i}.v_fm(:,k) = alpha(i)*sub_sigs{1}.v_fm(:,k) + ...
                                        (1-alpha(i))*sub_sigs{2}.v_fm(:,k);
        v_syn_sig = v_syn_sig+interp_sigs{i,i}.v_am(:,k).*sin(cumsum(2*pi*interp_sigs{i,i}.v_fm(:,k)*Ts));
    end
    interp_sigs{i,i}.u_am = alpha(i)*sub_sigs{1}.u_am + ...
                            (1-alpha(i))*sub_sigs{2}.u_am;
    interp_sigs{i,i}.u_fm = alpha(i)*sub_sigs{1}.u_fm + ...
                            (1-alpha(i))*sub_sigs{2}.u_fm;

    u_syn_sig = interp_sigs{i,i}.u_am.*sin(cumsum(2*pi*interp_sigs{i,i}.u_fm)*Ts);

    % ----- synthesize complete signal
    interp_sigs{i,i}.sig = v_syn_sig + u_syn_sig; 
end
end
