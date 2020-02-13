

function [qhd] = gui_tvh_tsm_psm_synthesis(qhd)
    Fs = qhd.Fs;
    Ts = 1/Fs;

    % do tsm and do psm
    taxis_1 = (0:size(qhd.v_am,1)-1)*(1/qhd.alpha_tsm)*1/Fs;
    taxis_2 = 0:1/Fs:taxis_1(end);

    temp_new_v_am = zeros(length(taxis_2),size(qhd.v_am,2));
    temp_new_v_fm = temp_new_v_am;

    % stretch the voiced segment
    qhd.mod_nharm = qhd.nharm;
    if qhd.alpha_psm>1
        qhd.mod_nharm = fix(7e3/median(qhd.alpha_psm*(qhd.v_fm(find(qhd.v_fm(:,1)>0),1))));
    end

    for i = 1:qhd.mod_nharm
        temp_new_v_am(:,i) = interp1(taxis_1(:),qhd.v_am(:,i),taxis_2(:));
        temp_new_v_fm(:,i) = qhd.alpha_psm*interp1(taxis_1(:),qhd.v_fm(:,i),taxis_2(:));
    end

    % stretch the unvoiced segment
    temp_new_u_am = interp1(taxis_1(:),qhd.u_am,taxis_2(:));
    temp_new_u_fm = interp1(taxis_1(:),qhd.u_fm,taxis_2(:));

    qhd.mod_v_am = temp_new_v_am;
    qhd.mod_v_fm = temp_new_v_fm;

    qhd.mod_u_am = temp_new_u_am;
    qhd.mod_u_fm = temp_new_u_fm;

    v_syn_sig = zeros(size(qhd.mod_v_am,1),1);
    for k = 1:qhd.mod_nharm
        v_syn_sig = v_syn_sig+qhd.mod_v_am(:,k).*sin(cumsum(2*pi*qhd.mod_v_fm(:,k)*Ts));
    end
    u_syn_sig = qhd.mod_u_am.*sin(cumsum(2*pi*qhd.mod_u_fm)*Ts);
    % ----- synthesize complete signal
    qhd.mod_syn_sig = v_syn_sig + u_syn_sig;
    qhd.mod_vsyn_sig = v_syn_sig;
    qhd.mod_usyn_sig = u_syn_sig;
    qhd.mod_taxis = taxis_2;
end