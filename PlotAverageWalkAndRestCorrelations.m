% PlotAverageWalkAndRestCorrelations.m
% Sarah West
% 5/27/22

% Runs with RunAnalysis.m
function [parameters] = PlotAverageWalkAndRestCorrelations(parameters)

    cmap_corrs = parula(256); 
    cmap_diffs = flipud(cbrewer('div', 'RdBu', 256, 'nearest'));
    c_range_diffs = [-0.5 0.5]; 

    parameters.fig = figure;
    parameters.fig.WindowState = 'maximized';

    spon_walk = parameters.data{190};
    spon_rest = parameters.data{189};
    
    holder = NaN(parameters.number_of_sources, parameters.number_of_sources);
    holder(parameters.indices) = spon_rest;
    subplot(2,5,1); imagesc(holder);  colorbar; colormap(gca,cmap_corrs); caxis([0 2]); axis square;
    title('spon rest');
    
    spon_walk_diff = spon_walk - spon_rest;
    holder = NaN(parameters.number_of_sources, parameters.number_of_sources);
    holder(parameters.indices) = spon_walk_diff;
    subplot(2,5,2); imagesc(holder);  colorbar; colormap(gca, cmap_diffs); caxis(c_range_diffs); axis square;
    title('diff spon walk');    
    
    % rest
    holder = NaN(parameters.number_of_sources, parameters.number_of_sources);
    holder(parameters.indices) = parameters.data{180};
    subplot(2,5,6); imagesc(holder);  colorbar; colormap(gca,cmap_corrs); caxis([0 2]); axis square;
    title('motor rest');
    
    % walk 1600
    motor_walk_diff = parameters.data{176} - parameters.data{180};
    holder = NaN(parameters.number_of_sources, parameters.number_of_sources);
    holder(parameters.indices) = motor_walk_diff;
    subplot(2,5,7); imagesc(holder); colorbar; colormap(gca, cmap_diffs); caxis(c_range_diffs); axis square;
    title('diff motor walk 1600');
    
    % walk 2000
    motor_walk_diff = parameters.data{177} - parameters.data{180};
    holder = NaN(parameters.number_of_sources, parameters.number_of_sources);
    holder(parameters.indices) = motor_walk_diff;
    subplot(2,5,8); imagesc(holder);  colorbar; colormap(gca, cmap_diffs); caxis(c_range_diffs); axis square;
    title('diff motor walk 2000');
    
    % walk 2400
    motor_walk_diff = parameters.data{178} - parameters.data{180};
    holder = NaN(parameters.number_of_sources, parameters.number_of_sources);
    holder(parameters.indices) = motor_walk_diff;
    subplot(2,5,9); imagesc(holder);  colorbar; colormap(gca, cmap_diffs); caxis(c_range_diffs); axis square;
    title('diff motor walk 2400');
    
    % walk 2800
    motor_walk_diff = parameters.data{179} - parameters.data{180};
    holder = NaN(parameters.number_of_sources, parameters.number_of_sources);
    holder(parameters.indices) = motor_walk_diff;
    subplot(2,5,10); imagesc(holder); colorbar; colormap(gca, cmap_diffs); caxis(c_range_diffs); axis square;
    title('diff motor walk 2800');
    
    % Motorized vs spontaneous rest
    motor_rest_diff = parameters.data{180} - spon_rest;
    holder = NaN(parameters.number_of_sources, parameters.number_of_sources);
    holder(parameters.indices) = motor_rest_diff;
    subplot(2,5,5); imagesc(holder);  colorbar; colormap(gca, cmap_diffs); caxis(c_range_diffs); axis square;
    title('diff motor rest - spon rest');
    
    sgtitle(strjoin(parameters.values(1:end/2), ', '));

end 

