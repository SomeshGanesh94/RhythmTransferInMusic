%% Quantized onset detection 
% Somesh Ganesh
% MUSI 7100 Fall 2017

function [quantized_onsets] = onsetDetection(total_time, HD, fs, param)
%% Accessing onset detection function from NMF toolbox

addpath('../NmfDrumToolbox-master/src/');

load DefaultSetting.mat

[drumOnsetTime, drumOnsetNum] = OnsetDetection(HD, fs, param.windowSize, ...
    param.hopSize, param.lambda, param.order);

rmpath('../NmfDrumToolbox-master/src/');

%% Quantizing onset detection output to 32 bins

bins = 32;

quantized_onsets = zeros(bins, 3);

onsets1 = transpose(drumOnsetTime(drumOnsetNum == 1));
onsets2 = transpose(drumOnsetTime(drumOnsetNum == 2));
onsets3 = transpose(drumOnsetTime(drumOnsetNum == 3));

for i = 1 : bins
    
    lower_time_bound = (i-1) * total_time / bins;
    upper_time_bound = i * total_time / bins;
    quantized_onsets(i,1) = length(onsets1(onsets1 >= lower_time_bound & onsets1 < upper_time_bound));

    lower_time_bound = (i-1) * total_time / bins;
    upper_time_bound = i * total_time / bins;
    quantized_onsets(i,2) = length(onsets2(onsets2 >= lower_time_bound & onsets2 < upper_time_bound));
    
    lower_time_bound = (i-1) * total_time / bins;
    upper_time_bound = i * total_time / bins;
    quantized_onsets(i,3) = length(onsets3(onsets3 >= lower_time_bound & onsets3 < upper_time_bound));

end