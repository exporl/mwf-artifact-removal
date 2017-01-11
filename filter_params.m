% Create struct with parameters for processing data with MWF. 
% Non-specified parameters are set to a default value. Inputs must be given
% as name/value pairs, e.g. 
% 
%   p = filter_params('delay', 5, 'rank', 'full')

function p = filter_params(varargin)

% Set processing parameter defaults
p = struct(...
    'srate', 200, ...   % sampling rate
    'delay', 0, ...     % any integer >= 0
    'rank', 'full', ... % 'full', 'poseig'
    'mu', 1, ...        % any value [1 = default, >1 = noise weighted MWF]
    'train_len', 0);    % any value >= 0 [0 = no training, use full data]

p_names = fieldnames(p);

% Count arguments
nArgs = length(varargin);
if mod(nArgs,2) ~= 0
    error('filter_params needs pairs of parameterName/parameterValue')
end

for pair = reshape(varargin,2,[]) % one pair is {parameterName; parameterValue}
    input_name = lower(pair{1});
    
    if any(strcmp(input_name, p_names))
        % Overwrite default value with input value
        p.(input_name) = pair{2};
    else
        error('%s is not a recognized parameter name', input_name)
    end
end

% Test for valid parameters settings
for i = 1:numel(p_names)
    switch p_names{i}
        case 'srate'
            validateattributes(p.(p_names{i}), {'numeric'}, {'integer','nonnegative'}, mfilename, p_names{i})
        case 'delay'
            validateattributes(p.(p_names{i}), {'numeric'}, {'integer','nonnegative'}, mfilename, p_names{i})
        case 'rank'
            validateattributes(p.(p_names{i}), {'char'}, {'nonempty'}, mfilename, p_names{i})
            validatestring(p.(p_names{i}), {'full','poseig'}, mfilename, p_names{i});
        case 'mu'
            validateattributes(p.(p_names{i}), {'numeric'}, {'real'}, mfilename, p_names{i})
        case 'train_len'
            validateattributes(p.(p_names{i}), {'numeric'}, {'nonnegative','real'}, mfilename, p_names{i})
    end
end

end

