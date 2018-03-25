function regionsAndIdx = findOnsetRegions(X, phaseX_in, onsets_new_frames, onsets_old_frames, param)

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
            
        end
        
    end
    
    for onset_num = 1 : size(onsets_new_frames{instr}, 1)
   
        if ~isempty(onsets_new_frames{instr}{onset_num})
            
            start_idx = onsets_new_frames{instr}{onset_num}(1);
            end_idx = onsets_new_frames{instr}{onset_num}(end);
            new_onsets(start_idx:end_idx) = 1;
            
        end
        
    end
    
end
%% Finding regions for old onsets
offset_old_onsets = find(old_onsets);
prev_idx = offset_old_onsets(1);

if ~isempty(offset_old_onsets)

    region_count = 1;
    for i = 2 : length(offset_old_onsets)
        
        curr_idx = offset_old_onsets(i);
        if (curr_idx - prev_idx) > 1
            
            region_count = region_count + 1;
            
        end
        prev_idx = curr_idx;
        
    end
    
else
    
    region_count = 0;
    
end

if ~isempty(offset_old_onsets)

    old_region_idx_cell = cell(region_count, 1);
    start_idx = offset_old_onsets(1);
    prev_idx = offset_old_onsets(1);
    region = 1;
    
    for i = 2 : length(offset_old_onsets)
       
        curr_idx = offset_old_onsets(i);
        if (curr_idx - prev_idx) > 1
        
            end_idx = prev_idx;
            old_region_idx_cell{region} = [start_idx, end_idx];
            region = region + 1;
            start_idx = curr_idx;
            
        end
        prev_idx = curr_idx;
        
    end
    end_idx = prev_idx;
    old_region_idx_cell{region} = [start_idx, end_idx];
    
else
    
    old_region_idx_cell = {};
    
end

old_region_cell = cell(size(old_region_idx_cell));
for region = 1 : size(old_region_idx_cell, 1)

    start_idx = old_region_idx_cell{region}(1);
    end_idx = old_region_idx_cell{region}(2);
    old_region_cell{region} = X(:, start_idx:end_idx);
    
end

%% Finding regions for new onsets
offset_new_onsets = find(new_onsets);
prev_idx = offset_new_onsets(1);

if ~isempty(offset_new_onsets)

    region_count = 1;
    for i = 2 : length(offset_new_onsets)
        
        curr_idx = offset_new_onsets(i);
        if (curr_idx - prev_idx) > 1
            
            region_count = region_count + 1;
            
        end
        prev_idx = curr_idx;
        
    end
    
else
    
    region_count = 0;
    
end

if ~isempty(offset_new_onsets)

    new_region_idx_cell = cell(region_count, 1);
    start_idx = offset_new_onsets(1);
    prev_idx = offset_new_onsets(1);
    region = 1;
    
    for i = 2 : length(offset_new_onsets)
       
        curr_idx = offset_new_onsets(i);
        if (curr_idx - prev_idx) > 1
        
            end_idx = prev_idx;
            new_region_idx_cell{region} = [start_idx, end_idx];
            region = region + 1;
            start_idx = curr_idx;
            
        end
        prev_idx = curr_idx;
        
    end
    end_idx = prev_idx;
    new_region_idx_cell{region} = [start_idx, end_idx];
    
else
    
    new_region_idx_cell = {};
    
end

new_region_cell = cell(size(new_region_idx_cell));
for region = 1 : size(new_region_idx_cell, 1)

    start_idx = new_region_idx_cell{region}(1);
    end_idx = new_region_idx_cell{region}(2);
    new_region_cell{region} = X(:, start_idx:end_idx);
    
end

%% Finding regions for no onsets
no_onsets = old_onsets + new_onsets;
no_onsets(no_onsets > 0) = 1;
no_onsets = 1 - no_onsets;

offset_no_onsets = find(no_onsets);
prev_idx = offset_no_onsets(1);

if ~isempty(offset_no_onsets)

    region_count = 1;
    for i = 2 : length(offset_no_onsets)
        
        curr_idx = offset_no_onsets(i);
        if (curr_idx - prev_idx) > 1
            
            region_count = region_count + 1;
            
        end
        prev_idx = curr_idx;
        
    end
    
else
    
    region_count = 0;
    
end

if ~isempty(offset_no_onsets)

    no_region_idx_cell = cell(region_count, 1);
    start_idx = 1;
    prev_idx = offset_no_onsets(1);
    region = 1;
    
    for i = 2 : length(offset_no_onsets)
       
        curr_idx = offset_no_onsets(i);
        if (curr_idx - prev_idx) > 1
        
            end_idx = prev_idx;
            no_region_idx_cell{region} = [start_idx, end_idx];
            region = region + 1;
            start_idx = curr_idx;
            
        end
        prev_idx = curr_idx;
        
    end
    end_idx = prev_idx;
    no_region_idx_cell{region} = [start_idx, end_idx];
    
else
    
    no_region_idx_cell = {};
    
end

no_region_cell = cell(size(no_region_idx_cell));
for region = 1 : size(no_region_idx_cell, 1)

    start_idx = no_region_idx_cell{region}(1);
    end_idx = no_region_idx_cell{region}(2);
    no_region_cell{region} = X(:, start_idx:end_idx);
    
end

%% Storing values in a cell
regionsAndIdx = cell(3,2);
regionsAndIdx{1,1} = old_region_cell;
regionsAndIdx{1,2} = old_region_idx_cell;
regionsAndIdx{2,1} = new_region_cell;
regionsAndIdx{2,2} = new_region_idx_cell;
regionsAndIdx{3,1} = no_region_cell;
regionsAndIdx{3,2} = no_region_idx_cell;

end