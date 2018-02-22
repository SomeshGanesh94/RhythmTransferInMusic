function X_complex = phaseProcessing(X, phaseX_in, param, regionsAndIdx)

X_complex = phaseX_in;

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
    
end

%% Phase reconstruction for old regions using toolbox
old_rephase = cell(size(old_region_cell));

for region = 1 : size(old_rephase,1)
  
    old_rephase{region} = pghi(old_region_cell{region}, param.windowSize, param.hopSize, param.windowSize);
    start_idx = old_region_idx_cell{region}(1);
    end_idx = old_region_idx_cell{region}(2);
    X_complex(:, start_idx:end_idx) = old_rephase{region};
    
end

%% Phase reset for new regions

new_rephase = cell(size(new_region_cell));

for region = 1 : size(new_rephase, 1)
    
    
    
    
end

end