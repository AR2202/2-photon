function result = parcellfun(func, c,varargin)
% Parallel version of cellfun that uses parfor inside
%check if parallel computing toolbox is installed
%this only works for Matlab> 2022a

%if canUseParallelPool
p = inputParser;
addParameter(p, 'UniformOutput', 1, @isscalar);
parse(p, varargin{:});
result = cell(size(c));
parfor i = 1:numel(c)
    result{i} = func(c{i});
end
if p.Results.UniformOutput % uniform
    result = cell2mat(result);
end
%else
%    result = cellfun(func, c, varargin);
%end