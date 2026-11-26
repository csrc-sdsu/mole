function write_mole_junit(report, filename)
% PURPOSE
% Write portable MOLE test results as UTF-8 JUnit XML.
%
% SYNTAX
% write_mole_junit(report, filename)
%
% DESCRIPTION
% report is the structure returned by run_mole_tests. filename is a nonempty
% character vector, relative to the working directory or an absolute path.
% Creates missing parent directories and replaces an existing report.
% Each result becomes one testcase with its name, duration, and diagnostics.
% Serializes existing results without executing tests or measuring coverage.
% Raises MOLETests:ReportWrite if the destination cannot be written.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    if ~ischar(filename) || isempty(filename) || ~isrow(filename)
        error('MOLETests:InvalidInput', 'filename must be a nonempty character vector.');
    end
    parent = fileparts(filename);
    if ~isempty(parent) && ~isfolder(parent)
        [ok, message] = mkdir(parent);
        if ~ok
            error('MOLETests:ReportWrite', 'Cannot create %s: %s', parent, message);
        end
    end
    [fid, message] = fopen(filename, 'w', 'n', 'UTF-8');
    if fid < 0
        error('MOLETests:ReportWrite', 'Cannot open %s: %s', filename, message);
    end
    try
        results = report.results;
        total = numel(results);
        failures = sum(~[results.passed]);
        duration = sum([results.duration]);
        fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n');
        fprintf(fid, ['<testsuite name="MOLE" tests="%d" failures="%d" ' ...
                      'errors="0" skipped="0" time="%.9f">\n'], ...
                      total, failures, duration);
        for index = 1:total
            result = results(index);
            fprintf(fid, '  <testcase classname="MOLE" name="%s" time="%.9f"', ...
                    localXml(result.name), result.duration);
            if result.passed
                fprintf(fid, '/>\n');
            else
                fprintf(fid, '>\n    <failure type="%s" message="%s">%s</failure>\n', ...
                        localXml(result.identifier), localXml(result.message), ...
                        localXml(result.message));
                fprintf(fid, '  </testcase>\n');
            end
        end
        fprintf(fid, '</testsuite>\n');
        [message, writeError] = ferror(fid);
    catch err
        fclose(fid);
        rethrow(err);
    end
    closeStatus = fclose(fid);
    if writeError ~= 0 || closeStatus ~= 0
        error('MOLETests:ReportWrite', 'Cannot finish %s: %s', filename, message);
    end
end

function value = localXml(value)
    % Remove forbidden control characters; escape markup before whitespace.
    codes = double(value);
    value(codes < 32 & codes ~= 9 & codes ~= 10 & codes ~= 13) = [];
    value = strrep(value, '&', '&amp;');
    value = strrep(value, '<', '&lt;');
    value = strrep(value, '>', '&gt;');
    value = strrep(value, '"', '&quot;');
    value = strrep(value, '''', '&apos;');
    value = strrep(value, char(9), '&#9;');
    value = strrep(value, char(10), '&#10;');
    value = strrep(value, char(13), '&#13;');
end
