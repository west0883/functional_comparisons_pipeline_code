% plot_starts_and_stops_together.m
% Sarah West
% 5/20/22

% Quick function/script that plots starts/stops in same figure.

function [] = plot_starts_and_stops_together(parameters)

    looping_output_list = LoopGenerator(parameters.loop_list, parameters.loop_variables);
    
    keywords = [parameters.loop_list.iterators(:,1); parameters.loop_list.iterators(:,3)];

    for itemi = 1:size(looping_output_list,1)

        % Values are the corresponding values in the looping output list
        % for each keyword's field.
        values = cell(size(keywords));
        for i = 1: numel(keywords)
            values{i} = looping_output_list(itemi).(cell2mat(keywords(i)));
        end

        % Make dir_out 
        output_dir = CreateStrings(parameters.dir_out, keywords, values);
        if ~exist(output_dir, 'dir')
            mkdir(output_dir);
        end
        
        % Do starts 
        load_dir_string = CreateStrings(parameters.spontaneous_periods_dir, keywords, values);
        load([load_dir_string 'values_average.mat'], 'values_average');
        startwalk = values_average{192}(1:20,:);

        load_dir_string = CreateStrings(parameters.motorized_periods_dir, keywords, values);
        load([load_dir_string 'm_start_averaged.mat'], 'values_averaged');
        m_start_400 = values_averaged.x400(1:20,:);
        m_start_800 = values_averaged.x800(1:20,:);

        figure; 
        subplot(3, 24, 1:8); imagesc(startwalk); caxis([-2 2]); title('startwalk'); 
        subplot(3, 1, 2); imagesc(m_start_400);  caxis([-2 2]); title('motorized start, accel 400');
        subplot(3, 1, 3); imagesc(m_start_800);  caxis([-2 2]); title('motorized start, accel 800');
        sgtitle(['PCA scores individual mouse, ' strjoin(values(1:numel(values)/2), ', ')]);
        savefig([output_dir 'all_starts_together.fig']);

        % Do stops
        load_dir_string = CreateStrings(parameters.spontaneous_periods_dir, keywords, values);
        load([load_dir_string 'values_average.mat'], 'values_average');
        stopwalk = values_average{193}(1:20, :);
    
        load_dir_string = CreateStrings(parameters.motorized_periods_dir, keywords, values);
        load([load_dir_string 'm_stop_averaged.mat'], 'values_averaged');
        m_stop_400 = values_averaged.x400(1:20,:);
        m_stop_800 = values_averaged.x800(1:20,:);
        load([load_dir_string 'm_stop_ending_averaged.mat'], 'values_averaged');
        m_stop_ending_400 = values_averaged.x400(1:20,:);
        m_stop_ending_800 = values_averaged.x800(1:20,:);
        


        figure;
        subplot(5, 24, 17:24); imagesc(stopwalk);  caxis([-2 2]); title('stopwalk'); 
        subplot(5, 1, 2); imagesc(m_stop_400);  caxis([-2 2]); title('motorized stop, accel 400');
        subplot(5, 1, 3); imagesc(m_stop_800);  caxis([-2 2]); title('motorized stop, accel 800');
        subplot(5, 1, 4); imagesc(m_stop_ending_400);  caxis([-2 2]); title('motorized stop ending aligned, accel 400');
        subplot(5, 1, 5); imagesc(m_stop_ending_800);  caxis([-2 2]); title('motorized stop ending aligned, accel 800');
        sgtitle(['PCA scores individual mouse, ' strjoin(values(1:numel(values)/2), ', ')]);
        savefig([output_dir 'all_stops_together.fig']);
    end 
end 