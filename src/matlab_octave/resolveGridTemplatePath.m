function templatePath = resolveGridTemplatePath(grid_name)
% Resolve grid template folder, preferring v2 geometry/templates layout.

    assert(ischar(grid_name) || isstring(grid_name), ...
           'grid_name must be a character vector or string');

    grid_name = char(grid_name);
    baseDir = fileparts(mfilename('fullpath'));

    candidates = {
        fullfile(baseDir, 'geometry', 'templates', grid_name), ...
        fullfile(baseDir, 'grids', grid_name)
    };

    for i = 1:numel(candidates)
        if isfolder(candidates{i})
            templatePath = candidates{i};
            return;
        end
    end

    error('resolveGridTemplatePath:GridNotFound', ...
          'Grid template "%s" was not found in geometry/templates or grids', ...
          grid_name);
end