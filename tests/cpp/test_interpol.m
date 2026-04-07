clear; clc; close all;
addpath("../../src/matlab_octave");

tol = 1e-10;

for k = 2:2:3

    m = 2 * k + 1;
    n = m + 1;
    o = n + 1;

    icfcpp = readmatrix("picf1D.csv");
    icncpp = readmatrix("picn1D.csv");
    ifccpp = readmatrix("pifc1D.csv");
    inccpp = readmatrix("pinc1D.csv");

    if ~all(icfcpp - interpolCentersToFacesD1DPeriodic(k, m) < tol, "all")
        disp("1-D, k = " + k + ", Periodic Centers to Faces: Pass")
    else
        disp("1-D, k = " + k + ", Periodic Centers to Faces: Fail")
    end

    if ~all(icncpp - interpolCentersToNodes1DPeriodic(k, m) < tol, "all")
        disp("1-D, k = " + k + ", Periodic Centers to Nodes: Pass")
    else
        disp("1-D, k = " + k + ", Periodic Centers to Nodes: Fail")
    end

    if ~all(ifccpp - interpolFacesToCentersG1DPeriodic(k, m) < tol, "all")
        disp("1-D, k = " + k + ", Periodic Faces to Centers: Pass")
    else
        disp("1-D, k = " + k + ", Periodic Faces to Centers: Fail")
    end

    if ~all(inccpp - interpolNodesToCenters1DPeriodic(k, m) < tol, "all")
        disp("1-D, k = " + k + ", Periodic Nodes to Centers: Pass")
    else
        disp("1-D, k = " + k + ", Periodic Nodes to Centers: Fail")
    end

    icfcpp = readmatrix("picf2D.csv");
    icncpp = readmatrix("picn2D.csv");
    ifccpp = readmatrix("pifc2D.csv");
    inccpp = readmatrix("pinc2D.csv");

    if all(abs(icfcpp - interpolCentersToFacesD2DPeriodic(k, m, n)) < tol, "all")
        disp("2-D, k = " + k + ", Periodic Centers to Faces: Pass")
    else
        disp("2-D, k = " + k + ", Periodic Centers to Faces: Fail")
    end

    if all(abs(icncpp - interpolCentersToNodes2DPeriodic(k, m, n)) < tol, "all")
        disp("2-D, k = " + k + ", Periodic Centers to Nodes: Pass")
    else
        disp("2-D, k = " + k + ", Periodic Centers to Nodes: Fail")
    end

    if all(abs(ifccpp - interpolFacesToCentersG2DPeriodic(k, m, n)) < tol, "all")
        disp("2-D, k = " + k + ", Periodic Faces to Centers: Pass")
    else
        disp("2-D, k = " + k + ", Periodic Faces to Centers: Fail")
    end

    if all(abs(inccpp - interpolNodesToCenters2DPeriodic(k, m, n)) < tol, "all")
        disp("2-D, k = " + k + ", Periodic Nodes to Centers: Pass")
    else
        disp("2-D, k = " + k + ", Periodic Nodes to Centers: Fail")
    end

    icfcpp = readmatrix("picf3D.csv");
    icncpp = readmatrix("picn3D.csv");
    ifccpp = readmatrix("pifc3D.csv");
    inccpp = readmatrix("pinc3D.csv");

    if all(abs(icfcpp - interpolCentersToFacesD3DPeriodic(k, m, n, o)) < tol, "all")
        disp("3-D, k = " + k + ", Periodic Centers to Faces: Pass")
    else
        disp("3-D, k = " + k + ", Periodic Centers to Faces: Fail")
    end

    if all(abs(icncpp - interpolCentersToNodes3DPeriodic(k, m, n, o)) < tol, "all")
        disp("3-D, k = " + k + ", Periodic Centers to Nodes: Pass")
    else
        disp("3-D, k = " + k + ", Periodic Centers to Nodes: Fail")
    end

    if all(abs(ifccpp - interpolFacesToCentersG3DPeriodic(k, m, n, o)) < tol, "all")
        disp("3-D, k = " + k + ", Periodic Faces to Centers: Pass")
    else
        disp("3-D, k = " + k + ", Periodic Faces to Centers: Fail")
    end

    if all(abs(inccpp - interpolNodesToCenters3DPeriodic(k, m, n, o)) < tol, "all")
        disp("3-D, k = " + k + ", Periodic Nodes to Centers: Pass")
    else
        disp("3-D, k = " + k + ", Periodic Nodes to Centers: Fail")
    end



    icfcpp = readmatrix("nicf1D.csv");
    icncpp = readmatrix("nicn1D.csv");
    ifccpp = readmatrix("nifc1D.csv");
    inccpp = readmatrix("ninc1D.csv");

    if all(abs(icfcpp - interpolCentersToFacesD1D(k, m)) < tol, "all")
        disp("1-D, k = " + k + ", Nonperiodic Centers to Faces: Pass")
    else
        disp("1-D, k = " + k + ", Nonperiodic Centers to Faces: Fail")
    end

    if all(abs(icncpp - interpolCentersToNodes1D(k, m)) < tol, "all")
        disp("1-D, k = " + k + ", Nonperiodic Centers to Nodes: Pass")
    else
        disp("1-D, k = " + k + ", Nonperiodic Centers to Nodes: Fail")
    end

    if all(abs(ifccpp - interpolFacesToCentersG1D(k, m)) < tol, "all")
        disp("1-D, k = " + k + ", Nonperiodic Faces to Centers: Pass")
    else
        disp("1-D, k = " + k + ", Nonperiodic Faces to Centers: Fail")
    end

    if all(abs(inccpp - interpolNodesToCenters1D(k, m)) < tol, "all")
        disp("1-D, k = " + k + ", Nonperiodic Nodes to Centers: Pass")
    else
        disp("1-D, k = " + k + ", Nonperiodic Nodes to Centers: Fail")
    end

    icfcpp = readmatrix("nicf2D.csv");
    icncpp = readmatrix("nicn2D.csv");
    ifccpp = readmatrix("nifc2D.csv");
    inccpp = readmatrix("ninc2D.csv");

    if all(abs(icfcpp - interpolCentersToFacesD2D(k, m, n)) < tol, "all")
        disp("2-D, k = " + k + ", Nonperiodic Centers to Faces: Pass")
    else
        disp("2-D, k = " + k + ", Nonperiodic Centers to Faces: Fail")
    end

    if all(abs(icncpp - interpolCentersToNodes2D(k, m, n)) < tol, "all")
        disp("2-D, k = " + k + ", Nonperiodic Centers to Nodes: Pass")
    else
        disp("2-D, k = " + k + ", Nonperiodic Centers to Nodes: Fail")
    end

    if all(abs(ifccpp - interpolFacesToCentersG2D(k, m, n)) < tol, "all")
        disp("2-D, k = " + k + ", Nonperiodic Faces to Centers: Pass")
    else
        disp("2-D, k = " + k + ", Nonperiodic Faces to Centers: Fail")
    end

    if all(abs(inccpp - interpolNodesToCenters2D(k, m, n)) < tol, "all")
        disp("2-D, k = " + k + ", Nonperiodic Nodes to Centers: Pass")
    else
        disp("2-D, k = " + k + ", Nonperiodic Nodes to Centers: Fail")
    end

    icfcpp = readmatrix("nicf3D.csv");
    icncpp = readmatrix("nicn3D.csv");
    ifccpp = readmatrix("nifc3D.csv");
    inccpp = readmatrix("ninc3D.csv");

    if all(abs(icfcpp - interpolCentersToFacesD3D(k, m, n, o)) < tol, "all")
        disp("3-D, k = " + k + ", Nonperiodic Centers to Faces: Pass")
    else
        disp("3-D, k = " + k + ", Nonperiodic Centers to Faces: Fail")
    end

    if all(abs(icncpp - interpolCentersToNodes3D(k, m, n, o)) < tol, "all")
        disp("3-D, k = " + k + ", Nonperiodic Centers to Nodes: Pass")
    else
        disp("3-D, k = " + k + ", Nonperiodic Centers to Nodes: Fail")
    end

    if all(abs(ifccpp - interpolFacesToCentersG3D(k, m, n, o)) < tol, "all")
        disp("3-D, k = " + k + ", Nonperiodic Faces to Centers: Pass")
    else
        disp("3-D, k = " + k + ", Nonperiodic Faces to Centers: Fail")
    end

    if all(abs(inccpp - interpolNodesToCenters3D(k, m, n, o)) < tol, "all")
        disp("3-D, k = " + k + ", Nonperiodic Nodes to Centers: Pass")
    else
        disp("3-D, k = " + k + ", Nonperiodic Nodes to Centers: Fail")
    end

end