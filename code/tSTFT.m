

% code to take STFT
% created on 4 Sept. 2019

function [STFT,len,win,nfft,hop,Xw] = tSTFT(sig,Fs,wmsec,wtype,hop_frac,do_ola_plot)

% ----- window define
wlen = fix(wmsec*Fs);
switch(wtype)
    case 'hanning'
        win = hanning(wlen);
        % ----- induce symmetry
        if mod(wlen,2) % odd
            win = win-min(win);
            win(1) = win(1)/2;
            win(end) = win(end)/2;
        else
            win = hanning(wlen+1);
            win = win(1:wlen);
            win = win-min(win);
        end

    case 'hamming'
        win = hamming(wlen);
        % ----- induce symmetry
        if mod(wlen,2) % odd
            win = win-min(win);
            win(1) = win(1)/2;
            win(end) = win(end)/2;
        else
            win = hamming(wlen+1);
            win = win(1:wlen);
            win = win-min(win);
        end
    case 'rect'
        win = ones(wlen,1);
        % ----- null last sample
        win(end) = 0;
end

win = sqrt(win);

% ----- hop and overlap
hop  = fix((wlen-1)/hop_frac);
ovlp = wlen-hop;

% ----- show OLA plot
if do_ola_plot
    len = 3*wlen;

    z = zeros(1,len)';
    plot(z,'-k'); hold on; s = z;

    for i = 0:hop:len-wlen
       ndx = i+1:i+wlen;
       s(ndx) = s(ndx)+win;
       wzp = z;
       wzp(ndx) = win;
       plot(wzp,'--ok');
    end
    plot(s,'or'); hold off;
    title('COLA illustration')
end

% ----- make frames
len = length(sig);
xpad = [zeros(1,wlen) sig' zeros(1,wlen)]; % pad to
X = buffer(xpad,wlen,ovlp);

nframes = size(X,2);
% ----- window the frames
%hwin = ones(wlen,1); % column vector
hwin = win; % column vector
Hw = repmat(hwin,1,nframes);

Xw = X.*Hw;
%Ww = W.*Hw;

nfft = 2^(nextpow2(wlen)+2);
STFT = fft(Xw,nfft);
%Yw = (ifft(FXw));
%Yw = Yw(1:wlen,:);

%STFT = FXw;
end
