function [recBuffer,recChanList,sampRate,soundData] = ...
    SFlabPlayAndRecord(time,n_pulse,mics,speakers,pulseWidth,pulseFreq,fs,tb,rec_name)
% Function that plays a sound and records at the same time.
%
% function [recBuffer,recChanList,noiseBuffer,sampRate,soundData] = ...
%     SFlabPlayAndRecord(time,n_pulse,mics,speakers,pulseWidth,pulseFreq)
%
% INPUTS:
% time        -  Length in seconds of the recording.
% n_pulse     -  Number of pulses.
% mics        -  Vector that specifies which microphones to use,
%                e.g. mics=[1:8] means microphones 1 to 8 are used.
% speakers    -  Vector that specifies which speakers to use,
%                e.g. speakers=[1:8] means speakers 1 to 8 are used.
% pulseWidth  -  Width of the pulses.
% pulseFreq   -  Pulse frequency.
%
% OUTPUTS:
% recBuffer   -  NxM-matrix with sound data, where M=length(mics) and
%                N = (sample freq)*(time). Each column contains data from
%                one of the microphones.
% recChanList -  Vector with the recording channels that were used.
% sampRate    -  Sampling frequency.
% soundData   -  Sound sequence that was played.
%
%

% Martin Skoglund and Karl Granstr�m
% 2009-02-24
%
% Updated by Anton Kullberg
% 2020-01-20
% Notes: Added functionality for the MATLAB Audio Toolbox. 
% Now primarily uses the Audio Toolbox with playrec as fallback if the
% audio toolbox does not exist.

useAudioToolbox = ~isempty(ver('audio'));
deviceName = 'Default';%'UMC ASIO Driver';

if ~useAudioToolbox
    disp('Using playrec');
    %  Get information on all available devices
    dL = playrec('getDevices');
    % Get correct device ID
    % name should be "Saffire PRO ASIO Driver"
    nameList = {dL.name};
    devID = [];

    for i = 1:length(nameList)
        %if strcmp(nameList{i}, 'Saffire Pro26 1394 ASIO x64')
        if strcmp(nameList{i}, deviceName)
       % if strcmp(nameList{i}, 'Saffire PRO ASIO Driver')
            devID = dL(i).deviceID; % Get device ID
            sampRate = dL(i).defaultSampleRate; % Get sample rate
        end
    end

    if isempty(devID)
        disp('No device found - aborting')
        return
    end

    % initialise playrec functions
    % sample rate, play device id, rec device id, max play ch, max rec ch
    if ~playrec('isInitialised')
        playrec('init',sampRate,devID,devID,1,8);
    end
else
    disp('Using MATLAB Audio Toolbox');
    sampRate = 44100;
    if ispc
       audioReader = audioDeviceReader('Driver', 'ASIO');
    elseif isunix
        audioReader = audioDeviceReader;
        devices = getAudioDevices(audioReader);
        ind = cellfun(@(x) contains(x,'UMC1820'), devices);
        if sum(ind) ~= 1
            disp('UMC1820 device not found, try again')
            return
        end
        deviceName = devices{ind};
        
    end
    audioReader.SamplesPerFrame = 512;
    audioReader.SampleRate = sampRate;
    audioReader.Device = deviceName;
    audioReader.NumChannels = 8;
    setup(audioReader);
    t = datetime;
    t_name= rec_name + char(t);
    filename = replace(['Recording_' char(t_name) '.wav'],':','.');
    audioWriter = dsp.AudioFileWriter(filename,'FileFormat','WAV');
end

disp('Press any key to start recording.')
pause
disp('Recording...')

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

if ~useAudioToolbox
    if ~isempty(speakers)
        % create sound data
        disp('...generating sound.')
        soundData = generateSoundData(time,n_pulse,pulseWidth,pulseFreq,sampRate);
        disp('...sound generated.')
        % play the sound and record from microphones
        % input: sound to be played, channels to play at, number of samples to
        % record, channels to record at.
        [pageNumber] = playrec('playrec',soundData,speakers,sampRate*time,mics);
    else
        soundData = 0;
        % record from microphones
        % input: number of samples to record, channels to record at.
        [pageNumber] = playrec('rec',sampRate*time,mics);
    end

    % wait for playrec to finish recording
    while(playrec('isFinished',pageNumber) == 0); end
    disp('...play and record session finished.')

    % get recorded data

    [recBuffer, recChanList] = playrec('getRec',pageNumber);
    recBuffer = double(recBuffer);
else
    dropped = 0;
    tic;
    while toc < time
        [data, frameDrop] = audioReader();
        dropped = dropped+frameDrop;
        audioWriter(data);
    end
    disp('...play and record session finished.')
    [recBuffer, sampRate] = audioread(filename);
    recChanList = mics;
    release(audioReader);
    release(audioWriter);
    soundData = 0;
end

