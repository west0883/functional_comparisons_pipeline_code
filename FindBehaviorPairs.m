% FindBehaviorPairs.m
% Sarah West
% 5/31/22

% From a periods_nametable table from Random Motorized Treadmill
% experiement, finds indices of behavior type pairs (behavior_indices) that are
% identical in all parameters except the parameter given by divideby. 
% Inputs:
% behaviors -- a cell array of strings that are the name of the
% behavior type/the "condition" in periods_nametable.
% divideby -- a string that holds the name of ONE field/table column found
% in periods_nametable. Is the parameter that you want pair divisions for.
% ignore -- A cell array of strings that lists fields/table columns found in 
% periods_nametable that are okay to be different in these behavior pairs
% (besides the parameter of interest given by divideby)

% For parameters with more than two possible values (ie speed), can be
% groups of data. 

function [behavior_indices] = FindBehaviorPairs(behaviors, divideby, ignore, periods_nametable)

    % Make a list of the column names you DO want to match.
    variable_names = periods_nametable.Properties.VariableNames; 

    % Remove the column names you DON'T want to match (condition is already
    % accounted for).
    all_ignores = [{'condition'} {'index'} {divideby} ignore];
    indices_to_remove = [];
    for donti = all_ignores
   
        indices_to_remove = [indices_to_remove; strcmp(variable_names, donti)];

    end
    matching_variables = variable_names;
    matching_variables(any(indices_to_remove,1)) = []; 

    % Make an empty cell for holding behavior_indices. (Is concatenated
    % across behavior periods).
    behavior_indices = cell(1, 2);

    % For each behavior condition,
    for behaviori = 1:numel(behaviors)
        behavior = behaviors{behaviori};

        % Make a holder table for all entries of periods_nametable for that
        % condition.
        holder_table = periods_nametable(string(periods_nametable.condition) == behavior, :);
        

        while size(holder_table, 1) > 0

            [behavior_indices, holder_table] = SubFindBehaviorPairs(behavior_indices, holder_table, matching_variables);

        end 

    end

    % Now that you have them in groups of matches, divide the behaviors
    % into sub-groups based on the divideby value. 

    % Find all possible values of the "divideby" to use. 
    divide_values = unique(periods_nametable.(divideby));
    
    % Skip the first row (is empty).
    for behaviori = 2:size(behavior_indices, 1)

        % For each possible value of the subdivide parameter.
        for subdividei = 1:numel(divide_values)




        end     
    end

end 

function [behavior_indices, holder_table] = SubFindBehaviorPairs(behavior_indices, holder_table, matching_variables)

      % Make the first row of holder_table its own table, remove from
      % holder_table.
      first_entry = holder_table(1, :);
      holder_table(1, :) = [];

      % Make a holder for potential matches with first_entry
      matches = holder_table; 

      % For each matching variable,
      for matchingi = 1:numel(matching_variables)
          matching_variable = matching_variables{matchingi};

          % Value from first entry
          value = first_entry.(matching_variable){1};
         
          % Check if value is a number or string:

          % Find matches that also match this variable.
          % If value is a string:
          if isstring(value)
            matches = matches(string(matches.(matching_variable)) == value, :); 

          % If value is a number:
          elseif isnumeric(value)
            matches = matches(cell2mat(matches.(matching_variable)) == value, :);           

          end 

      end 
      
      % Remove matches from holder_table.
      indices_to_remove = []; 
      for matchesi = 1:numel(matches.index)
            
         if holder_table{matchesi, 'index'} == matches{matchesi, 'index'}
            indices_to_remove = [indices_to_remove; matchesi];
         end

      end
      holder_table(indices_to_remove, :) = []; 

      % Put behaviors into useful place.
      sub_cell =  {[first_entry.index; matches.index] [first_entry; matches]};
      behavior_indices = [behavior_indices; sub_cell];
 
end 