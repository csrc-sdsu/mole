function assert_gradient_close(actual, expected, tolerance)
% PURPOSE
% Require gradient results to match within an absolute tolerance.
%
% SYNTAX
% assert_gradient_close(actual, expected, tolerance)
%
% DESCRIPTION
% actual and expected must have equal dimensions. tolerance is a nonnegative
% scalar absolute tolerance applied to each element. Fails an assertion if
% dimensions differ or any absolute difference exceeds tolerance.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    assert(isequal(size(actual), size(expected)), 'Gradient result sizes differ.');
    difference = abs(actual(:) - expected(:));
    assert(all(difference <= tolerance), 'Gradient values exceed the absolute tolerance.');
end
