%% Wrapper for NMF drum toolbox
% Somesh Ganesh
% MUSI 7100 Fall 2017

clc;
clear all;
close all;

%% Input and target audio

addpath('../Audio_files/inputs/');
% audio_file_path = 'Audio_files/';

[audio_in, fs_in] = audioread('test_audio.wav');
audio_in = mean(audio_in,2);

[audio_target, fs_target] = audioread('test_audio.wav');
audio_target = mean(audio_target,2);
rmpath('../Audio_files/inputs/');

%% Accessing toolbox directory

% NOTE: Input to toolbox function is the file path, not the audio
addpath('../NmfDrumToolbox-master/src/');
 
%% Initialization: Loading param structure and selecting NMF method
load DefaultSetting.mat
% method = 'Nmf';
method = 'PfNmf';
% method = 'Am1';
% method = 'Am2';
% method = 'SaNmf';
% method = 'NmfD';
fprintf('Selected method is %s\n', method);

%% INPUT RHYTHM: Selecting NMF computation based on given method

% Computing spectrogram
overlap = param.windowSize - param.hopSize;
X = spectrogram(audio_in, param.windowSize, overlap, param.windowSize, fs_in);  
phaseX_in = angle(X);
X = abs(X);

if strcmp(method, 'Nmf')
    param.rh = 0;
    [WD_in, HD_in, WH_in, HH_in, err_in] = PfNmf(X, param.WD, [], [], [], param.rh, param.sparsity);
    
elseif strcmp(method, 'PfNmf')
    [WD_in, HD_in, WH_in, HH_in, err_in] = PfNmf(X, param.WD, [], [], [], param.rh, param.sparsity);
    
elseif strcmp(method, 'Am1')
    [WD_in, HD_in, WH_in, HH_in, itererr_in] = Am1(X, param.WD, param.rh, param.rhoThreshold...
        , param.maxIter, param.sparsity);
    
elseif strcmp(method, 'Am2')
    [WD_in, HD_in, WH_in, HH_in, itererr_in] = Am2(X, param.WD, param.maxIter, param.rh,...
        param.sparsity);
      
elseif strcmp(method, 'SaNmf')
    [B_in, G_in, err_in] = SaNmf(X, param.WD, param.maxIter, 4);      
    
elseif strcmp(method, 'NmfD')
    [P_in, G_in, err_in] = NmfD(X, param.WD, param.maxIter, 10);         

end

%% TARGET RHYTHM: Selecting NMF computation based on given method

% Computing spectrogram
overlap = param.windowSize - param.hopSize;
X = spectrogram(audio_target, param.windowSize, overlap, param.windowSize, fs_target); 
phaseX_tar = angle(X);
X = abs(X);

if strcmp(method, 'Nmf')
    param.rh = 0;
    [WD_tar, HD_tar, WH_tar, HH_tar, err_tar] = PfNmf(X, param.WD, [], [], [], param.rh, param.sparsity);
    
elseif strcmp(method, 'PfNmf')
    [WD_tar, HD_tar, WH_tar, HH_tar, err_tar] = PfNmf(X, param.WD, [], [], [], param.rh, param.sparsity);
    
elseif strcmp(method, 'Am1')
    [WD_tar, HD_tar, WH_tar, HH_tar, itererr_tar] = Am1(X, param.WD, param.rh, param.rhoThreshold...
        , param.maxIter, param.sparsity);
    
elseif strcmp(method, 'Am2')
    [WD_tar, HD_tar, WH_tar, HH_tar, itererr_tar] = Am2(X, param.WD, param.maxIter, param.rh,...
        param.sparsity);
      
elseif strcmp(method, 'SaNmf')
    [B_tar, G_tar, err_tar] = SaNmf(X, param.WD, param.maxIter, 4);      
    
elseif strcmp(method, 'NmfD')
    [P_tar, G_tar, err_tar] = NmfD(X, param.WD, param.maxIter, 10);         

end
rmpath('../NmfDrumToolbox-master/src/');

%% Reconstructing signal

% New spectrogram and phase
W_complete = [WD_in WH_in];
H_complete = [HD_in; HH_in];
X_out = W_complete * H_complete;
phaseX_out = phaseX_in;
X_complex = X_out.*exp(1i*phaseX_out);

audio_out = myInverseFFT(X_complex, param.windowSize, param.hopSize);

file_outpath = '../Audio_files/outputs/';
filename = 'example.wav';
fs_out = fs_in;
audiowrite(strcat(file_outpath,filename), audio_out, fs_out);
% soundsc(audio_out, fs_out);

% [hh, bd, sd] = NmfDrum(strcat(audio_file_path,'test_audio.wav'), 'NmfD');
