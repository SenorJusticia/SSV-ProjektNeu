function SFlabPlotRecData(recBuffer,recChanList,...
    playChanList,soundData,sampRate,fs)
%
% Function that plots the results from a recording session.
%
% function SFlabPlotRecData(recBuffer,recChanList,noiseBuffer,...
%     playChanList,soundData,sampRate)
% 
%
% INPUTS:
% recBuffer    -  NxM-matrix with sound data, where M=length(mics) and
%                 N = (sample freq)*(time). Each column contains data from
%                 one of the microphones.
% recChanList  -  Vector with the recording channels that were used.
% playChanList -  Vector with the output channels that were used.
% soundData    -  Sound sequence that was played.
% sampRate     -  Sampling frequency.
%
%

% Martin Skoglund and Karl Granström
% 2009-02-24

% Number of samples and number of microphones used
[n_samp,n_mics] = size(recBuffer);

% Number of sound sequences
[tmp,n_sounds] = size(soundData);

% define a time vector
t = (0:n_samp-1)/sampRate;

% Plots for outputs, normalised for SNR
figure
if n_mics>1
    for i = 1:n_mics
        subplot(ceil(n_mics/2),2,i)
        y = recBuffer(:,i);
        plot(t,y/max(abs(y)))
        title(['Recording from channel ' num2str(recChanList(i))])
        xlabel('Time [s]')
        ylabel('Signal y(t)/max_t(y(t))')
    end
else
    y = recBuffer;
    plot(t,y/max(abs(y)))
    title(['Recording from channel ' num2str(recChanList)])
    xlabel('Time [s]')
    ylabel('Signal y(t)/max_t(y(t))')
end

if ~isempty(playChanList)
    % Plots for inputs
    figure
    if n_sounds>1
        for j = 1:n_sounds
            subplot(ceil(n_sounds/2),2,i)
            plot(t,soundData)
            title(['Sound sequence ' num2str(playChanList(j))])
            xlabel('Time [s]')
        end
    else
        plot(t,soundData)
        title(['Sound sequence ' num2str(playChanList)])
        xlabel('Time [s]')
    end
end