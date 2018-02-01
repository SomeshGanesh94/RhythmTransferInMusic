%% Processing the input rhythmic activations
% Somesh Ganesh
% MUSI 7100 Fall 2017

function new_HD_in = activationProcessing(HD_in)

% Copy paste sections
new_HD_in = HD_in;
temp = new_HD_in(2,60:100);
temp2 = new_HD_in(2,100:120);

new_HD_in(2,60:80) = temp2;
new_HD_in(2,80:120) = temp;

% Resampling
% temp = resample(HD_in(2,41:60),2,1);
% 
% temp2 = resample(HD_in(2,61:100),1,2);
% 
% new_HD_in = HD_in;
% new_HD_in(2,41:80) = temp;
% new_HD_in(2,81:100) = temp2;

end