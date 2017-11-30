%% Similarity measure
% Somesh Ganesh
% MUSI 7100 Fall 2017

function similarity_value = similarityMeasure(quantized_onsets_in, quantized_onsets_tar, method)

if strcmp(method,'swap')
    
    % Generating offset vectors
    offset_vector_in = find(quantized_onsets_in);
    offset_vector_tar = find(quantized_onsets_tar);
    
    % Calculating distance
    dist = sum(abs(offset_vector_in - offset_vector_tar));
    
end

if strcmp(method,'directed_swap')
   
%     Defining number of sound components, length of each instrument onset vector and distance matrix
    num_instruments = 3;
    instrument_length = size(quantized_onsets_in,1) / num_instruments;
    dist = zeros(num_instruments, 1);
    
%     Iterating over each sound component
    for idx = 1 : num_instruments
       
        onsets_in = quantized_onsets_in((idx-1)*instrument_length + 1 : idx*instrument_length);
        onsets_tar = quantized_onsets_tar((idx-1)*instrument_length + 1 : idx*instrument_length);
        
        offset_vector_in = find(onsets_in);
        offset_vector_tar = find(onsets_tar);
        
%         Finding closest onsets for input and target offsets
        input_to_target = zeros(size(offset_vector_in,1),1);
        target_to_input = zeros(size(offset_vector_tar,1),1);
        
        for input_idx = 1:size(offset_vector_in,1)
           
            diff_with_tar = abs(offset_vector_in(input_idx) - offset_vector_tar);
            [~, loc] = min(diff_with_tar);
            input_to_target(input_idx) = offset_vector_tar(loc);
            
        end
        
%         for target_idx = 1:size(offset_vector_tar,1)
%            
%             diff_with_in = abs(offset_vector_in(input_idx) - offset_vector_tar);
%             
%         end
       
        dist(idx, 1) = sum(abs(offset_vector_in - input_to_target));
        
    end
    
end

similarity_value = dist;

end