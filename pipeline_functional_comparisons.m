% pipeline_functional_comparisons.m
% Sarah West
% 5/16/22

% Pipeline that allows for comparisons between behavior types-- for Random
% Motorized Treadmill project. Is run AFTER pipeline_fluorescence_analysis
% (so, once correlations & PCs have been calculated & separated, here you
% start averaging things by behavior).

%% Initial Setup  
% Put all needed paramters in a structure called "parameters", which you
% can then easily feed into your functions. 
clear all; 

% Create the experiment name.
parameters.experiment_name='Random Motorized Treadmill';

% Output directory name bases
parameters.dir_base='Y:\Sarah\Analysis\Experiments\';
parameters.dir_exper=[parameters.dir_base parameters.experiment_name '\']; 

% Load mice_all, pass into parameters structure
load([parameters.dir_exper '\mice_all.mat']);
parameters.mice_all = mice_all;

% ****Change here if there are specific mice, days, and/or stacks you want to work with**** 
parameters.mice_all = parameters.mice_all(1);
%parameters.mice_all(1).days = parameters.mice_all(1).days(10:end);

% Include stacks from a "spontaneous" field of mice_all?
parameters.use_spontaneous_also = true;

% Other parameters
parameters.digitNumber = 2;
parameters.yDim = 256;
parameters.xDim = 256;
number_of_sources = 32; 

% Make a conditions structure
conditions= {'motorized'; 'spontaneous'};
conditions_stack_locations = {'stacks'; 'spontaneous'};

% Load nametable of motorized periods
load([parameters.dir_exper 'periods_nametable.mat']);
periods_nametable_motorized= periods;

% Load name table of spontaneous periods
load([parameters.dir_exper 'periods_nametable_spontaneous.mat']);
periods_nametable_spontaneous = periods;

% Create a shared motorized & spontaneous table.
periods_bothConditions = [periods_nametable_motorized; periods_nametable_spontaneous]; 

% Make list of transformation types for iterating later.
parameters.loop_variables.transformations = {'not transformed'; 'Fisher transformed'};
parameters.loop_variables.data_type = {'correlations', 'PCA across mice'};
parameters.loop_variables.mice_all = parameters.mice_all;
parameters.loop_variables.conditions = conditions;
parameters.loop_variables.conditions_stack_locations = conditions_stack_locations;
parameters.loop_variables.accelerations.startstop = {'400', '800'};
parameters.loop_variables.accelerations.acceldecell = {'200', '800'};

%% Average data values by behavior (within mice)
% Always clear loop list first. 
if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

% Iterators
parameters.loop_list.iterators = {
               'data_type',  {'loop_variables.data_type'}, 'data_type_iterator';
               'transformation', {'loop_variables.transformations'}, 'transformation_iterator';
               'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               'period', {'loop_variables.periods'}, 'period_iterator';            
               };

parameters.loop_variables.periods = periods_bothConditions.condition; 

% 
parameters.averageDim = 3;

% Input 
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'fluorescence analysis\'],'data type', '\', 'transformation', '\', 'mouse', '\instances reshaped\'};
parameters.loop_list.things_to_load.data.filename= {'values.mat'};
parameters.loop_list.things_to_load.data.variable= {'values{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_load.data.level = 'mouse';

% Output
parameters.loop_list.things_to_save.average.dir = {[parameters.dir_exper 'fluorescence analysis\'],'data type', '\', 'transformation', '\', 'mouse', '\instances reshaped\'};
parameters.loop_list.things_to_save.average.filename= {'values_average.mat'};
parameters.loop_list.things_to_save.average.variable= {'values_average{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_save.average.level = 'mouse';

parameters.loop_list.things_to_save.std_dev.dir = {[parameters.dir_exper 'fluorescence analysis\'],'data type', '\', 'transformation', '\', 'mouse', '\instances reshaped\'};
parameters.loop_list.things_to_save.std_dev.filename= {'values_std.mat'};
parameters.loop_list.things_to_save.std_dev.variable= {'values_std{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_save.std_dev.level = 'mouse';

RunAnalysis({@AverageData}, parameters);

%% Correltions, individual mice -- Visualize difference in mean continued rest & walk for motorized & spontaneous
mouse ='1087';
cmap_corrs = parula(256); 
cmap_diffs = flipud(cbrewer('div', 'RdBu', 256, 'nearest'));
c_range_diffs = [-0.3 0.3];
figure; 

filename = 'correlations_rolled_average.mat';

for transi = 1:numel(parameters.loop_variables.transformations)

    transformation = parameters.loop_variables.transformations{transi};
    motor = load([parameters.dir_exper 'fluorescence analysis\correlations\' transformation '\' mouse '\average rolled\' filename]);
    figure;
    spon_walk.average = motor.average{190};
    spon_rest.average = motor.average{189};
    
    subplot(2,5,1); imagesc(spon_rest.average);  colorbar; colormap(gca,cmap_corrs); caxis([0 1]);
    title('spon rest');
    
    spon_walk_diff = spon_walk.average - spon_rest.average;
    subplot(2,5,2); imagesc(spon_walk_diff);  colorbar; colormap(gca, cmap_diffs); caxis(c_range_diffs);
    title('diff spon walk');
    
    
    % rest
    subplot(2,5,6); imagesc(motor.average{180});  colorbar; colormap(gca,cmap_corrs); caxis([0 1]);
    title('motor rest');
    
    % walk 1600
    motor_walk_diff = motor.average{176} - motor.average{180};
    subplot(2,5,7); imagesc(motor_walk_diff); colorbar; colormap(gca, cmap_diffs); caxis(c_range_diffs);
    title('diff motor walk 1600');
    
    % walk 2000
    motor_walk_diff = motor.average{177} - motor.average{180};
    subplot(2,5,8); imagesc(motor_walk_diff);  colorbar; colormap(gca, cmap_diffs); caxis(c_range_diffs);
    title('diff motor walk 2000');
    
    % walk 2400
    motor_walk_diff = motor.average{178} - motor.average{180};
    subplot(2,5,9); imagesc(motor_walk_diff);  colorbar; colormap(gca, cmap_diffs); caxis(c_range_diffs);
    title('diff motor walk 2400');
    
    % walk 2800
    motor_walk_diff = motor.average{179} - motor.average{180};
    subplot(2,5,10); imagesc(motor_walk_diff); colorbar; colormap(gca, cmap_diffs); caxis(c_range_diffs);
    title('diff motor walk 2800');
    
    motor_rest_diff = motor.average{180} - spon_rest.average;
    subplot(2,5,5); imagesc(motor_rest_diff);  colorbar; colormap(gca, cmap_diffs); caxis(c_range_diffs);
    title('diff motor rest - spon rest');
    
    sgtitle([mouse ', ' transformation]);
end

%% Individual mice -- plot mean PC scores for continued rest & walk 
mouse ='1087';

filename = 'values_average.mat';

for transi = 1:numel(parameters.loop_variables.transformations)

    transformation = parameters.loop_variables.transformations{transi};
    load(['Y:\Sarah\Analysis\Experiments\Random Motorized Treadmill\fluorescence analysis\PCA across mice\' transformation '\' mouse '\instances reshaped\' filename])

    scores = [values_average{180} values_average{190} values_average{176} values_average{177} values_average{178} values_average{179} values_average{189}];
    figure; imagesc(scores(1:20,:));
    xticklabels({'motor rest', 'spon rest', '1600', '2000', '2400', '2800', 'spon walk'});
    colorbar;
    title([mouse ', ' transformation]);
    dir_out = ['Y:\Sarah\Analysis\Experiments\Random Motorized Treadmill\functional comparisons\PCA across mice\' transformation '\average walk and rest\' mouse '\'];
    mkdir(dir_out);
    savefig([dir_out 'average_walk_rest_values_first20.fig']);
end

%% Take the averaged individual mice values & concatenate across mice.
% Always clear loop list first. 
if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

% Iterators
parameters.loop_list.iterators = {
               'data_type',  {'loop_variables.data_type'}, 'data_type_iterator';
               'transformation', {'loop_variables.transformations'}, 'transformation_iterator';
               'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               'period', {'loop_variables.periods'}, 'period_iterator';            
               };

parameters.loop_variables.periods = periods_bothConditions.condition; 
parameters.concatDim = 3; 

% Input
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'fluorescence analysis\PCA across mice\'], 'data_type', '\','transformation', '\', 'mouse', '\instances reshaped\'};
parameters.loop_list.things_to_load.data.filename= {'values_average.mat'};
parameters.loop_list.things_to_load.data.variable= {'values_average{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_load.data.level = 'mouse';

% Output
parameters.loop_list.things_to_save.concatenated_data.dir = {[parameters.dir_exper 'fluorescence analysis\'], 'data_type', '\', 'transformation', '\averages across mice\'};
parameters.loop_list.things_to_save.concatenated_data.filename= {'values_all_averages.mat'};
parameters.loop_list.things_to_save.concatenated_data.variable= {'values_all_averages{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_save.concatenated_data.level = 'transformation';

parameters.loop_list.things_to_save.concatenated_origin.dir = {[parameters.dir_exper 'fluorescence analysis\'], 'data_type', '\', 'transformation', '\averages across mice\'};
parameters.loop_list.things_to_save.concatenated_originfilename= {'values_all_averages_concatenation_origin.mat'};
parameters.loop_list.things_to_save.concatenated_origin.variable= {'values_concatenation_origin{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_save.concatenated_origin.level = 'transformation';

RunAnalysis({@ConcatenateData}, parameters);

%% Take average of values across mice, within behaviors.
% Always clear loop list first. 
if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

% Iterators
parameters.loop_list.iterators = {
               'data_type',  {'loop_variables.data_type'}, 'data_type_iterator';
               'transformation', {'loop_variables.transformations'}, 'transformation_iterator';
               'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               'period', {'loop_variables.periods'}, 'period_iterator';            
               };

parameters.loop_variables.periods = periods_bothConditions.condition; 
parameters.averageDim = 3; 

% Input
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'fluorescence analysis\PCA across mice\'], 'data_type', '\','transformation', '\averages across mice\'};
parameters.loop_list.things_to_load.data.filename= {'values_all_averages.mat'};
parameters.loop_list.things_to_load.data.variable= {'values_all_averages{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_load.data.level = 'transformation';

% Output
parameters.loop_list.things_to_save.average.dir = {[parameters.dir_exper 'fluorescence analysis\'], 'data type', '\', 'transformation', '\averages across mice\'};
parameters.loop_list.things_to_save.average.filename= {'values_average.mat'};
parameters.loop_list.things_to_save.average.variable= {'values_average{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_save.average.level = 'transformation';

parameters.loop_list.things_to_save.std_dev.dir = {[parameters.dir_exper 'fluorescence analysis\'], 'data type', '\', 'transformation', '\averages across mice\'};
parameters.loop_list.things_to_save.std_dev.filename= {'values_std.mat'};
parameters.loop_list.things_to_save.std_dev.variable= {'values_std{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_save.std_dev.level = 'transformation';

RunAnalysis({@AverageData}, parameters);

%% Across mice -- plot mean correlations for continued rest & walk.

%% Across mice -- plot mean PC scores for continued rest & walk 

%%  Within mice -- Visualize average values across rolled periods that may need to be compared
% Is all periods except continued rest & walk.
% Always clear loop list first. 
if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

variable_periods = unique(periods_bothConditions.condition, 'stable');
variable_periods([26, 27, 29, 30]) = [];

% Iterators
parameters.loop_list.iterators = {
               'data_type', {'loop_variables.data_type'}, 'data_type_iterator';
               'transformation', {'loop_variables.transformations'}, 'transformation_iterator';
               'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               'period', {'loop_variables.periods'}, 'period_iterator';            
               };

parameters.loop_variables.periods = variable_periods;
parameters.periods_nametable = periods_bothConditions;
parameters.periods_bothConditions = periods_bothConditions.condition;

% Input
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'fluorescence analysis\'], 'data_type', '\', 'transformation', '\', 'mouse', '\instances reshaped\'};
parameters.loop_list.things_to_load.data.filename= {'values_average.mat'};
parameters.loop_list.things_to_load.data.variable= {'values_average'}; 
parameters.loop_list.things_to_load.data.level = 'mouse';

% Output
parameters.loop_list.things_to_save.visual_fig.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\', 'transformation', '\average visualization\', 'mouse', '\'};
parameters.loop_list.things_to_save.visual_fig.filename= {'rolled_average_', 'period', '.fig'};
parameters.loop_list.things_to_save.visual_fig.variable= {'rolled_average'}; 
parameters.loop_list.things_to_save.visual_fig.level = 'period';

RunAnalysis({@VisualizeAverageRolledData}, parameters);

close all;

%% Across mice - Visualize average values across rolled periods that may need to be compared
% Is all periods except continued rest & walk.
% Always clear loop list first. 
if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

variable_periods = unique(periods_bothConditions.condition, 'stable');
variable_periods([26, 27, 29, 30]) = [];

% Iterators
parameters.loop_list.iterators = {
               'data_type', {'loop_variables.data_type'}, 'data_type_iterator';
               'transformation', {'loop_variables.transformations'}, 'transformation_iterator';
               'period', {'loop_variables.periods'}, 'period_iterator';            
               };

parameters.loop_variables.periods = variable_periods;
parameters.periods_nametable = periods_bothConditions;
parameters.periods_bothConditions = periods_bothConditions.condition;

% Input
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'fluorescence analysis\'], 'data_type', '\', 'transformation', '\averages across mice\',};
parameters.loop_list.things_to_load.data.filename= {'values_average.mat'};
parameters.loop_list.things_to_load.data.variable= {'values_average'}; 
parameters.loop_list.things_to_load.data.level = 'transformation';

% Output
parameters.loop_list.things_to_save.visual_fig.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\', 'transformation', '\average visualization\across mice\'};
parameters.loop_list.things_to_save.visual_fig.filename= {'rolled_average_', 'period', '.fig'};
parameters.loop_list.things_to_save.visual_fig.variable= {'rolled_average'}; 
parameters.loop_list.things_to_save.visual_fig.level = 'period';

RunAnalysis({@VisualizeAverageRolledData}, parameters);
close all;

% %% Concatenate variable durations together, aligned to front -- not divided by acceleration rate
% % Then average.
% % Try to plot with alpha values proportional to number of instances
% % Indclude a m_stop_ending period -- where stop is alinged to end of period. 
% variable_periods = {'m_start', 'm_stop', 'm_accel', 'm_decel', ...
%                     'm_p_nowarn_start', 'm_p_nowarn_stop', 'm_p_nowarn_accel', 'm_p_nowarn_decel'};
% 
% period_indices = {};
% for i = 1:numel(variable_periods)
%     period_indices{i} = find(contains(periods_bothConditions.condition, variable_periods{i}));
% end 
% 
% % Add the m_stop_ending. 
% variable_periods = [variable_periods, {'m_stop_ending'}];
% period_indices = [period_indices, find(contains(periods_bothConditions.condition, 'm_stop'))];
% 
% if isfield(parameters, 'loop_list')
% parameters = rmfield(parameters,'loop_list');
% end
% 
% % Iterators
% parameters.loop_list.iterators = {
%                'data_type', {'loop_variables.data_type'}, 'data_type_iterator';
%                'transformation', {'loop_variables.transformations'}, 'transformation_iterator';
%                'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
%                'period', {'loop_variables.periods'}, 'period_iterator';  
%                'index', {'loop_variables.period_indices{', 'period_iterator', '}'}, 'index_iterator'
%                };
% 
% parameters.loop_variables.periods = variable_periods;
% parameters.loop_variables.period_indices = period_indices; 
% 
% % Clear concatenated_data and start a new concatenation if this is the
% % first of a new set.
% % Initialize with an empty matrix of NaNs.(values, max roll number, number of instances). 
% % If it's m_stop_ending, align to end.
% parameters.evaluation_instructions = {{'if parameters.values{end} == 1;'...
%                                        'parameters.concatenated_data = [];'...
%                                        'end;'...
%                                       'data_evaluated = NaN(parameters.number_of_values, parameters.max_roll_number, size(parameters.data,3));'...
%                                       'if strcmp(parameters.values{4}, "m_stop_ending");' ... 
%                                         'data_evaluated(:, [parameters.max_roll_number - size(parameters.data,2) + 1 : parameters.max_roll_number],:) = parameters.data;'...
%                                       'else;' ...
%                                       'data_evaluated(:, [1:size(parameters.data,2)],:) = parameters.data;'...
%                                       'end';
%                                       }};
% 
% parameters.number_of_values = (number_of_sources^2 - number_of_sources)/2;
% parameters.max_roll_number = 24;
% 
% parameters.concatDim = 3;
% 
% % Input 
% parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'fluorescence analysis\'], 'data_type', '\', 'transformation', '\', 'mouse', '\instances reshaped\'};
% parameters.loop_list.things_to_load.data.filename= {'values.mat'};
% parameters.loop_list.things_to_load.data.variable= {'values{', 'index', '}'}; 
% parameters.loop_list.things_to_load.data.level = 'mouse';
% 
% % Output 
% parameters.loop_list.things_to_save.concatenated_data.dir = {[parameters.dir_exper 'functional comparisons\'],'data_type', '\', 'transformation', '\variable duration\no division\', 'mouse','\'};
% parameters.loop_list.things_to_save.concatenated_data.filename= {'values_concatenated.mat'};
% parameters.loop_list.things_to_save.concatenated_data.variable= {'values_concatenated{', 'period_iterator', ', 1}'}; 
% parameters.loop_list.things_to_save.concatenated_data.level = 'mouse';
% 
% parameters.loop_list.things_to_save.concatenated_origin.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\no division\', 'mouse', '\'};
% parameters.loop_list.things_to_save.concatenated_origin.filename= {'values_concatenated_origin.mat'};
% parameters.loop_list.things_to_save.concatenated_origin.variable= {'values_concatenated_origin{', 'period_iterator', ', 1}'}; 
% parameters.loop_list.things_to_save.concatenated_origin.level = 'mouse';
% 
% parameters.loop_list.things_to_rename = {{'data_evaluated', 'data'}};
%                                 
% RunAnalysis({@EvaluateOnData, @ConcatenateData}, parameters);
% 
% %% Average the variable values, counting the number of contributions. -- not divided by acceleration rate
% variable_periods = {'m_start', 'm_stop', 'm_accel', 'm_decel', ...
%                     'm_p_nowarn_start', 'm_p_nowarn_stop', 'm_p_nowarn_accel', 'm_p_nowarn_decel', ...
%                     'm_stop_ending'};
% 
% if isfield(parameters, 'loop_list')
% parameters = rmfield(parameters,'loop_list');
% end
% 
% % Iterators
% parameters.loop_list.iterators = {
%                'data_type', {'loop_variables.data_type'}, 'data_type_iterator';
%                'transformation', {'loop_variables.transformations'}, 'transformation_iterator';
%                'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
%                'period', {'loop_variables.periods'}, 'period_iterator';  
%                };
% 
% parameters.loop_variables.periods = variable_periods;
% 
% % Count & save number of non- NaNs
% parameters.evaluation_instructions = {{'data_evaluated = sum(~isnan(parameters.data), 3);'}}; 
% parameters.averageDim = 3;
%                         
% % Input 
% parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'functional comparisons\'],'data_type', '\','transformation','\variable duration\no division\', 'mouse', '\'};
% parameters.loop_list.things_to_load.data.filename= {'values_concatenated.mat'};
% parameters.loop_list.things_to_load.data.variable= {'values_concatenated{', 'period_iterator', ', 1}'}; 
% parameters.loop_list.things_to_load.data.level = 'mouse';
% 
% % Output 
% parameters.loop_list.things_to_save.data_evaluated.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\', 'transformation','\variable duration\no division\', 'mouse', '\'};
% parameters.loop_list.things_to_save.data_evaluated.filename= {'values_number.mat'};
% parameters.loop_list.things_to_save.data_evaluated.variable= {'values_number{', 'period_iterator', ', 1}'}; 
% parameters.loop_list.things_to_save.data_evaluated.level = 'mouse';
% 
% parameters.loop_list.things_to_save.average.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\no division\', 'mouse', '\'};
% parameters.loop_list.things_to_save.average.filename= {'values_average.mat'};
% parameters.loop_list.things_to_save.average.variable= {'values_average{', 'period_iterator', ', 1}'}; 
% parameters.loop_list.things_to_save.average.level = 'mouse';
% 
% parameters.loop_list.things_to_save.std_dev.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\no division\', 'mouse', '\'};
% parameters.loop_list.things_to_save.std_dev.filename= {'values_std.mat'};
% parameters.loop_list.things_to_save.std_dev.variable= {'values_std{', 'period_iterator', ', 1}'}; 
% parameters.loop_list.things_to_save.std_dev.level = 'mouse';
% 
% RunAnalysis({@EvaluateOnData, @AverageData}, parameters);
% 
% %% Across mice-- concatenate & average the average variable duration values.
% variable_periods = {'m_start', 'm_stop', 'm_accel', 'm_decel', ...
%                     'm_p_nowarn_start', 'm_p_nowarn_stop', 'm_p_nowarn_accel', 'm_p_nowarn_decel', ...
%                     'm_stop_ending'};
% 
% if isfield(parameters, 'loop_list')
% parameters = rmfield(parameters,'loop_list');
% end
% 
% parameters.loop_variables.periods = variable_periods;
% 
% % Iterators
% parameters.loop_list.iterators = {
%                'data_type', {'loop_variables.data_type'}, 'data_type_iterator';
%                'transformation', {'loop_variables.transformations'}, 'transformation_iterator';
%                'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
%                'period', {'loop_variables.periods'}, 'period_iterator';  
%                };
% 
% parameters.concatDim = 3;
% 
% % Input
% parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\no division\', 'mouse', '\'};
% parameters.loop_list.things_to_load.data.filename= {'values_average.mat'};
% parameters.loop_list.things_to_load.data.variable= {'values_average{', 'period_iterator', ', 1}'}; 
% parameters.loop_list.things_to_load.data.level = 'mouse';
% 
% % Output
% parameters.loop_list.things_to_save.average.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\no division\across mice\'};
% parameters.loop_list.things_to_save.average.filename= {'values_average.mat'};
% parameters.loop_list.things_to_save.average.variable= {'values_acrossmice_average{', 'period_iterator', ', 1}'}; 
% parameters.loop_list.things_to_save.average.level = 'transformation';
% 
% parameters.loop_list.things_to_save.std_dev.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\no division\across mice\'};
% parameters.loop_list.things_to_save.std_dev.filename= {'values_std_dev.mat'};
% parameters.loop_list.things_to_save.std_dev.variable= {'values_acrossmice_std_dev{', 'period_iterator', ', 1}'}; 
% parameters.loop_list.things_to_save.std_dev.level = 'transformation';
% 
% parameters.loop_list.things_to_rename = {{'concatenated_data', 'data'}};
% 
% RunAnalysis({@ConcatenateData, @AverageData}, parameters);
% 
% %% Across mice -- count the (average) number of instances per mouse contributing to 
% % the the values in the variable duration periods.
% variable_periods = {'m_start', 'm_stop', 'm_accel', 'm_decel', ...
%                     'm_p_nowarn_start', 'm_p_nowarn_stop', 'm_p_nowarn_accel', 'm_p_nowarn_decel', ...
%                     'm_stop_ending'};
% 
% % Input 
% parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\', 'transformation','\variable duration\no division\', 'mouse', '\'};
% parameters.loop_list.things_to_load.data.filename= {'values_number.mat'};
% parameters.loop_list.things_to_load.data.variable= {'values_number{', 'period_iterator', ', 1}'}; 
% parameters.loop_list.things_to_load.data.level = 'mouse';
% 
% % Output
% parameters.loop_list.things_to_save.average.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\no division\across mice\'};
% parameters.loop_list.things_to_save.average.filename= {'values_number_average.mat'};
% parameters.loop_list.things_to_save.average.variable= {'values_number_average{', 'period_iterator', ', 1}'}; 
% parameters.loop_list.things_to_save.average.level = 'transformation';
% 
% arameters.loop_list.things_to_save.std_dev.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\no division\across mice\'};
% parameters.loop_list.things_to_save.std_dev.filename= {'values_number_std_dev.mat'};
% parameters.loop_list.things_to_save.std_dev.variable= {'values_number_std_dev{', 'period_iterator', ', 1}'}; 
% parameters.loop_list.things_to_save.std_dev.level = 'transformation';
% 
% RunAnalysis({@ConcatenateData, @AverageData}, parameters);

%% Concatenate variable durations together, divided by acceleration rate
% Then average.
% Try to plot with alpha values proportional to number of instances
variable_periods = {'m_start', 'm_stop', 'm_accel', 'm_decel', ...
                    'm_p_nowarn_start', 'm_p_nowarn_stop', 'm_p_nowarn_accel', 'm_p_nowarn_decel', ...
                     'full_onset', 'full_offset', 'startwalk', 'stopwalk'};
divideby = {'accel'};
behavior_indices = FindMotorizedBehaviorIndices(variable_periods, divideby, periods_bothConditions);

% Add the m_stop_ending. 
variable_periods = [variable_periods, {'m_stop_ending'}];
behavior_indices(size(behavior_indices,2) + 1) = behavior_indices(2);
behavior_indices(size(behavior_indices, 2) + 1).name = 'm_stop_ending';

if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

% Iterators
parameters.loop_list.iterators = {
               'data_type', {'loop_variables.data_type'}, 'data_type_iterator';
               'transformation', {'loop_variables.transformations'}, 'transformation_iterator';
               'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               'period', {'loop_variables.periods'}, 'period_iterator';  
               'accel', {'loop_variables.period_indices(', 'period_iterator', ').indices(:).accel'}, 'accel_iterator';
               'index', {'loop_variables.period_indices(', 'period_iterator', ').indices(', 'accel_iterator', ').indices'}, 'index_iterator';
               };

parameters.loop_variables.periods = variable_periods;
parameters.loop_variables.period_indices = behavior_indices; 

% Initialize with an empty matrix of NaNs.(values, ,max roll number). If
% the period is m_stop_ending, put at end of matrix. 
parameters.evaluation_instructions = {{'if parameters.values{end} == 1;'...
                                       'parameters.concatenated_data = [];'...
                                       'end;'...
                                       'data_evaluated = NaN(parameters.number_of_values, parameters.max_roll_number, size(parameters.data,3));'...
                                       'if strcmp(parameters.values{4}, "m_stop_ending");' ... 
                                        'data_evaluated(:, [parameters.max_roll_number - size(parameters.data,2) + 1 : parameters.max_roll_number],:) = parameters.data;'...
                                      'else;' ...
                                      'data_evaluated(:, [1:size(parameters.data,2)],:) = parameters.data;'...
                                      'end;'}};

parameters.number_of_values = (number_of_sources^2 - number_of_sources)/2;
parameters.max_roll_number = 24;

parameters.concatDim = 3;

% Input 
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'fluorescence analysis\'], 'data_type', '\', 'transformation', '\', 'mouse', '\instances reshaped\'};
parameters.loop_list.things_to_load.data.filename= {'values.mat'};
parameters.loop_list.things_to_load.data.variable= {'values{', 'index', '}'}; 
parameters.loop_list.things_to_load.data.level = 'mouse';

% Output 
parameters.loop_list.things_to_save.concatenated_data.dir = {[parameters.dir_exper 'functional comparisons\'],'data_type', '\', 'transformation', '\variable duration\divided by accel\', 'mouse', '\'};
parameters.loop_list.things_to_save.concatenated_data.filename= {'period', '.mat'};
parameters.loop_list.things_to_save.concatenated_data.variable= {'values_concatenated.x', 'accel'}; 
parameters.loop_list.things_to_save.concatenated_data.level = 'period';

parameters.loop_list.things_to_save.concatenated_origin.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation', '\variable duration\divided by accel\', 'mouse', '\'};
parameters.loop_list.things_to_save.concatenated_origin.filename= {'period', '_concatenated_origin.mat'};
parameters.loop_list.things_to_save.concatenated_origin.variable= {'values_concatenated_origin.x', 'accel'}; 
parameters.loop_list.things_to_save.concatenated_origin.level = 'period';

parameters.loop_list.things_to_rename = {{'data_evaluated', 'data'}};
                                
RunAnalysis({@EvaluateOnData, @ConcatenateData}, parameters);

%% Average the variable values, counting the number of contributions. -- divided by acceleration rate
variable_periods = {'m_start', 'm_stop', 'm_accel', 'm_decel', ...
                    'm_p_nowarn_start', 'm_p_nowarn_stop', 'm_p_nowarn_accel', 'm_p_nowarn_decel',...
                    'full_onset', 'full_offset', 'startwalk', 'stopwalk'};

divideby = {'accel'};
[behavior_indices] = FindMotorizedBehaviorIndices(variable_periods, divideby, periods_bothConditions);

% Add the m_stop_ending. 
variable_periods = [variable_periods, {'m_stop_ending'}];
behavior_indices(size(behavior_indices,2) + 1) = behavior_indices(2);
behavior_indices(size(behavior_indices, 2) + 1).name = 'm_stop_ending';

if isfield(parameters, 'loop_list')
    parameters = rmfield(parameters,'loop_list');
end

% Iterators
parameters.loop_list.iterators = {
               'data_type', {'loop_variables.data_type'}, 'data_type_iterator';
               'transformation', {'loop_variables.transformations'}, 'transformation_iterator';
               'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               'period', {'loop_variables.periods'}, 'period_iterator';  
               'accel', {'loop_variables.period_indices(', 'period_iterator', ').indices(:).accel'}, 'accel_iterator';
               };

parameters.loop_variables.periods = variable_periods;
parameters.loop_variables.period_indices = behavior_indices;

% Count & save number of non- NaNs
parameters.evaluation_instructions = {{'data_evaluated = sum(~isnan(parameters.data), 3);'}}; 
parameters.averageDim = 3;
                        
% Input 
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'functional comparisons\'],'data_type', '\', 'transformation', '\variable duration\divided by accel\', 'mouse', '\'};
parameters.loop_list.things_to_load.data.filename= {'period', '.mat'};
parameters.loop_list.things_to_load.data.variable= {'values_concatenated.x', 'accel'}; 
parameters.loop_list.things_to_load.data.level = 'period';

% Output
parameters.loop_list.things_to_save.data_evaluated.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\', 'transformation', '\variable duration\divided by accel\', 'mouse', '\'};
parameters.loop_list.things_to_save.data_evaluated.filename= {'period', '_count.mat'};
parameters.loop_list.things_to_save.data_evaluated.variable= {'values_number.x', 'accel'}; 
parameters.loop_list.things_to_save.data_evaluated.level = 'period';

parameters.loop_list.things_to_save.average.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\', 'transformation', '\variable duration\divided by accel\', 'mouse', '\'};
parameters.loop_list.things_to_save.average.filename= {'period', '_averaged.mat'};
parameters.loop_list.things_to_save.average.variable= {'values_averaged.x', 'accel'}; 
parameters.loop_list.things_to_save.average.level = 'period';

RunAnalysis({@EvaluateOnData, @AverageData}, parameters);

%% Across mice-- accel divided, concatenate the average accel divided values.

% [still need to change periods list, directories]

variable_periods = {'m_start', 'm_stop', 'm_accel', 'm_decel', ...
                    'm_p_nowarn_start', 'm_p_nowarn_stop', 'm_p_nowarn_accel', 'm_p_nowarn_decel', ...
                    'm_stop_ending'};

if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

parameters.loop_variables.periods = variable_periods;

% Iterators
parameters.loop_list.iterators = {
               'data_type', {'loop_variables.data_type'}, 'data_type_iterator';
               'transformation', {'loop_variables.transformations'}, 'transformation_iterator';
               'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               'period', {'loop_variables.periods'}, 'period_iterator';  
               };

parameters.concatDim = 3;

% Input
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\divided by accel\', 'mouse', '\'};
parameters.loop_list.things_to_load.data.filename= {'values_average.mat'};
parameters.loop_list.things_to_load.data.variable= {'values_average{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_load.data.level = 'mouse';

% Output
parameters.loop_list.things_to_save.average.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\divided by accel\across mice\'};
parameters.loop_list.things_to_save.average.filename= {'values_average.mat'};
parameters.loop_list.things_to_save.average.variable= {'values_acrossmice_average{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_save.average.level = 'transformation';

parameters.loop_list.things_to_save.std_dev.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\divided by accel\across mice\'};
parameters.loop_list.things_to_save.std_dev.filename= {'values_std_dev.mat'};
parameters.loop_list.things_to_save.std_dev.variable= {'values_acrossmice_std_dev{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_save.std_dev.level = 'transformation';

parameters.loop_list.things_to_rename = {{'concatenated_data', 'data'}};

RunAnalysis({@ConcatenateData, @AverageData}, parameters);

%% Across mice -- accel divided, count the (average) number of instances per mouse contributing to 
% the the values in the variable duration periods.

% [still need to change periods list, directories]

variable_periods = {'m_start', 'm_stop', 'm_accel', 'm_decel', ...
                    'm_p_nowarn_start', 'm_p_nowarn_stop', 'm_p_nowarn_accel', 'm_p_nowarn_decel', ...
                    'm_stop_ending'};

% Input 
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\', 'transformation','\variable duration\divided by accel\', 'mouse', '\'};
parameters.loop_list.things_to_load.data.filename= {'values_number.mat'};
parameters.loop_list.things_to_load.data.variable= {'values_number{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_load.data.level = 'mouse';

% Output
parameters.loop_list.things_to_save.average.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\divided by accel\across mice\'};
parameters.loop_list.things_to_save.average.filename= {'values_number_average.mat'};
parameters.loop_list.things_to_save.average.variable= {'values_number_average{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_save.average.level = 'transformation';

arameters.loop_list.things_to_save.std_dev.dir = {[parameters.dir_exper 'functional comparisons\'], 'data_type', '\','transformation','\variable duration\divided by accel\across mice\'};
parameters.loop_list.things_to_save.std_dev.filename= {'values_number_std_dev.mat'};
parameters.loop_list.things_to_save.std_dev.variable= {'values_number_std_dev{', 'period_iterator', ', 1}'}; 
parameters.loop_list.things_to_save.std_dev.level = 'transformation';

RunAnalysis({@ConcatenateData, @AverageData}, parameters);


%% Plot starts & stops together in same figures (per mouse)
% (divided by accel)
if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

% Iterators
parameters.loop_list.iterators = {
               'transformation', {'loop_variables.transformations'}, 'transformation_iterator';
               'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'};

parameters.spontaneous_periods_dir = {[parameters.dir_exper 'fluorescence analysis\PCA across mice\'], 'transformation', '\', 'mouse', '\instances reshaped\'};
parameters.motorized_periods_dir = {[parameters.dir_exper 'functional comparisons\PCA across mice\'], 'transformation', '\variable duration\divided by accel\', 'mouse', '\'};
parameters.dir_out = {[parameters.dir_exper 'functional comparisons\PCA across mice\'], 'transformation', '\all starts and stops\', 'mouse', '\'};
plot_starts_and_stops_together(parameters);

%% Across mice -- Divided by accel, plot starts & stops together in same figures. 

%% Look at difference between spontaneous & motorized walks.
% Start with speed regressions? 

%% Look at effect of accel on motorized start/stop. 
% Could treat as time-invarying 
% and/or could do a "compare the timing of the maximum time point" thing

%% Look at spontaneous vs motorized start/stop
% May need to do the "compare the maximum time point" thing or something.
% And/or do only a comparison to the 800 acceleration rate or something.

%% Look at similarities/differences between start/stop vs accel/decel
% May need to do the "compare the maximum time point" thing or something.

%% Look at the effect of acceleration rate (if any) on accel/decel. 
% Don't break up by start or end speed/duration, because you'll have the
% variable duration plots. 
% Figure out how to compare these, because the timing & therefore the
% placement of the potentially relevant values in the matrices may be
% different. Maybe compare the values of a maximum time point, and/or the timing 
% of that time point.

%% Look at the effect of speeds (if any) on accel/decell
% For both accel & decel, and for both deceleration rates, group by start speed
% Then subtract/ compare the difference of the two higher speeds to the
% lowest speed ( & probably to each other). 
% Don't need to group by end speed or duration, because you'll have the variable
% duration plots. 

%% Look at finished periods
% Look at the effect of current speed (by comparing pairs of behaviors
% where the only thing that differs is the current speed).
% Look at the effect of accel (by comparing pairs of behaviors where the
% only thing that differs is the accel)
% Effect of previous speed (by comparing pairs of behaviors where the
% only thing that differs is the previous speed/duration)

%% Look at warning pergit iods
% Effect of warning compared to same-speed continued and/or paired no warning probe. 
% Look at the effect of current speed (by comparing pairs of behaviors
% where the only thing that differs is the current speed).

%% Look at effect of warning periods on behavior
% (by comparing pairs of behaviors
% where the only thing that differs is if the warning was given or not) --
% might need to break this down into behavior type & accels 

 