'''
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
'''

from .BoundaryCondition import BoundaryCondition

class RobinBoundaryCondition(BoundaryCondition):
    def apply(self) -> None:
        pass