function [passed, total, testFunctions] = test_junit_reporting(runTests)
% PURPOSE
% Test JUnit serialization of portable MOLE test results.
%
% SYNTAX
% test_junit_reporting()
% [~, total, testFunctions] = test_junit_reporting(false)
%
% DESCRIPTION
% Checks case counts, diagnostics, XML escaping, and file destinations.
% Uses temporary files and does not run the discovered suites recursively.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    if nargin < 1
        runTests = true;
    elseif ~islogical(runTests) || ~isscalar(runTests)
        error('MOLETests:InvalidInput', 'runTests must be a logical scalar.');
    end
    testFunctions = {@testPassingCases, @testFailureDiagnostics, ...
        @testControlCharacters, @testEmptyReport, ...
        @testNestedDestination, @testUnwritableDestination};
    total = numel(testFunctions);
    passed = 0;
    if ~runTests
        return;
    end
    addpath(fileparts(fileparts(mfilename('fullpath'))));
    for index = 1:total
        currentTest = testFunctions{index};
        try
            currentTest();
            passed = passed + 1;
            fprintf('%s: passed\n', func2str(currentTest));
        catch err
            fprintf('%s: failed [%s]\n%s\n', ...
                    func2str(currentTest), err.identifier, err.message);
        end
    end
    fprintf('Passed %d of %d tests.\n', passed, total);
    if nargout == 0 && passed ~= total
        error('MOLETests:Failed', '%d of %d tests failed.', total - passed, total);
    end
end

function testPassingCases()
    [directory, cleanup] = temporary_directory();
    report = sample_report();
    report.results(2) = report.results;
    report.results(2).name = 'suite_second';
    filename = fullfile(directory, 'results.xml');
    write_mole_junit(report, filename);
    output = fileread(filename);
    assert(~isempty(strfind(output, 'tests="2" failures="0"')));
    assert(~isempty(strfind(output, 'time="0.250000000"')));
    assert(numel(strfind(output, '<testcase ')) == 2);
    assert(isempty(strfind(output, '<failure ')));
end

function testFailureDiagnostics()
    [directory, cleanup] = temporary_directory();
    report = sample_report();
    report.results.passed = false;
    report.results.name = 'suite_<case>&"';
    report.results.identifier = 'MOLE:EXPECTED';
    report.results.message = 'Expected <x> & "y"; received ''z'' ]]>';
    filename = fullfile(directory, 'results.xml');
    write_mole_junit(report, filename);
    output = fileread(filename);
    assert(~isempty(strfind(output, 'tests="1" failures="1"')));
    assert(~isempty(strfind(output, 'suite_&lt;case&gt;&amp;&quot;')));
    assert(~isempty(strfind(output, 'type="MOLE:EXPECTED"')));
    assert(~isempty(strfind(output, '&lt;x&gt; &amp; &quot;y&quot;')));
    assert(~isempty(strfind(output, '&apos;z&apos; ]]&gt;')));
end

function testControlCharacters()
    [directory, cleanup] = temporary_directory();
    report = sample_report();
    report.results.passed = false;
    report.results.message = ['first' char(10) 'second' char(9) char(13) char(1)];
    filename = fullfile(directory, 'results.xml');
    write_mole_junit(report, filename);
    output = fileread(filename);
    assert(~isempty(strfind(output, 'first&#10;second&#9;&#13;')));
    assert(isempty(strfind(output, char(1))));
end

function testEmptyReport()
    [directory, cleanup] = temporary_directory();
    report = sample_report();
    report.results = report.results([]);
    filename = fullfile(directory, 'results.xml');
    write_mole_junit(report, filename);
    output = fileread(filename);
    assert(~isempty(strfind(output, 'tests="0" failures="0"')));
    assert(isempty(strfind(output, '<testcase ')));
end

function testNestedDestination()
    [directory, cleanup] = temporary_directory();
    filename = fullfile(directory, 'nested', 'reports', 'results.xml');
    write_mole_junit(sample_report(), filename);
    assert(isfile(filename));
    write_mole_junit(sample_report(), filename);
    assert(numel(strfind(fileread(filename), '<?xml ')) == 1);
end

function testUnwritableDestination()
    [directory, cleanup] = temporary_directory();
    caught = false;
    try
        write_mole_junit(sample_report(), directory);
    catch err
        caught = true;
        assert(strcmp(err.identifier, 'MOLETests:ReportWrite'));
    end
    assert(caught, 'A directory cannot be used as the report file.');
end

function report = sample_report()
    report.results = struct('name', 'suite_first', 'passed', true, ...
        'duration', .125, 'identifier', '', 'message', '');
end

function [directory, cleanup] = temporary_directory()
    directory = tempname();
    mkdir(directory);
    cleanup = onCleanup(@() rmdir(directory, 's'));
end
