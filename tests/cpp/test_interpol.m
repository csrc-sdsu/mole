clear; clc; close all;
addpath("../../src/matlab_octave");

tol = 1e-10;

for k = 2:2:8

    m = 2 * k + 1;
    n = m + 1;
    o = n + 1;

    icfcpp = readmatrix("picf1Dk" + k + ".csv");
    icncpp = readmatrix("picn1Dk" + k + ".csv");
    ifccpp = readmatrix("pifc1Dk" + k + ".csv");
    inccpp = readmatrix("pinc1Dk" + k + ".csv");

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

    icfcpp = readmatrix("picf2Dk" + k + ".csv");
    icncpp = readmatrix("picn2Dk" + k + ".csv");
    ifccpp = readmatrix("pifc2Dk" + k + ".csv");
    inccpp = readmatrix("pinc2Dk" + k + ".csv");

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

    icfcpp = readmatrix("picf3Dk" + k + ".csv");
    icncpp = readmatrix("picn3Dk" + k + ".csv");
    ifccpp = readmatrix("pifc3Dk" + k + ".csv");
    inccpp = readmatrix("pinc3Dk" + k + ".csv");

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



    icfcpp = readmatrix("nicf1Dk" + k + ".csv");
    icncpp = readmatrix("nicn1Dk" + k + ".csv");
    ifccpp = readmatrix("nifc1Dk" + k + ".csv");
    inccpp = readmatrix("ninc1Dk" + k + ".csv");

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

    icfcpp = readmatrix("nicf2Dk" + k + ".csv");
    icncpp = readmatrix("nicn2Dk" + k + ".csv");
    ifccpp = readmatrix("nifc2Dk" + k + ".csv");
    inccpp = readmatrix("ninc2Dk" + k + ".csv");

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

    icfcpp = readmatrix("nicf3Dk" + k + ".csv");
    icncpp = readmatrix("nicn3Dk" + k + ".csv");
    ifccpp = readmatrix("nifc3Dk" + k + ".csv");
    inccpp = readmatrix("ninc3Dk" + k + ".csv");

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