% Read out the EEG data corrupted with artifacts
% 
% INPUT: artifacted .bdf files for the 10 test subjects
% OUTPUT: eeg data as 64xsamples, saved in the EEG_data_normal folder in
% the format eye_blink_<name> or muscle_<name>. The working sample rate Fs 
%(200 Hz) is also stored along with it, as well as the duration.

clear

% Specify the desired working frequency Fs
Fs = 200;

% Specify the location of the file on the PC (make sure it's on the matlab path!)
folder = 'C:\Users\gebruiker\Documents\KULeuven Vakantiewerk Thesispaper 1\EEG Data - Artifacts\';

name = 'olivia'; %alex, anneleen, hanneke, jan-peter, jeroen, jonas, lorenz, otto, steven
% bdf_loc = [folder name '\blink.bdf'];
bdf_loc = [folder name '\clench.bdf'];

% % One subject has no "blink" every 5 seconds, but a "blink continously" measurement
% name = 'olivia';
% bdf_loc = [folder name '\blink_continuously.bdf'];

% Read out the bdf file
eeg_struct  = biopil_raw_data('FileName',bdf_loc, 'MultipleEpochs', 'ignore','Channels','all');

% Extract some relevant figures from the read out data
Fs_original = eeg_struct.FileHeader.SampleRate; % Original sample frequency
duration = eeg_struct.FileHeader.RecordCount;   % Duration of measurement in seconds

% Apply high- and lowpass filtering as preprocessing
eeg_struct = biopil_filter(eeg_struct,'HighPass', 1,'LowPass', [] );

% % NOTCH FILTER IF NEEDED
% % Apply a notch filter on 50 Hz and it's harmonics smaller than Fs
% for i = 50:50:floor(Fs/50)*50
%     wo = i/(Fs_original/2); bw = wo/35; % location and 3dB Bandwidth of notch filter
%     [num,den] = iirnotch(wo,bw);
%     eeg_struct.RawData.EegData = filter(num,den,eeg_struct.RawData.EegData);
% end
% clear num den wo bw i


% Resample the EEG measurement from 8192 Hz to a lower working frequency Fs
% Resample() already applies a LP Anti-Aliasing Filter
eeg_struct.RawData.EegData = resample(double(eeg_struct.RawData.EegData),Fs,Fs_original);

% Put the data in the right format (channels x samples)
eeg_data = (eeg_struct.RawData.EegData(:,1:64)).';

% Remove unwanted wave artifacts in the case of Jeroen
% if (strcmp(name,'jeroen'))
%     eeg_data(:,Fs*53.5:Fs*55.5) = [];
%     eeg_data(:,Fs*33.5:Fs*35.5) = [];
%     eeg_data(:,Fs*11.5:Fs*14) = [];
%     eeg_data(:,Fs*6:Fs*9) = [];
%     duration = duration - 9.52;
% end
% if (strcmp(name,'alex'))
%     eeg_data(:,Fs*86:Fs*88) = [];
%     eeg_data(:,Fs*77.5:Fs*82) = [];
%     eeg_data(:,Fs*63:Fs*65.5) = [];
%     eeg_data(:,Fs*52:Fs*58) = [];
%     duration = duration - 15.02;
% end

% Save the structure and resampled frequency to a mat-file
save(['EEG_data_readout\muscle_' name '.mat'],'eeg_data','Fs','duration');

% Make a plot of the eeg measurements
eegplot(eeg_data,'srate',Fs,'spacing',80,'winlength',10,'dispchans',16)

% Calculation of the spectrum of a channel
channel = eeg_data(3,:);

Ts = 1/Fs;                  % Sample time
L = duration*Fs;            % Length of signal in frames
t = (0:L-1)*Ts;             % Time vector

% Plot the waveform of the considered channel
figure
subplot(2,1,1)
plot(t,channel)         
title('EEG data channel 3')
xlabel('Time (s)')
ylabel('Amplitude')

NFFT = 2^nextpow2(L);               % Next power of 2 from length of the signal
channel_dft = fft(channel,NFFT)/L;  % Fourier transform
f = Fs/2*linspace(0,1,NFFT/2+1);    % Frequency vector

% Plot the spectrum of the considered channel
subplot(2,1,2)
plot(f,2*abs(channel_dft(1:NFFT/2+1))) 
title('Single-Sided Amplitude Spectrum of EEG channel 3')
xlabel('Frequency (Hz)')
ylabel('Amplitude')
