% Create struct with parameters regarding MWF data processing.
% Parameters can be entered using <key>-<value> pairs as inputs to the
% mwf_params function. Parameters that are not specified are set to the
% devault value.
%
% INPUTS:
%   <key>-<value> pairs (see below)
%
% OUTPUTS: 
%   p        MWF parameter struct
%
% KEY - VALUE PAIRS
%   delay       number of time lags to include in MWF (positive integer or 0)
%   rank        decides how the rank for the MWF should be set
%               'full':     use full rank MWF (don't use GEVD)
%               'poseig':   use GEVD, only retain positive eigenvalues
%               'pct':      use GEVD, only retain x% of eigenvalues
%               'first':    use GEVD, only retain x eigenvalues
%   rankopt     additional rank options, required if rank is 'pct' or 'first'
%               'pct': specify the percentage of eigenvalues to keep (0-100)
%               'first': specify the number of eigenvalues to keep (positive integer)
%   mu          noiseweighting factor (default = 1)
%   train_len   length of training sequence in seconds (0 = don't use training set)
%   srate       EEG sample rate in Hz
% 
% EXAMPLES
%   p = mwf_params('delay', 5, 'rank', 'full')
%   creates settings for an MWF using 5 time lags and without GEVD
%
%   p = mwf_params('delay', 10, 'rank', 'poseig')
%   creates settings for an MWF using 10 time lags, using GEVD where only
%   positive eigenvalues are kept
%   
%   p = mwf_params('rank', 'pct', 'rankopt', 50)
%   creates settings for an MWF using GEVD where only 50% of eigenvalues is
%   kept. No time delays are used (default = 0).
%
%   p = mwf_params('train_len', 30, 'mu', 2)
%   creates settings for a noise-weighted MWF which will be trained on the
%   first 30 seconds of the provided data, with noise-weighting factor 2.
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function p = mwf_params(varargin)

% Set processing parameter defaults
p = struct(...
    'srate', 200, ...   % sampling rate
    'delay', 0, ...     % any integer >= 0
    'rank', 'full', ... % 'full', 'poseig', 'pct', 'first'
    'rankopt', 1, ...   % additional specifier if 'rank' is 'pct' or 'first'
    'mu', 1, ...        % any value [1 = default, >1 = noise weighted MWF]
    'train_len', 0);    % any value >= 0 [0 = no training, use full data]

p_names = fieldnames(p);

% Count arguments
nArgs = length(varargin);
if mod(nArgs,2) ~= 0
    error('mwf_params needs pairs of parameterName/parameterValue')
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
            validatestring(p.(p_names{i}), {'full','poseig','pct','first'}, mfilename, p_names{i});
        case 'rankopt'
            if strcmp(p.rank,'pct')
                validateattributes(p.(p_names{i}), {'numeric'}, {'positive','<=',100}, mfilename, p_names{i})
            elseif strcmp(p.rank,'first')
                validateattributes(p.(p_names{i}), {'numeric'}, {'positive','integer'}, mfilename, p_names{i})
            end
        case 'mu'
            validateattributes(p.(p_names{i}), {'numeric'}, {'real'}, mfilename, p_names{i})
        case 'train_len'
            validateattributes(p.(p_names{i}), {'numeric'}, {'nonnegative','real'}, mfilename, p_names{i})
    end
end

end

