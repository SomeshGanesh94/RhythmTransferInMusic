function [temp_HD_in, temp_HD_tar] = hardThresholdAndNorm(HD_in, HD_tar, thresh_factor)

temp_HD_in = HD_in;
temp_HD_tar = HD_tar;

num_instr = size(HD_in, 1);

for instr = 1 : num_instr
   
    temp_HD_in(instr, :) = temp_HD_in(instr, :) ./ max(abs(temp_HD_in(instr, :)));
    temp = temp_HD_in(instr, :);
    temp(temp < thresh_factor)=0;
    temp_HD_in(instr, :) = temp;
    
    temp_HD_tar(instr, :) = temp_HD_tar(instr, :) ./ max(abs(temp_HD_tar(instr, :)));
    temp = temp_HD_tar(instr, :);
    temp(temp < thresh_factor)=0;
    temp_HD_tar(instr, :) = temp;
    
end

end
