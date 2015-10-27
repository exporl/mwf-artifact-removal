
clear

load('EEG_data_readout\eye_blink_alex.mat')
[eeg_filtered_MWF,SER,ARR] = remove_artifacts(eeg_data,Fs);
SER_all = SER; ARR_all = ARR;

load('EEG_data_readout\eye_blink_anneleen.mat')
[eeg_filtered_MWF,SER,ARR] = remove_artifacts(eeg_data,Fs);
SER_all(end+1,:) = SER; ARR_all(end+1,:) = ARR;

load('EEG_data_readout\eye_blink_hanneke.mat')
[eeg_filtered_MWF,SER,ARR] = remove_artifacts(eeg_data,Fs);
SER_all(end+1,:) = SER; ARR_all(end+1,:) = ARR;

load('EEG_data_readout\eye_blink_jan-peter.mat')
[eeg_filtered_MWF,SER,ARR] = remove_artifacts(eeg_data,Fs);
SER_all(end+1,:) = SER; ARR_all(end+1,:) = ARR;

load('EEG_data_readout\eye_blink_jeroen.mat')
[eeg_filtered_MWF,SER,ARR] = remove_artifacts(eeg_data,Fs);
SER_all(end+1,:) = SER; ARR_all(end+1,:) = ARR;

load('EEG_data_readout\eye_blink_jonas.mat')
[eeg_filtered_MWF,SER,ARR] = remove_artifacts(eeg_data,Fs);
SER_all(end+1,:) = SER; ARR_all(end+1,:) = ARR;

load('EEG_data_readout\eye_blink_lorenz.mat')
[eeg_filtered_MWF,SER,ARR] = remove_artifacts(eeg_data,Fs);
SER_all(end+1,:) = SER; ARR_all(end+1,:) = ARR;

load('EEG_data_readout\eye_blink_otto.mat')
[eeg_filtered_MWF,SER,ARR] = remove_artifacts(eeg_data,Fs);
SER_all(end+1,:) = SER; ARR_all(end+1,:) = ARR;

load('EEG_data_readout\eye_blink_steven.mat')
[eeg_filtered_MWF,SER,ARR] = remove_artifacts(eeg_data,Fs);
SER_all(end+1,:) = SER; ARR_all(end+1,:) = ARR;
