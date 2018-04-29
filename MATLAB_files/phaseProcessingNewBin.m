function X_complex = phaseProcessingNewBin(X, phaseX_in, param, regionsAndIdx, onsets_new_frames, onsets_old_frames, HD_in, HH_in, WD_in, WH_in)

X_complex = zeros(size(phaseX_in));

old_region_cell = regionsAndIdx{1,1};
old_region_idx_cell = regionsAndIdx{1,2};

new_region_cell = regionsAndIdx{2,1};
new_regions_idx_cell = regionsAndIdx{2,2};

same_region_cell = regionsAndIdx{3,1};
same_region_idx_cell = regionsAndIdx{3,2};

%% Phase reconstruction at locations of no change
same_rephase = cell(size(same_region_cell));

for region = 1 : size(same_rephase,1)
    
    start_idx = same_region_idx_cell{region}(1);
    end_idx = same_region_idx_cell{region}(2);
    same_rephase{region} = X(:, start_idx:end_idx).*(exp(1i*phaseX_in(:, start_idx:end_idx)));
    X_complex(:, start_idx:end_idx) = same_rephase{region};
%     X_complex(:, start_idx:end_idx) = 0;
    
end

%% Phase reconstruction for old regions using toolbox
old_rephase = cell(size(old_region_cell));

for region = 1 : size(old_rephase,1)
    
    old_rephase{region} = pghi(old_region_cell{region}, param.windowSize, param.hopSize, param.windowSize, 'timeinv');
    start_idx = old_region_idx_cell{region}(1);
    end_idx = old_region_idx_cell{region}(2);
    X_complex(:, start_idx:end_idx) = old_rephase{region};
%     X_complex(:, start_idx:end_idx) = 0;
    
end

%% Phase reset for new regions

new_indices = [];
for instr = 1 : size(new_regions_idx_cell, 1)
    
    new_indices = [new_indices (new_regions_idx_cell{instr}(1):new_regions_idx_cell{instr}(2))];
    
end

dspec_value = zeros(size(HD_in, 1), 1);
hspec_value = zeros(size(HH_in, 1), 1);

for frame_no = 1 : size(X,2)
    
    new_phase_value = zeros(size(phaseX_in, 1), 1);
    
    if ismember(frame_no, new_indices)
        
        for bin_no = 1 : size(WD_in, 1)
            %%
            for instr = 1 : size(HD_in, 1)
                
                onset_cell = onsets_new_frames{instr};
                for new_onsets = 1 : size(onset_cell,1)
                
                    if ismember(frame_no, onset_cell{new_onsets})
                       
                        new_onset_loc = find(onset_cell{new_onsets} == frame_no);
                        new_frame_no = onsets_old_frames{instr}{new_onsets}(new_onset_loc);
                        dspec_value(instr) = WD_in(bin_no, instr) * HD_in(instr, new_frame_no);
                        
                    end
                
                end
                
            end
            
            spec_max_instr = find(dspec_value == max(dspec_value));
            
            for instr = 1 : size(HH_in, 1)
                hspec_value(instr) = WH_in(bin_no, instr) * HH_in(instr, frame_no);
            end
            hspec_max_instr = find(hspec_value == max(hspec_value));
            hSpec = sum(hspec_value);
            
            if isempty(hspec_value)
                flag = 1;
            elseif max(dspec_value) > hSpec
                flag = 1;
            else
                flag = 0;
            end 
            
            if flag
                
                onset_cell = onsets_new_frames{spec_max_instr};
                for new_onsets = 1 : size(onset_cell, 1)

                    if ismember(frame_no, onset_cell{new_onsets})

                        new_onset_loc = find(onset_cell{new_onsets} == frame_no);
                        new_to_old_index = [frame_no,bin_no,spec_max_instr,new_onsets,new_onset_loc];

                        if new_frame_no == 1
                            if bin_no == 1
                                new_phase_value(bin_no) = phaseX_in(bin_no, new_frame_no);
                            else
                                new_phase_value(bin_no) = new_phase_value(bin_no) + phaseX_in(bin_no, new_frame_no);
                            end
                        else
                            if bin_no == 1
                                new_phase_value(bin_no) = phaseX_in(bin_no, new_frame_no) - phaseX_in(bin_no, new_frame_no-1);
                            else
                                new_phase_value(bin_no) = new_phase_value(bin_no) + phaseX_in(bin_no, new_frame_no) - phaseX_in(bin_no, new_frame_no-1);
                            end

                        end

                    end

                end
                
            else
               
                new_phase_value(bin_no) = phaseX_in(bin_no, frame_no);
                
            end
            
        end
        
        X_complex(:, frame_no) = X(:, frame_no).*(exp(1i*new_phase_value));
        
    end
    
end

end