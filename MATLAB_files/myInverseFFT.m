%% Inverse Spectrogram
% objective: transform a spectrogram into time domain signal
% created by Chih-Wei Wu @ GTCMT 2014.07
%
% y = myInverseFFT(X, windowSize, hopSize)
% input:
%       X = a freqNum * frameNum complex spectrogram matrix
%           freqNum = 1/2* windowSize + 1;
%       windowSize = a scalar of the window size used
%       hopSize = a scalar of the hop size used
% output:
%       y = a time domain signal


function [y] = myInverseFFT(X, windowSize, hopSize)

[numFreq, numFrame] = size(X);
maxLength = hopSize * numFrame + windowSize;

%initialization
y = zeros(maxLength, 1);

%mirror the spectrogram
Xflip = conj(flipud(X(1:end-1, :)));
Xall = [X; Xflip(1:end-1, :)];


%resynthesis
for i = 1:numFrame
    
    iStart = (i - 1) * hopSize + 1; 
    iEnd = iStart + windowSize - 1;
    
    %overlap add
    ySegment = ifft(Xall(:,i), windowSize);
    y(iStart: iEnd) = y(iStart: iEnd) + ySegment;
    
end

y = real(y);
