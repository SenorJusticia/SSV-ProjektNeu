clear all
fs = 44100; %Sampling Rate
%% Set up  
% Number of pulses per second that you want to play in speakers
npt = 2;
% time to record in seconds
time = 45;%45;
% number of pulses that will be played
n_pulse = npt*time;
% Time between pulses (s)
tb = 0.5;%n_pulse/time;        
% microphone inputs to use
mics = 1:8;
% speaker outputs to use
speakers = [];
% width of sound pulse
pulseWidth = 0.1; %[0.001 0.005 0.01];
% frequency of pulse
pulseFreq = [1000]; 

%name of recording
rec_name="0_Pos3_"
%% Record
% List of channels that you want to play sound on, ie same as speakers
% above

playChanList = speakers;
% see help SFlabPlayAndRecord o
[recBuffer,recChanList,sampRate,soundData] = SFlabPlayAndRecord(time,...
    n_pulse,mics,speakers,pulseWidth,pulseFreq,fs,tb,rec_name);

%% Plot the recorded data
SFlabPlotRecData(recBuffer,recChanList,...
      playChanList,soundData,sampRate,fs)

%% Find the pulse times
% Set to 0 to turn plots off, 1 otherwise.
plotOn = 1;
% Estimate pulse times, see help SFlabFindPulseTimes

tphat = SFlabFindPulseTimes(recBuffer,recChanList,speakers,...
    sampRate,pulseFreq,pulseWidth,npt,time,plotOn,[]);
<<<<<<< HEAD
name=datestr(now,"yyyy-mm-dd-HH-MM");
name=rec_name+"tphat-"+name
save(name,"tphat");
=======
save("tphat-"+char(datetime),tphat);
>>>>>>> e5ebe59853266088ff46ce3538ce0e4987c59186
%% Listen to the recorded data
SFlabPlayRecData(recBuffer,recChanList,1,fs)

