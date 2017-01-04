% Create struct with parameters for processing data with MWF. 
% Non-specified parameters are set to a default value. Inputs must be given
% as name/value pairs, e.g. 
% 
%   p = filter_params('delay', 5, 'rank', 'full')

function p = filter_params(varargin)

% Set processing parameter defaults
p = struct(...
    'delay', 0, ...     % any integer >= 0
    'rank', 'full', ... % 'full', 'poseig'
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
if ~(mod(p.delay,1) == 0 && p.delay >= 0 && isnumeric(p.delay))
    parameter_invalid_error(p, 'delay')
    
elseif ~(any(strcmp(p.rank, {'full','poseig'})) && ischar(p.rank))
    parameter_invalid_error(p, 'rank')
    
elseif ~(p.train_len >= 0 && isnumeric(p.train_len)) 
    parameter_invalid_error(p, 'train_len')
    
end

end

function parameter_invalid_error(p, field)
    error('''%s'' is not a valid value for field ''%s''', num2str(p.(field)), field)
end
