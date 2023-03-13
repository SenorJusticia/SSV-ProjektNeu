function SFlabPlayRecData(playBuffer,playChanList,recChanList,fs)

%
% Function that plays the results from a recording session.
%
% SFlabPlayRecData(playBuffer,playChanList,recChanList)
% 
%
% INPUTS:
% playBuffer   -  NxM-matrix with sound data, where M=length(mics) and
%                 N = (sample freq)*(time). Each column contains data from
%                 one of the microphones.
% playChanList -  Vector with index to the recording channels that are to 
%                 be played.
% recChanList  -  Vector with the recording channels that were used to
%                 record.
%
%

% Martin Skoglund and Karl Granström
% 2009-02-27

for k = 1:length(playChanList)
    disp(['Playing recorded channel ' num2str(playChanList(k)) '...'])
    soundsc(double(playBuffer(:,k)),fs);
    disp('Press any key to play next channel')
    pause
end