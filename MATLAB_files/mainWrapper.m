%% Wrapper for Rhythm transfer
% Somesh Ganesh
% MUSI 7100 Fall 2017

clc;
clear all;
close all;

%% Input and target audio

fprintf('Reading audio files');

addpath('../Audio_files/inputs/created_loops');
% audio_file_path = 'Audio_files/';

[audio_in, fs_in] = audioread('loop1.wav');
audio_in = mean(audio_in,2);

[audio_target, fs_target] = audioread('loop1.wav');
audio_target = mean(audio_target,2);
rmpath('../Audio_files/inputs/created_loops');

fprintf('...done\n');

%% Downbeat detection

%% Accessing toolbox directory

% NOTE: Input to toolbox function is the file path, not the audio
addpath('../NmfDrumToolbox-master/src/');
 
%% Initialization: Loading param structure and selecting NMF method
load DefaultSetting.mat
% method = 'Nmf';
% method = 'PfNmf';
method = 'Am1';
% method = 'Am2';
% method = 'SaNmf';
% method = 'NmfD';
fprintf('Selected method is %s\n', method);

param.rh = 1;

%% INPUT RHYTHM: Selecting NMF computation based on given method

fprintf('NMF being computed on input file');

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

fprintf('...done\n');

%% TARGET RHYTHM: Selecting NMF computation based on given method

fprintf('NMF being computed on target file');

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

fprintf('...done\n');

%% Onset detection and quantization

fprintf('Performing onset detection to 32 bins on both files');

quantized_onsets_in = onsetDetection(length(audio_in)/fs_in, HD_in, fs_in, param);
quantized_onsets_tar = onsetDetection(length(audio_target)/fs_target, HD_tar, fs_target, param);

% Flattening the onsets for each instrument
feature_vector1 = [quantized_onsets_in(:,1) ; quantized_onsets_in(:,2) ; quantized_onsets_in(:,3)];
feature_vector2 = [quantized_onsets_tar(:,1) ; quantized_onsets_tar(:,2) ; quantized_onsets_tar(:,3)];

fprintf('...done\n');

%% Similarity measure 

fprintf('Applying similarity measure\n');

measure = 'swap';
similarity_value = similarityMeasure(feature_vector1, feature_vector2, measure);
fprintf('Similarity value is %f', similarity_value);

fprintf('...done\n');

%% Process input activation matrix



%% Reconstructing signal

fprintf('Reconstructing signal');

% HD_tar = HD_tar.*0;
% WD_in = WD_in.*0;

% New spectrogram and phase
W_complete = [WD_in WH_in];
H_complete = [HD_in; HH_in];
X_out = W_complete * H_complete;
phaseX_out = phaseX_in;
X_complex = X_out.*exp(1i*phaseX_out);

audio_out = myInverseFFT(X_complex, param.windowSize, param.hopSize);

fprintf('...done\n');

file_outpath = '../Audio_files/outputs/';
filename = 'example.wav';
fs_out = fs_in;
% audiowrite(strcat(file_outpath,filename), audio_out, fs_out);
% soundsc(audio_out, fs_out);

%% Plotting section

% Plot input harmonic templates
% figure;
% plot(WH_in);
% title('Input harmonic templates');

% Plot input drum templates
% figure;
% subplot(311);
% plot(WD_in(:,1));
% title('Input drum templates');
% xlabel('blocks');
% ylabel('HH');
% subplot(312);
% plot(WD_in(:,2));
% xlabel('blocks');
% ylabel('BD');
% subplot(313);
% plot(WD_in(:,3));
% xlabel('blocks');
% ylabel('SD');

% Plot input harmonic activations
figure;
plot(HH_in);
title('Input harmonic activations');

% Plot input drum activations
figure;
subplot(311);
plot(HD_in(1,:));
title('Input drum activations');
xlabel('blocks');
ylabel('HH');
subplot(312);
plot(HD_in(2,:));
xlabel('blocks');
ylabel('BD');
subplot(313);
plot(HD_in(3,:));
xlabel('blocks');
ylabel('SD');


% Plot target harmonic templates
% figure;
% plot(WH_tar);
% title('Target harmonic templates');

% Plot target drum templates
% figure;
% subplot(311);
% plot(WD_tar(:,1));
% title('Target drum templates');
% xlabel('blocks');
% ylabel('HH');
% subplot(312);
% plot(WD_tar(:,2));
% xlabel('blocks');
% ylabel('BD');
% subplot(313);
% plot(WD_tar(:,3));
% xlabel('blocks');
% ylabel('SD');

% Plot target harmonic activations
figure;
plot(HH_tar);
title('Target harmonic activations');

% Plot target drum activations
figure;
subplot(311);
plot(HD_tar(1,:));
title('Target drum activations');
xlabel('blocks');
ylabel('HH');
subplot(312);
plot(HD_tar(2,:));
xlabel('blocks');
ylabel('BD');
subplot(313);
plot(HD_tar(3,:));
xlabel('blocks');
ylabel('SD');


% Plot feature vectors
figure;
subplot(211);
stem(feature_vector1);
title('Feature vectors');
ylabel('Input');
subplot(212);
stem(feature_vector2);
ylabel('Target');

% Input activations with onsets
figure;
subplot(611);
plot(HD_in(1,:)); axis tight;
title('Input drum activations');
xlabel('blocks');
ylabel('HH');
subplot(612);
stem(quantized_onsets_in(:,1)); axis tight;
subplot(613);
plot(HD_in(2,:)); axis tight;
xlabel('blocks');
ylabel('BD');
subplot(614);
stem(quantized_onsets_in(:,2)); axis tight;
subplot(615);
plot(HD_in(3,:)); axis tight;
xlabel('blocks');
ylabel('SD');
subplot(616);
stem(quantized_onsets_in(:,3)); axis tight;

% Target activations with onsets
figure;
subplot(611);
plot(HD_tar(1,:)); axis tight;
title('Target drum activations');
xlabel('blocks');
ylabel('HH');
subplot(612);
stem(quantized_onsets_tar(:,1)); axis tight;
subplot(613);
plot(HD_tar(2,:)); axis tight;
xlabel('blocks');
ylabel('BD');
subplot(614);
stem(quantized_onsets_tar(:,2)); axis tight;
subplot(615);
plot(HD_tar(3,:)); axis tight;
xlabel('blocks');
ylabel('SD');
subplot(616);
stem(quantized_onsets_tar(:,3)); axis tight;