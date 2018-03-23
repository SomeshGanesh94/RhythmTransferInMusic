%% Processing the input rhythmic activations
% Somesh Ganesh
% MUSI 7100 Fall 2017

function [new_HD_in, onsets_new_frames, onsets_old_frames] = activationProcessing(HD_in, offset_vector_in, input_to_target)

num_instruments = size(HD_in, 1);
quantization_factor = 32;
tolerance = 0;
blocks = 2 * ceil(size(HD_in, 2) / quantization_factor) + tolerance;
new_HD_in = HD_in;
onsets_new_frames = cell(num_instruments, 1);
onsets_old_frames = cell(num_instruments, 1);

for instr = 1 : num_instruments
    
    onsets_old_frames{instr} = cell(size(offset_vector_in{instr}));
    onsets_new_frames{instr} = cell(size(offset_vector_in{instr}));
    
    %     plot(new_HD_in(instr,:));
    % Initializing temporary shift zones for each instrument
    temp_shift_zones = zeros(size(offset_vector_in{instr}, 1), blocks);
    
    % Iterating over every detected onset in the input to store all the
    % zones to be shifted
    for onset_num = 1 : size(offset_vector_in{instr}, 1)
        
%         if instr == 2 && onset_num == 1
%             disp(instr);
%         end
        
        % Checking to see if the onset is not already in the desired
        % location
        if input_to_target{instr}(onset_num) ~= offset_vector_in{instr}(onset_num)
            
            shift_zone_start = floor((offset_vector_in{instr}(onset_num) - 1) * size(HD_in, 2) / quantization_factor);
            %             end_idx = floor(shift_zone_start);
            start_idx = shift_zone_start - floor(blocks / 4);
            end_idx = start_idx + blocks - 1;
            
            % Checking for condition when start_idx is less than 1
            if start_idx < 1
                
                diff = 1 - start_idx;
                start_idx = 1;
                
                temp_shift_zones(onset_num, (start_idx + diff) : end) = HD_in(instr, start_idx : end_idx);
                
            else
                
                temp_shift_zones(onset_num, :) = HD_in(instr, start_idx : end_idx);
                
            end
            
            onsets_old_frames{instr}{onset_num} = [start_idx : end_idx];
            
        end
        
    end
    
    % Adding 0s to locations FROM where the onsets are shifted
    for onset_num = 1 : size(offset_vector_in{instr}, 1)
        
        if input_to_target{instr}(onset_num) ~= offset_vector_in{instr}(onset_num)
            
            shift_zone_start = floor((offset_vector_in{instr}(onset_num) - 1) * size(HD_in, 2) / quantization_factor);
            start_idx = shift_zone_start - floor(blocks / 4);
            end_idx = start_idx + blocks - 1;
            
            if start_idx < 1
                
                start_idx = 1;
                
            end
            
            new_HD_in(instr, start_idx : end_idx) = 0;
            %         plot(new_HD_in(instr,:));
            
        end
        
    end
    
    % Find locations to shift onset to and shift them
    for onset_num = 1 : size(offset_vector_in{instr}, 1)
        
%         if instr == 2 && onset_num == 1
%             disp(instr);
%         end
        
        if input_to_target{instr}(onset_num) ~= offset_vector_in{instr}(onset_num)
            
            final_zone_start = floor((input_to_target{instr}(onset_num) - 1) * size(HD_in, 2) / quantization_factor);
            start_idx = final_zone_start - floor(blocks / 4);
            end_idx = start_idx + blocks - 1;
            
            % Checking for condition when start_idx is less than 1
            if start_idx < 1
                
                diff = 1 - start_idx;
                start_idx = 1;
                
                new_HD_in(instr, start_idx : end_idx) = temp_shift_zones(onset_num, (start_idx + diff) : end);
                
            else
                
                new_HD_in(instr, start_idx : end_idx) = temp_shift_zones(onset_num, :);
                
            end
            
            onsets_new_frames{instr}{onset_num} = [start_idx : start_idx + length(onsets_old_frames{instr}{onset_num}) - 1];
            
        end
        %             plot(new_HD_in(instr,:));
        
    end
    
end

end