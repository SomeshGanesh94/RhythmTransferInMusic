%% Main file for Rhythm transfer
% Somesh Ganesh
% MUSI 7100 Fall 2017

clc;
clear all;
close all;

%% Setting up phase retrieval toolbox

addpath('../ltfat');
addpath('../phaseret');
ltfatstart;
phaseretstart;

%% Input and target audio

% Storing current random generator settings to keep same seed throughout
% the program for NMF computation, etc.
s = rng;

fprintf('Reading audio files');

addpath('../Audio_files/inputs/created_loops');
% audio_file_path = 'Audio_files/';

[audio_in, fs_in] = audioread('mix5.wav');
audio_in = mean(audio_in,2);

[audio_target, fs_target] = audioread('mix6.wav');
audio_target = mean(audio_target,2);
rmpath('../Audio_files/inputs/created_loops');

fprintf('...done\n');

%% Downbeat detection

%% Accessing toolbox directory

% NOTE: Input to toolbox function is the file path, not the audio
addpath('../NmfDrumToolbox-master/src/');
 
%% Initialization: Loading param structure and other parameters and selecting NMF method
load DefaultSetting.mat
% method = 'Nmf';
% method = 'PfNmf';
% method = 'Am1';
method = 'Am2';
% method = 'SaNmf';
% method = 'NmfD';
fprintf('Selected method is %s\n', method);

param.rh = 2;
param.lambda = 0.1;
% param.hopSize = 256;
% param.maxIter = 100;
num_of_instr = 3;
window = 'blackman';

% Hard thresholding factor
thresh_factor = 0.8;

%% INPUT RHYTHM: Selecting NMF computation based on given method

fprintf('NMF being computed on input file');

% Computing spectrogram
overlap = param.windowSize - param.hopSize;
% X_in = spectrogram(audio_in, blackman(param.windowSize), overlap, param.windowSize, fs_in); 
[X_in, len_X] = dgtreal(audio_in, {window, param.windowSize}, param.hopSize, param.windowSize, 'timeinv');
phaseX_in = angle(X_in);
X = abs(X_in);

if strcmp(method, 'Nmf')
    param.rh = 0;
    [WD_in, HD_in, WH_in, HH_in, err_in] = PfNmf(X, param.WD, [], [], [], param.rh, param.sparsity);
    
elseif strcmp(method, 'PfNmf')
    [WD_in, HD_in, WH_in, HH_in, err_in] = PfNmf(X, param.WD, [], [], [], param.rh, param.sparsity, s);
    
elseif strcmp(method, 'Am1')
    [WD_in, HD_in, WH_in, HH_in, itererr_in] = Am1(X, param.WD, param.rh, param.rhoThreshold...
        , param.maxIter, param.sparsity, s);
    
elseif strcmp(method, 'Am2')
    [WD_in, HD_in, WH_in, HH_in, itererr_in] = Am2(X, param.WD, param.maxIter, param.rh,...
        param.sparsity,s);
      
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
% X_tar = spectrogram(audio_target, blackman(param.windowSize), overlap, param.windowSize, fs_target);
% len_X = size(audio_in,1);
[X_tar, len_X] = dgtreal(audio_target, {window, param.windowSize}, param.hopSize, param.windowSize, 'timeinv');
phaseX_tar = angle(X_tar);
X = abs(X_tar);

if strcmp(method, 'Nmf')
    param.rh = 0;
    [WD_tar, HD_tar, WH_tar, HH_tar, err_tar] = PfNmf(X, param.WD, [], [], [], param.rh, param.sparsity);
    
elseif strcmp(method, 'PfNmf')
    [WD_tar, HD_tar, WH_tar, HH_tar, err_tar] = PfNmf(X, param.WD, [], [], [], param.rh, param.sparsity, s);
    
elseif strcmp(method, 'Am1')
    [WD_tar, HD_tar, WH_tar, HH_tar, itererr_tar] = Am1(X, param.WD, param.rh, param.rhoThreshold...
        , param.maxIter, param.sparsity, s);
    
elseif strcmp(method, 'Am2')
    [WD_tar, HD_tar, WH_tar, HH_tar, itererr_tar] = Am2(X, param.WD, param.maxIter, param.rh,...
        param.sparsity,s);
      
elseif strcmp(method, 'SaNmf')
    [B_tar, G_tar, err_tar] = SaNmf(X, param.WD, param.maxIter, 4);      
    
elseif strcmp(method, 'NmfD')
    [P_tar, G_tar, err_tar] = NmfD(X, param.WD, param.maxIter, 10);         

end
rmpath('../NmfDrumToolbox-master/src/');

fprintf('...done\n');


%% Hard thresholding and normalization for a more robust onset detection

fprintf('Performing hard thresholding and normalizing with threshold factor %f', thresh_factor);
% [temp_HD_in, temp_HD_tar] = hardThresholdAndNorm(HD_in, HD_tar, thresh_factor);
temp_HD_in = HD_in;
temp_HD_tar = HD_tar;
fprintf('...done\n');

%% Onset detection and quantization

fprintf('Performing onset detection to 32 bins on both files');
quantized_onsets_in = onsetDetection(length(audio_in)/fs_in, temp_HD_in, fs_in, param);
quantized_onsets_tar = onsetDetection(length(audio_target)/fs_target, temp_HD_tar, fs_target, param);



fprintf('...done\n');

%% Similarity measure

% fprintf('Applying similarity measure\n');
% 
% % measure = 'swap';
% measure = 'directed_swap';
% similarity_value = similarityMeasure(quantized_onsets_in, quantized_onsets_tar, measure);
% fprintf('Similarity value is %f', similarity_value);
% 
% fprintf('...done\n');

%% Produce mappings for input activation to target activation

[offset_vector_in, input_to_target] = inputToTargetMap(quantized_onsets_in, quantized_onsets_tar);


%% Process input activation matrix

[new_HD_in, onsets_new_frames, onsets_old_frames] = activationProcessing(HD_in, offset_vector_in, input_to_target);
% new_HD_in = HD_in;

%% Reconstructing signal

fprintf('Reconstructing signal');

% HD_tar = HD_tar.*0;
% WD_in = WD_in.*0;
% HD_in([1,3],:) = 0;
% HD_in([2,3],:) = 0;
% HD_in([1,2],:) = 0;
% HH_in(:,:) = 0;

% New spectrogram and phase
W_complete = [WD_in WH_in];
H_complete = [new_HD_in(:, 1 : size(HD_in,2)); HH_in];
X_out = W_complete * H_complete;

%

% L=dgtlength(Ls,a,M);
% reX = gla(X_out, {'blackman', param.windowSize}, param.hopSize, param.windowSize, 'timeinv', 'Ls', 81920);
% 
% audio_out = idgtreal(reX, {'blackman', param.windowSize}, param.hopSize, param.windowSize, 'timeinv');



%% Process phase
regionsAndIdx = findOnsetRegions(abs(X_in), X_out, phaseX_in, onsets_new_frames, onsets_old_frames, param);

% X_complex = phaseProcessing(X_out, phaseX_in, param, regionsAndIdx, onsets_new_frames, onsets_old_frames, HD_in, WD_in);
% 
% audio_out_plain = idgtreal(X_complex, {'dual', {window, param.windowSize}}, param.hopSize, param.windowSize, len_X, 'timeinv');

X_complex = phaseProcessingNewBin(X_out, phaseX_in, param, regionsAndIdx, onsets_new_frames, onsets_old_frames, HD_in, WD_in);

%% 

% phaseX_out = pghi(X_out, param.windowSize, param.hopSize, param.windowSize);
audio_out_bin = idgtreal(X_complex, {'dual', {window, param.windowSize}}, param.hopSize, param.windowSize, len_X, 'timeinv');
 
X_complex = phaseProcessingNewFrame(X_out, phaseX_in, param, regionsAndIdx, onsets_new_frames, onsets_old_frames, HD_in, WD_in);

audio_out_frame = idgtreal(X_complex, {'dual', {window, param.windowSize}}, param.hopSize, param.windowSize, len_X, 'timeinv');

phaseX_out = phaseX_in;

X_complex = X_out.*exp(1i*phaseX_out);

audio_out = istft(X_complex, param.windowSize, param.windowSize, param.hopSize);

% audio_out = idgtreal(X_complex, {'dual', {window, param.windowSize}}, param.hopSize, param.windowSize, len_X, 'timeinv');

% audio_out = myInverseFFT(X_complex, param.windowSize, param.hopSize);
% audio_out = ygab;
fprintf('...done\n');

file_outpath = '../Audio_files/outputs/';
filename = strcat(window,'example.wav');
fs_out = fs_in;
audio_out = audio_out ./ max(abs(audio_out));
% audiowrite(strcat(file_outpath,filename), audio_out, fs_out);
% soundsc(audio_out, fs_out);

%% Plotting section

% All audio
t = 0:1/fs_out:(length(audio_out)-1)/fs_out;
t1 = 0:1/fs_out:(length(audio_in)-1)/fs_out;
figure('Name','Time domain'); subplot(311); plot(t1,audio_in); title('Input audio'); xlabel('Time (seconds)'); ylabel('Amplitude');  axis tight; subplot(312); plot(t1,audio_target); title('Target audio'); xlabel('Time (seconds)'); ylabel('Amplitude');  axis tight; subplot(313); plot(t,audio_out); title('Modified audio'); xlabel('Time (seconds)'); ylabel('Amplitude');  axis tight;

figure('Name', 'Spectrogram target');
spectrogram(audio_target, blackman(param.windowSize), overlap, param.windowSize, fs_out, 'yaxis'); 
ax = caxis;

figure('Name', 'Spectrogram binwise');
spectrogram(audio_out_bin, blackman(param.windowSize), overlap, param.windowSize, fs_out, 'yaxis'); 
caxis(ax);

% figure('Name', 'Spectrogram muted');
% spectrogram(audio_out_plain, blackman(param.windowSize), overlap, param.windowSize, fs_out, 'yaxis'); 
% caxis(ax);

figure('Name', 'Spectrogram framewise');
spectrogram(audio_out_frame, blackman(param.windowSize), overlap, param.windowSize, fs_out, 'yaxis'); 
caxis(ax);

figure('Name', 'Spectrogram inPhase');
spectrogram(audio_out, hann(param.windowSize), overlap, param.windowSize, fs_out, 'yaxis'); 
caxis(ax);

% Activations
% i = 1; figure('Name','Hi-hat'); subplot(311); plot((HD_in(i,:))./max(abs(HD_in(i,:)))); title('Input activation'); xlabel('Frames'); ylabel('Normalized magnitude'); subplot(312); plot(HD_tar(i,:));xlabel('Frames'); ylabel('Normalized magnitude'); title('Target activation'); subplot(313); plot(new_HD_in(i,:)./max(abs(new_HD_in(i,:)))); title('Processed  activation');xlabel('Frames'); ylabel('Normalized magnitude');
% i = 2; figure('Name','Bass drum'); subplot(311); plot((HD_in(i,:))./max(abs(HD_in(i,:)))); title('Input activation'); xlabel('Frames'); ylabel('Normalized magnitude'); subplot(312); plot(HD_tar(i,:));xlabel('Frames'); ylabel('Normalized magnitude'); title('Target activation'); subplot(313); plot(new_HD_in(i,:)./max(abs(new_HD_in(i,:)))); title('Processed  activation');xlabel('Frames'); ylabel('Normalized magnitude');
% i = 3; figure('Name','Snare drum'); subplot(311); plot((HD_in(i,:))./max(abs(HD_in(i,:)))); title('Input activation'); xlabel('Frames'); ylabel('Normalized magnitude'); subplot(312); plot(HD_tar(i,:));xlabel('Frames'); ylabel('Normalized magnitude'); title('Target activation'); subplot(313); plot(new_HD_in(i,:)./max(abs(new_HD_in(i,:)))); title('Processed  activation');xlabel('Frames'); ylabel('Normalized magnitude');

% plotdgtrealphasediff(real(phaseX_in),real(phaseX_tar),X_tar,0.9,param.hopSize,param.windowSize);

% % Plot input harmonic templates
% % figure;
% % plot(WH_in);
% % title('Input harmonic templates');
% 
% % Plot input drum templates
% % figure;
% % subplot(311);
% % plot(WD_in(:,1));
% % title('Input drum templates');
% % xlabel('blocks');
% % ylabel('HH');
% % subplot(312);
% % plot(WD_in(:,2));
% % xlabel('blocks');
% % ylabel('BD');
% % subplot(313);
% % plot(WD_in(:,3));
% % xlabel('blocks');
% % ylabel('SD');
% 
% % Plot input harmonic activations
% figure;
% plot(HH_in);
% title('Input harmonic activations');
% 
% % Plot input drum activations
% figure;
% subplot(311);
% plot(HD_in(1,:));
% title('Input drum activations');
% xlabel('blocks');
% ylabel('HH');
% subplot(312);
% plot(HD_in(2,:));
% xlabel('blocks');
% ylabel('BD');
% subplot(313);
% plot(HD_in(3,:));
% xlabel('blocks');
% ylabel('SD');
% 
% 
% % Plot target harmonic templates
% % figure;
% % plot(WH_tar);
% % title('Target harmonic templates');
% 
% % Plot target drum templates
% % figure;
% % subplot(311);
% % plot(WD_tar(:,1));
% % title('Target drum templates');
% % xlabel('blocks');
% % ylabel('HH');
% % subplot(312);
% % plot(WD_tar(:,2));
% % xlabel('blocks');
% % ylabel('BD');
% % subplot(313);
% % plot(WD_tar(:,3));
% % xlabel('blocks');
% % ylabel('SD');
% 
% % Plot target harmonic activations
% figure;
% plot(HH_tar);
% title('Target harmonic activations');
% 
% % Plot target drum activations
% figure;
% subplot(311);
% plot(HD_tar(1,:));
% title('Target drum activations');
% xlabel('blocks');
% ylabel('HH');
% subplot(312);
% plot(HD_tar(2,:));
% xlabel('blocks');
% ylabel('BD');
% subplot(313);
% plot(HD_tar(3,:));
% xlabel('blocks');
% ylabel('SD');
% 
% 
% % Plot feature vectors
% figure;
% subplot(211);
% stem(feature_vector1);
% title('Feature vectors');
% ylabel('Input');
% subplot(212);
% stem(feature_vector2);
% ylabel('Target');
% 
% % Input activations with onsets
% figure;
% subplot(611);
% plot(HD_in(1,:)); axis tight;
% title('Input drum activations');
% xlabel('blocks');
% ylabel('HH');
% subplot(612);
% stem(quantized_onsets_in(:,1)); axis tight;
% subplot(613);
% plot(HD_in(2,:)); axis tight;
% xlabel('blocks');
% ylabel('BD');
% subplot(614);
% stem(quantized_onsets_in(:,2)); axis tight;
% subplot(615);
% plot(HD_in(3,:)); axis tight;
% xlabel('blocks');
% ylabel('SD');
% subplot(616);
% stem(quantized_onsets_in(:,3)); axis tight;
% % 
% % % Target activations with onsets
% figure;
% subplot(611);
% plot(HD_tar(1,:)); axis tight;
% title('Target drum activations');
% xlabel('blocks');
% ylabel('HH');
% subplot(612);
% stem(quantized_onsets_tar(:,1)); axis tight;
% subplot(613);
% plot(HD_tar(2,:)); axis tight;
% xlabel('blocks');
% ylabel('BD');
% subplot(614);
% stem(quantized_onsets_tar(:,2)); axis tight;
% subplot(615);
% plot(HD_tar(3,:)); axis tight;
% xlabel('blocks');
% ylabel('SD');
% subplot(616);
% stem(quantized_onsets_tar(:,3)); axis tight;