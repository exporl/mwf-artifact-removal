% Checks if ICA or CCA components are cached for the given method, artifact
% type, subject and SNR. If they exist, return them. Is they don't exist,
% return an empty array.
%
% If there is an additional input for components, the function stores those
% components in the cache instead of checking for existance. Components
% that were already cached will be overwritten.

function [components] = method_cached_components(id, newcomponents)

% ensure right field order
id = orderfields(id); id = orderfields(id, [2, 1, 3, 4]);

subfields = fieldnames(id);
assert(isequal(subfields, {'method';'artifact';'name';'snr'}));

exist = 0;
L = load('method_cached_components.mat');
cached_components = L.cached_components;
if check_cache(cached_components, id)
    components = cached_components.(id.method).(id.artifact).(id.name).(id.snr);
    exist = true;
else
    components = [];
end

if nargin > 1
    if exist
        fprintf('Overwriting existing cached components... \n');
    end
    cached_components.(id.method).(id.artifact).(id.name).(id.snr) = newcomponents;
    components = newcomponents;
    save('method_cached_components.mat','cached_components');
end

end

function exists = check_cache(top, id)
% Recursive search for cached components satisfying the id. 
% The MATLAB function isfield() only checks the first struct level.

exists = 0;

subfields = fieldnames(id);
assert(isequal(subfields, {'method';'artifact';'name';'snr'}));

for j = 1:numel(subfields)
    f = fieldnames(top); if(isempty(f)); return; end
    for i=1:length(f)
        if(strcmp(f{i},id.(subfields{j})))
            top = top.(f{i});
            if j == numel(subfields); exists = 1; end
            break;
        elseif i == length(f)
            return
        else
            continue;
        end
    end
end

end
