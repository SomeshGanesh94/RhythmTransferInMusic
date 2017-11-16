%% Similarity measure
% Somesh Ganesh
% MUSI 7100 Fall 2017

function similarity_value = similarityMeasure(quantized_onsets_in, quantized_onsets_tar, method)

if method == 'swap'
    
    % Generating offset vectors
    offset_vector_in = find(quantized_onsets_in);
    offset_vector_tar = find(quantized_onsets_tar);
    
    % Calculating distance
    dist = sum(abs(offset_vector_in - offset_vector_tar));
    
end

similarity_value = dist;

end