%{
This are tests for our LIFO octave stack class
%}

classdef test_errors < matlab.unittest.TestCase
    properties
        TestError
    end
    methods(TestMethodSetup)
        #Initial stack setup with empty stack on each test case
        function createEmptyStack(testCase)
            testCase.TestError = MOLE_errors()
        end
    end
    methods(Test)

        function testMoleLogErrors(testCase):
            #Test for pushing onto stack
            testCase.verifyEqual(testCase.TestError.getNumErrors(),0)
            params = "numelem = 5 "
            testCase.TestError.log_error("MOLE_ERR_INVALID_ARRAY_SIZE", "array1D Construction", false, params)
            testCase.verifyEqual(testCase.TestError.numErrors, 1)
            params = "original numelem = 5, requested resize = "
            testCase.TestError.log_error("MOLE_ERR_FAILED_ARRAY_RESIZE", "array1D Resize", false, params)
            testCase.verifyEqual(testCase.TestError.numErrors, 2)
            
            params = "original numelem = 5, requested resize = "
            testCase.TestError.log_error("MOLE_ERR_INVALID_GRID_SPACING", "grid1D[construct]", params)
            
            testCase.verifyEqual(testCase.TestError.numErrors, 3)

        end

        function testMoleLogErrorOutput(testCase)
            params = "numelem = 5 ";
            output = evalc('testCase.TestError.log_error("MOLE_ERR_INVALID_ARRAY_SIZE", "array1D Construction", false, params);');
            expectedOutput = sprintf("========================================\nLogged MOLE Error\n========================================\nError: MOLE_ERR_INVALID_ARRAY_SIZE\nCode: 200\nParams: numelem = 5 \nLocations: array1D Construction\nMessage: Array dimensions need to be natural numbers >= 1\n");

            testCase.verifyEqual(output, expectedOutput);
            testCase.verifyEqual(testCase.TestError.getNumErrors(), 1);
        end

       function testErrorStopExecution(testCase):
            testCase.verifyEqual(testCase.TestError.getNumErrors(),0)
            params = "numelem = 5 ";
            testCase.verifyError(@() testCase.TestError.log_error("MOLE_ERR_INVALID_ARRAY_SIZE", "array1D Construction", true, params), 'Array dimensions need to be natural numbers >= 1');
            params = "original numelem = 5, requested resize = ";
            testCase.verifyError(@() testCase.TestError.log_error("MOLE_ERR_FAILED_ARRAY_RESIZE", "array1D Resize", true, params), 'Fail to resize array <array name>');
       end
       function testInvalidErrorNameType(testCase)
            output = evalc('testCase.TestError.log_error(200, "array1D Construction", false, "numelem = 5");');
            expectedOutput = sprintf("MOLE error name must be a character array\n");

            testCase.verifyEqual(output, expectedOutput);
            testCase.verifyEqual(testCase.TestError.getNumErrors(), 0);
        end

        function testUnknownErrorName(testCase)
            testCase.verifyError(@() testCase.TestError.log_error("MOLE_ERR_NOT_IN_MAP", "array1D Construction", false, "numelem = 5"), 'MOLE:UNKNOWN_ERROR_NAME');
            testCase.verifyEqual(testCase.TestError.getNumErrors(), 0);
        end

        function testInvalidLocationAndParamsTypes(testCase)
            locationOutput = evalc('testCase.TestError.log_error("MOLE_ERR_INVALID_ARRAY_SIZE", 25, false, "numelem = 5");');
            paramsOutput = evalc('testCase.TestError.log_error("MOLE_ERR_INVALID_ARRAY_SIZE", "array1D Construction", false, 25);');
            expectedOutput = sprintf("MOLE error location and params must be character arrays\n");

            testCase.verifyEqual(locationOutput, expectedOutput);
            testCase.verifyEqual(paramsOutput, expectedOutput);
            testCase.verifyEqual(testCase.TestError.getNumErrors(), 0);
        end

        function testInvalidAbortFlag(testCase)
            typeOutput = evalc('testCase.TestError.log_error("MOLE_ERR_INVALID_ARRAY_SIZE", "array1D Construction", 1, "numelem = 5");');
            sizeOutput = evalc('testCase.TestError.log_error("MOLE_ERR_INVALID_ARRAY_SIZE", "array1D Construction", [true false], "numelem = 5");');
            expectedOutput = sprintf("onErrorAbort must be true or false\n");

            testCase.verifyEqual(typeOutput, expectedOutput);
            testCase.verifyEqual(sizeOutput, expectedOutput);
            testCase.verifyEqual(testCase.TestError.getNumErrors(), 0);
        end

        function testDefaultInputs(testCase)
            output = evalc('testCase.TestError.log_error("MOLE_ERR_INVALID_ARRAY_SIZE", "array1D Construction");');
            expectedOutput = sprintf("========================================\nLogged MOLE Error\n========================================\nError: MOLE_ERR_INVALID_ARRAY_SIZE\nCode: 200\nParams: \nLocations: array1D Construction\nMessage: Array dimensions need to be natural numbers >= 1\n");

            testCase.verifyEqual(output, expectedOutput);
            testCase.verifyEqual(testCase.TestError.getNumErrors(), 1);
        end

        function testHaveErrors(testCase)
            testCase.verifyEqual(testCase.TestError.haveErrors(), false);
            evalc('testCase.TestError.log_error("MOLE_ERR_INVALID_ARRAY_SIZE", "array1D Construction", false, "numelem = 5");');
            testCase.verifyEqual(testCase.TestError.haveErrors(), true);
        end
end