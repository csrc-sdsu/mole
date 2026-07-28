// Tests for MOLE_grids.h/.cpp: grid1D, grid2D, grid3D, makeGrid,
// isValidGrid, validSpacing, generateNodalPts/generateCenterPts.
#include <gtest/gtest.h>
#include "MOLE_grids.h"
#include <cmath>

// ===================================================================
// validSpacing
// ===================================================================

TEST(ValidSpacing, PositiveFiniteIsValid) {
    EXPECT_TRUE(validSpacing(1.0));
    EXPECT_TRUE(validSpacing(0.001));
}

TEST(ValidSpacing, ZeroIsInvalid) {
    EXPECT_FALSE(validSpacing(0.0));
}

TEST(ValidSpacing, NegativeIsInvalid) {
    EXPECT_FALSE(validSpacing(-1.0));
}

TEST(ValidSpacing, NaNIsInvalid) {
    EXPECT_FALSE(validSpacing(std::nan("")));
}

TEST(ValidSpacing, InfIsInvalid) {
    EXPECT_FALSE(validSpacing(std::numeric_limits<Real>::infinity()));
}

// ===================================================================
// generateNodalPts / generateCenterPts
// ===================================================================

TEST(GenerateNodalPts, ProducesEvenlySpacedPoints) {
    Array1D xn(5); // npts=4 -> 5 nodal points
    generateNodalPts(4, 2.0, xn);
    for (size_t i = 0; i <= 4; ++i)
        EXPECT_DOUBLE_EQ(xn[i], i * 2.0);
}

TEST(GenerateCenterPts, ProducesCellCenteredPoints) {
    // centers layout: [0]=0 (untouched/default), [1..npts]=(i-0.5)*dx,
    // [npts+1]=npts*dx
    Array1D xc(4, 0.0); // npts=2 -> size m+2 = 4
    generateCenterPts(2, 2.0, xc);
    EXPECT_DOUBLE_EQ(xc[0], 0.0);
    EXPECT_DOUBLE_EQ(xc[1], 0.5 * 2.0);
    EXPECT_DOUBLE_EQ(xc[2], 1.5 * 2.0);
    EXPECT_DOUBLE_EQ(xc[3], 2 * 2.0);
}

// ===================================================================
// grid1D
// ===================================================================

TEST(Grid1D, UniformValidGridValidates) {
    gridParams1D p;
    p.topology = 'u'; p.m = 4; p.dx = 1.5;
    grid1D g(p);
    EXPECT_TRUE(g.isValidatedGrid());
    EXPECT_FALSE(g.hasGridErrors());
    EXPECT_EQ(g.grid.nodes_X.size(), 5u);   // m+1
    EXPECT_EQ(g.grid.centers_X.size(), 6u); // m+2
}

TEST(Grid1D, ZeroCellCountIsInvalid) {
    gridParams1D p;
    p.topology = 'u'; p.m = 0; p.dx = 1.0;
    grid1D g(p);
    EXPECT_FALSE(g.isValidatedGrid());
    EXPECT_TRUE(g.hasGridErrors());
}

TEST(Grid1D, NonPositiveSpacingIsInvalid) {
    gridParams1D p;
    p.topology = 'u'; p.m = 4; p.dx = -1.0;
    grid1D g(p);
    EXPECT_FALSE(g.isValidatedGrid());
}

TEST(Grid1D, CurvilinearIsAlwaysInvalidIn1D) {
    // 1D curvilinear grids are fundamentally undefined per validGrid()
    gridParams1D p;
    p.topology = 'c'; p.m = 4; p.dx = 1.0;
    grid1D g(p);
    EXPECT_FALSE(g.isValidatedGrid());
}

TEST(Grid1D, NonuniformWithoutNodesIsInvalid) {
    gridParams1D p;
    p.topology = 'n'; p.m = 4;
    grid1D g(p);
    EXPECT_FALSE(g.isValidatedGrid());
}

TEST(Grid1D, NonuniformWithNodesIsValid) {
    gridParams1D p;
    p.topology = 'n'; p.m = 3;
    p.nodes_X = {0.0, 1.0, 3.0, 6.0};  // arbitrary strictly-monotone
    grid1D g(p);
    EXPECT_TRUE(g.isValidatedGrid());
}

TEST(Grid1D, InvalidTopologyCharIsRejected) {
    gridParams1D p;
    p.topology = 'z'; p.m = 4; p.dx = 1.0;
    grid1D g(p);
    EXPECT_FALSE(g.isValidatedGrid());
}

TEST(Grid1D, PeriodicFlagIsPreserved) {
    gridParams1D p;
    p.topology = 'u'; p.m = 4; p.dx = 1.0; p.bc_isPeriodic = true;
    grid1D g(p);
    EXPECT_TRUE(g.grid.bc_isPeriodic);
}

TEST(Grid1D, ConstructorWithInerrsAccumulatesPriorErrors) {
    stack<MOLE_Errors> priorErrs;
    MOLEerr_log(priorErrs, MOLE_ERR_INVALID_GRID_DIM, "somewhere", "x");
    gridParams1D p;
    p.topology = 'u'; p.m = 4; p.dx = 1.0;
    grid1D g(p, priorErrs);
    // the pre-existing error must show up in the constructed grid's log
    EXPECT_TRUE(g.hasGridErrors());
}

// ===================================================================
// grid2D
// ===================================================================

TEST(Grid2D, UniformValidGridValidates) {
    gridParams2D p;
    p.topology = 'u'; p.m = 3; p.n = 2; p.dx = 1.0; p.dy = 2.0;
    grid2D g(p);
    EXPECT_TRUE(g.isValidatedGrid());
    EXPECT_FALSE(g.hasGridErrors());
    EXPECT_EQ(g.grid.nodes_X.rows(), 4u);   // m+1
    EXPECT_EQ(g.grid.nodes_X.cols(), 3u);   // n+1
    EXPECT_EQ(g.grid.centers_X.rows(), 5u); // m+2
    EXPECT_EQ(g.grid.centers_X.cols(), 4u); // n+2
    EXPECT_EQ(g.grid.faces_u_X.rows(), 4u); // m+1
    EXPECT_EQ(g.grid.faces_u_X.cols(), 2u); // n
    EXPECT_EQ(g.grid.faces_v_X.rows(), 3u); // m
    EXPECT_EQ(g.grid.faces_v_X.cols(), 3u); // n+1
}

TEST(Grid2D, ZeroCellCountInEitherDimIsInvalid) {
    gridParams2D p1;
    p1.topology = 'u'; p1.m = 0; p1.n = 2; p1.dx = 1.0; p1.dy = 1.0;
    grid2D g1(p1);
    EXPECT_FALSE(g1.isValidatedGrid());

    gridParams2D p2;
    p2.topology = 'u'; p2.m = 2; p2.n = 0; p2.dx = 1.0; p2.dy = 1.0;
    grid2D g2(p2);
    EXPECT_FALSE(g2.isValidatedGrid());
}

TEST(Grid2D, BothPeriodicFlagsPreservedIndependently) {
    gridParams2D p;
    p.topology = 'u'; p.m = 2; p.n = 2; p.dx = 1.0; p.dy = 1.0;
    p.bc_isPeriodic[0] = true;
    p.bc_isPeriodic[1] = false;
    grid2D g(p);
    EXPECT_TRUE(g.grid.bc_isPeriodic[0]);
    EXPECT_FALSE(g.grid.bc_isPeriodic[1]);
}

TEST(Grid2D, CurvilinearWithoutNodesIsInvalid) {
    gridParams2D p;
    p.topology = 'c'; p.m = 2; p.n = 2;
    grid2D g(p);
    EXPECT_FALSE(g.isValidatedGrid());
}

TEST(Grid2D, UserProvidedMismatchedNodeSizeIsRejected) {
    gridParams2D p;
    p.topology = 'u'; p.m = 2; p.n = 2; p.dx = 1.0; p.dy = 1.0;
    // wrong shape on purpose: should be (m+1) x (n+1) = 3x3
    p.nodes_X = Array2D(2, 2, 0.0);
    grid2D g(p);
    EXPECT_FALSE(g.isValidatedGrid());
    EXPECT_TRUE(g.hasGridErrors());
}

// ===================================================================
// grid3D -- regression coverage for the constructor bug that used to
// silently drop grid.o, grid.dz, all *_Z arrays, faces_v_Z,
// faces_w_X/Y/Z, and bc_isPeriodic[2].
// ===================================================================

TEST(Grid3D, UniformValidGridValidates) {
    gridParams3D p;
    p.topology = 'u';
    p.m = 3; p.n = 2; p.o = 4;
    p.dx = 1.0; p.dy = 2.0; p.dz = 0.5;
    grid3D g(p);
    EXPECT_TRUE(g.isValidatedGrid());
    EXPECT_FALSE(g.hasGridErrors());
}

TEST(Grid3D, ConstructorCopiesAllScalarFields) {
    // Direct regression test for the fixed grid3D constructor bug:
    // 'o' and 'dz' must survive construction, not just m/n/dx/dy.
    gridParams3D p;
    p.topology = 'u';
    p.m = 3; p.n = 2; p.o = 5;
    p.dx = 1.0; p.dy = 2.0; p.dz = 0.75;
    grid3D g(p);
    EXPECT_EQ(g.grid.o, 5u);
    EXPECT_DOUBLE_EQ(g.grid.dz, 0.75);
}

TEST(Grid3D, ConstructorCopiesAllPeriodicFlags) {
    gridParams3D p;
    p.topology = 'u';
    p.m = 2; p.n = 2; p.o = 2;
    p.dx = 1.0; p.dy = 1.0; p.dz = 1.0;
    p.bc_isPeriodic[0] = true;
    p.bc_isPeriodic[1] = false;
    p.bc_isPeriodic[2] = true;
    grid3D g(p);
    EXPECT_TRUE(g.grid.bc_isPeriodic[0]);
    EXPECT_FALSE(g.grid.bc_isPeriodic[1]);
    EXPECT_TRUE(g.grid.bc_isPeriodic[2]);  // the one that used to be dropped
}

TEST(Grid3D, AllZCoordinateArraysArePopulated) {
    gridParams3D p;
    p.topology = 'u';
    p.m = 2; p.n = 3; p.o = 4;
    p.dx = 1.0; p.dy = 1.0; p.dz = 1.0;
    grid3D g(p);
    ASSERT_TRUE(g.isValidatedGrid());

    EXPECT_EQ(g.grid.nodes_Z.dim1(), 3u);   // m+1
    EXPECT_EQ(g.grid.nodes_Z.dim2(), 4u);   // n+1
    EXPECT_EQ(g.grid.nodes_Z.dim3(), 5u);   // o+1
    EXPECT_FALSE(g.grid.nodes_Z.empty());

    EXPECT_EQ(g.grid.centers_Z.dim1(), 4u); // m+2
    EXPECT_EQ(g.grid.centers_Z.dim2(), 5u); // n+2
    EXPECT_EQ(g.grid.centers_Z.dim3(), 6u); // o+2
    EXPECT_FALSE(g.grid.centers_Z.empty());
}

TEST(Grid3D, AllFaceArraysArePopulatedWithCorrectShapes) {
    gridParams3D p;
    p.topology = 'u';
    p.m = 2; p.n = 3; p.o = 4;
    p.dx = 1.0; p.dy = 1.0; p.dz = 1.0;
    grid3D g(p);
    ASSERT_TRUE(g.isValidatedGrid());

    // faces_u_*: (m+1) x n x o
    EXPECT_EQ(g.grid.faces_u_X.dim1(), 3u);
    EXPECT_EQ(g.grid.faces_u_X.dim2(), 3u);
    EXPECT_EQ(g.grid.faces_u_X.dim3(), 4u);
    EXPECT_FALSE(g.grid.faces_u_Y.empty());
    EXPECT_FALSE(g.grid.faces_u_Z.empty());  // used to be dropped entirely

    // faces_v_*: m x (n+1) x o
    EXPECT_EQ(g.grid.faces_v_Y.dim1(), 2u);
    EXPECT_EQ(g.grid.faces_v_Y.dim2(), 4u);
    EXPECT_EQ(g.grid.faces_v_Y.dim3(), 4u);
    EXPECT_FALSE(g.grid.faces_v_X.empty());
    EXPECT_FALSE(g.grid.faces_v_Z.empty());  // used to be dropped entirely

    // faces_w_*: m x n x (o+1)  -- this whole trio used to be dropped
    EXPECT_EQ(g.grid.faces_w_Z.dim1(), 2u);
    EXPECT_EQ(g.grid.faces_w_Z.dim2(), 3u);
    EXPECT_EQ(g.grid.faces_w_Z.dim3(), 5u);
    EXPECT_FALSE(g.grid.faces_w_X.empty());
    EXPECT_FALSE(g.grid.faces_w_Y.empty());
    EXPECT_FALSE(g.grid.faces_w_Z.empty());
}

TEST(Grid3D, ConstructorWithInerrsAccumulatesPriorErrorsAndKeepsFields) {
    stack<MOLE_Errors> priorErrs;
    MOLEerr_log(priorErrs, MOLE_ERR_INVALID_GRID_DIM, "somewhere", "x");
    gridParams3D p;
    p.topology = 'u';
    p.m = 2; p.n = 2; p.o = 3;
    p.dx = 1.0; p.dy = 1.0; p.dz = 2.0;
    grid3D g(p, priorErrs);
    EXPECT_TRUE(g.hasGridErrors());
    // the second constructor must copy fields exactly like the first
    EXPECT_EQ(g.grid.o, 3u);
    EXPECT_DOUBLE_EQ(g.grid.dz, 2.0);
}

TEST(Grid3D, ZeroCellCountInAnyDimIsInvalid) {
    gridParams3D p;
    p.topology = 'u'; p.m = 0; p.n = 2; p.o = 2;
    p.dx = 1.0; p.dy = 1.0; p.dz = 1.0;
    grid3D g(p);
    EXPECT_FALSE(g.isValidatedGrid());
}

TEST(Grid3D, NonPositiveDzIsInvalid) {
    gridParams3D p;
    p.topology = 'u'; p.m = 2; p.n = 2; p.o = 2;
    p.dx = 1.0; p.dy = 1.0; p.dz = 0.0;  // dz invalid, dx/dy fine
    grid3D g(p);
    EXPECT_FALSE(g.isValidatedGrid());
}

TEST(Grid3D, CurvilinearRequiresAllThreeNodeArrays) {
    gridParams3D p;
    p.topology = 'c'; p.m = 2; p.n = 2; p.o = 2;
    // only nodes_X provided, nodes_Y/nodes_Z missing -> still invalid
    p.nodes_X = Array3D(3, 3, 3, 0.0);
    grid3D g(p);
    EXPECT_FALSE(g.isValidatedGrid());
}

// ===================================================================
// makeGrid factory + isValidGrid dispatch
// (regression test for the lambda-capture-by-reference fix and the
//  grid3Dp -> grid3D typo fix)
// ===================================================================

TEST(MakeGrid, ProducesGrid1DFromVariant) {
    gridParams1D p;
    p.topology = 'u'; p.m = 3; p.dx = 1.0;
    stack<MOLE_Errors> errs;
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    ASSERT_TRUE(std::holds_alternative<grid1D>(g));
    EXPECT_TRUE(isValidGrid(g));
}

TEST(MakeGrid, ProducesGrid2DFromVariant) {
    gridParams2D p;
    p.topology = 'u'; p.m = 2; p.n = 2; p.dx = 1.0; p.dy = 1.0;
    stack<MOLE_Errors> errs;
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    ASSERT_TRUE(std::holds_alternative<grid2D>(g));
    EXPECT_TRUE(isValidGrid(g));
}

TEST(MakeGrid, ProducesGrid3DFromVariantWithCorrectType) {
    // Regression test for the 'grid3Dp' typo: makeGrid must actually
    // return a grid3D, not fail to compile or return the wrong type.
    gridParams3D p;
    p.topology = 'u'; p.m = 2; p.n = 2; p.o = 2;
    p.dx = 1.0; p.dy = 1.0; p.dz = 1.0;
    stack<MOLE_Errors> errs;
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    ASSERT_TRUE(std::holds_alternative<grid3D>(g));
    EXPECT_TRUE(isValidGrid(g));
    EXPECT_EQ(std::get<grid3D>(g).grid.o, 2u);
}

TEST(MakeGrid, PropagatesPriorErrorsThroughVariant) {
    // Regression test for the lambda capture fix: errs must actually
    // be forwarded into the constructed grid, not silently dropped
    // (which previously wouldn't even compile).
    stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM, "prior", "");
    gridParams1D p;
    p.topology = 'u'; p.m = 2; p.dx = 1.0;
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    ASSERT_TRUE(std::holds_alternative<grid1D>(g));
    EXPECT_TRUE(std::get<grid1D>(g).hasGridErrors());
}

TEST(MakeGrid, InvalidParamsProducesInvalidGrid) {
    gridParams2D p;
    p.topology = 'u'; p.m = 0; p.n = 2; p.dx = 1.0; p.dy = 1.0;
    stack<MOLE_Errors> errs;
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    EXPECT_FALSE(isValidGrid(g));
}
