% Utility function: plot signal alongside it's frequency spectrum
%
% Input:    signal - 1D timesignal
%           Fs - samplerate of signal
% Output:   none (plot of funcion is generated)

function plotspectrum(signal, Fs)
% Calculation of the spectrum of a channel

L = length(signal);         % Signal length in sampls
Ts = 1/Fs;                  % Sample time
t = (0:L-1)*Ts;             % Time vector

% Plot the signal
figure
subplot(2,1,1)
plot(t,signal)         
title('Signal')
xlabel('Time [s]')
ylabel('Amplitude')

NFFT = 2^nextpow2(L);               % Next power of 2 from length of the signal
signal_dft = fft(signal,NFFT)/L;  % Fourier transform
f = Fs/2*linspace(0,1,NFFT/2+1);    % Frequency vector

% Plot the spectrum of the considered channel
subplot(2,1,2)
plot(f,2*abs(signal_dft(1:NFFT/2+1))) 
title('Single-Sided Amplitude Spectrum of Signal')
xlabel('Frequency (Hz)')
ylabel('Amplitude')
end