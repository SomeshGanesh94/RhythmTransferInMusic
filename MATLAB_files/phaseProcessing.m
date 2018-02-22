function new_phase = phaseProcessing(X, phaseX_in, onsets_new_frames, onsets_old_frames)

new_phase = phaseX_in;

old_onsets = zeros(size(phaseX_in, 2), 1);
new_onsets = zeros(size(phaseX_in, 2), 1);

% Setting 1's for locations in old_onsets and new_onsets
for instr = 1 : size(onsets_old_frames, 1)
    
    for onset_num = 1 : size(onsets_old_frames{instr}, 1)
   
        if ~isempty(onsets_old_frames{instr}{onset_num})
            
            start_idx = onsets_old_frames{instr}{onset_num}(1);
            end_idx = onsets_old_frames{instr}{onset_num}(end);
            old_onsets(start_idx:end_idx) = 1;
            
            start_idx = onsets_new_frames{instr}{onset_num}(1);
            end_idx = onsets_new_frames{instr}{onset_num}(end);
            new_onsets(start_idx:end_idx) = 1;
            
        end
        
    end
    
end

end