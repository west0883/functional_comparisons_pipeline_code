% FindMotorizedBehaviorIndices.m
% Sarah West
% 5/16/22

% Function that finds the indices of behaviors listed in
% periods_nametable.mat, which was created in motorized treadmill behavior pipeline code.
% Can divide by any of the (name) columns in periods_nametable.mat.
% Input:
% periods -- a cell array of strings of the behavior types (the
% 'conidition' in periods_nametable) you want to look at.

function [behavior_indices] = FindMotorizedBehaviorIndices(behaviors, divideby, periods_nametable)

    % Make an empty indices strucutre. 
   % behavior_indices = cell(numel(behaviors),1);

    % For each behavior
    for behaviori = 1:numel(behaviors)

        behavior = behaviors{behaviori};

        % Add to behavior_indices structure
        behavior_indices(behaviori).name = behavior; 

        % Make a holder table.
        behavior_indices_1 = cell(1,2);
        behavior_indices_1(1) =  {periods_nametable(string(periods_nametable.condition) == behavior, :)}; 
        
        % For each division type, iteratively find only behaviors that fit
        % the division criteria.
        for divideri = 1:numel(divideby)
          
            % Run sub function iteratively.
            behavior_indices_2 = SubFindBehaviorIndices(divideri,divideby, behavior_indices_1); 
            behavior_indices_1 = behavior_indices_2;

        end

        behavior_indices(behaviori).tables = behavior_indices_1(:, 1);

        for j = 1:numel(divideby)
            divider = divideby{j};
            for i = 1:size(behavior_indices_1,1)
                
                value = behavior_indices(behaviori).tables{i}.(divider){1};
                indices = behavior_indices_1{i,2};
                behavior_indices = setfield(behavior_indices, {behaviori}, 'indices', {i}, 'indices', indices);
                behavior_indices = setfield(behavior_indices, {behaviori}, 'indices', {i}, divider, value );
            end
        end
       
    end
end

function [behavior_indices_2] = SubFindBehaviorIndices(divideri, divideby, behavior_indices_1)
   
    behavior_indices_2 = {}; 
    divider = divideby{divideri}; 
    % For each entry to behavior_indices so far 

        for higheri = 1:size(behavior_indices_1,1)
            
            % Get a new table of just the relevent cell of
            % behavior_indices_1
            holder = behavior_indices_1{higheri, 1};
           

            % Find all the values that could match. 
            division_values = unique(holder.(divider)); 
            
             % For each division value, 
            for valuei = 1:numel(division_values)

                   % Get a new small table.
                   g = holder(string(holder.(divider)) == division_values{valuei}, :);
                   indices = cellfun(@num2str, num2cell(g.index), 'UniformOutput', false); 

                   % Add it to list of tables.
                   behavior_indices_2 = [behavior_indices_2; {g} {indices} ]; % {divider, division_values{divideri}}

            end
            
        end 
    % end
end 

