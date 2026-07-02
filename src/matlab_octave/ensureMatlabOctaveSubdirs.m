function ensureMatlabOctaveSubdirs()
% Ensure v2 subdirectories are available when only src/matlab_octave is on path.

    persistent didSetup;

    if isempty(didSetup) || ~didSetup
        baseDir = fileparts(mfilename('fullpath'));
        addpath(genpath(baseDir));
        didSetup = true;
    end
end