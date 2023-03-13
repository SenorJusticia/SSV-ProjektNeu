% Define signal parameters
fs = 44100;      % Sampling rate (Hz)
time = 60;        % Duration (s)
pulseWidth = 0.1;        % Pulse width (s)
pulseFreq= 950;         % Pulse frequency (Hz)
tb = 0.5;        % Time between pulses (s)

% Compute pulse train signal
t = linspace(0, time, time*fs);  % Time vector
pw_idx = round(pulseWidth*fs);         % Number of samples for pulse width
tb_idx = round(tb*fs);         % Number of samples for time between pulses
sig = zeros(size(t));          % Initialize signal vector
pulse = sin(2*pi*pulseFreq*t(1:pw_idx)); % Pulse waveform
for i = 1:tb_idx:length(sig)-pw_idx
    sig(i:i+pw_idx-1) = pulse; % Insert pulse
end

% Play sound
soundsc(sig, fs);
