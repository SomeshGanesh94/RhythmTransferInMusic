function [offset_vector_in, input_to_target] = inputToTargetMap(quantized_onsets_in, quantized_onsets_tar)

num_instruments = size(quantized_onsets_in, 2);

offset_vector_in = cell(num_instruments, 1);
input_to_target = cell(num_instruments, 1);
target_to_input = cell(num_instruments, 1);

% Iterating over each instrument to get their respective mappings
% This loop works on each instrument INDIVIDUALLY
for instr = 1 : num_instruments
    
    % Defning onset vectors and offsets of these vectors
    onsets_in = quantized_onsets_in(:, instr);
    onsets_tar = quantized_onsets_tar(:, instr);
    
    offset_vector_in{instr} = find(onsets_in);
    offset_vector_tar{instr} = find(onsets_tar);
    
    % Finding closest onsets for input and target offsets
    input_to_target{instr} = zeros(size(offset_vector_in{instr}, 1), 1);
    target_to_input{instr} = zeros(size(offset_vector_tar{instr}, 1), 1);
    
    % Looping through every onset in the input instrument activation
    for onset_num = 1 : size(offset_vector_in)
        
        diff_with_tar = abs(offset_vector_in{instr}(onset_num) - offset_vector_tar{instr});
        [~, loc] = min(diff_with_tar);
        input_to_target{instr}(onset_num) = offset_vector_tar{instr}(loc);
        
    end
    
end

end