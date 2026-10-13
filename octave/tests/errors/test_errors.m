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

        function testMoleErrorLog(testCase):
            #Test for pushing onto stack
            testCase.verifyEqual(testCase.TestError.getNumErrors(),0)
            params = "numelem = 5 "
            testCase.TestError.MOLEerr_log("MOLE_ERR_INVALID_ARRAY_SIZE", "array1D Construction", params)
            testCase.verifyEqual(testCase.TestError.getNumErrors(),1)
            params = "original numelem = 5, requested resize = "
            testCase.TestError.MOLEerr_log("MOLE_ERR_FAILED_ARRAY_RESIZE", "array1D Resize", params)
            
            testCase.verifyEqual(testCase.TestError.getNumErrors(),2)

            
            params = "original numelem = 5, requested resize = "
            testCase.TestError.MOLEerr_log("MOLE_ERR_INVALID_GRID_SPACING", "grid1D[construct]", params)
            
            testCase.verifyEqual(testCase.TestError.getNumErrors(),3)

        end

        function testMoleErrorContains(testCase)
            #Test for mole error contains
            assert(~testCase.TestError.MOLEerr_contains("MOLE_ERR_GRID_UNCHECKED"))
            params = ""
            testCase.TestError.MOLEerr_log("MOLE_ERR_GRID_UNCHECKED", "<Grid Construction", params)
            assert(testCase.TestError.MOLEerr_contains("MOLE_ERR_GRID_UNCHECKED"))

            params = "original numelem = 5, requested resize = "
            testCase.TestError.MOLEerr_log("MOLE_ERR_FAILED_ARRAY_RESIZE", "array1D Resize", params)
            assert(testCase.TestError.MOLEerr_contains("MOLE_ERR_FAILED_ARRAY_RESIZE"))

            assert(~testCase.TestError.MOLEerr_contains("MOLE_ERR_INVALID_GRID_SPACING"))

        endfunction

        function testMoleErrorsHasErrors(testCase)
            #This functon tests moles has erorrs function on empty error object object with an error
            assert(~testCase.TestError.MOLEerr_haserrors())
            params = ""
            testCase.TestError.MOLEerr_log("MOLE_ERR_GRID_UNCHECKED", "<Grid Construction", params)
            assert(testCase.TestError.MOLEerr_haserrors())
        endfunction

        function testMoleErrorRemoveError(testCase)
            #This test the remove error of a function by adding three errors and removing them each time checking the errors arent there
            params = ""
            testCase.TestError.MOLEerr_log("MOLE_ERR_GRID_UNCHECKED", "<Grid Construction", params)
            testCase.TestError.MOLEerr_log("MOLE_ERR_GRID_UNCHECKED", "<Grid Construction", params)
            testCase.TestError.MOLEerr_remove("MOLE_ERR_GRID_UNCHECKED")
            assert(~testCase.TestError.MOLEerr_contains("MOLE_ERR_GRID_UNCHECKED"))
            params = "numelem = 5 "
            testCase.TestError.MOLEerr_log("MOLE_ERR_INVALID_ARRAY_SIZE", "array1D Construction", params)
            params = "original numelem = 5, requested resize = "
            testCase.TestError.MOLEerr_log("MOLE_ERR_FAILED_ARRAY_RESIZE", "array1D Resize", params)
            params = "original numelem = 5, requested resize = "
            testCase.TestError.MOLEerr_log("MOLE_ERR_INVALID_GRID_SPACING", "grid1D[construct]", params)
            testCase.TestError.MOLEerr_remove("MOLE_ERR_INVALID_ARRAY_SIZE")
            assert(~testCase.TestError.MOLEerr_contains("MOLE_ERR_INVALID_ARRAY_SIZE"))
            assert(testCase.TestError.MOLEerr_contains("MOLE_ERR_FAILED_ARRAY_RESIZE"))
            assert(testCase.TestError.MOLEerr_contains("MOLE_ERR_INVALID_GRID_SPACING"))

            testCase.TestError.MOLEerr_remove("MOLE_ERR_FAILED_ARRAY_RESIZE")
            assert(~testCase.TestError.MOLEerr_contains("MOLE_ERR_FAILED_ARRAY_RESIZE"))
            assert(testCase.TestError.MOLEerr_contains("MOLE_ERR_INVALID_GRID_SPACING"))

            testCase.TestError.MOLEerr_remove("MOLE_ERR_INVALID_GRID_SPACING")
            assert(~testCase.TestError.MOLEerr_contains("MOLE_ERR_INVALID_GRID_SPACING"))
        
        endfunction

        function testGetNumErrors(testCase):
            #Test for checking the size of the stack
            testCase.verifyEqual(testCase.TestStack.size(), 0)
            testCase.TestStack.push({20})
            testCase.TestStack.push({22})
            testCase.verifyEqual(testCase.TestStack.size(),2)
        end
        
        function testIsEmpty(testCase):
            #Test for function that tests if stack is empty
            testCase.assertTrue(testCase.TestStack.isEmpty())
            testCase.TestStack.push({20})
            testCase.TestStack.push({22})
            testCase.assertFalse(testCase.TestStack.isEmpty())
            testCase.TestStack.pop()
            testCase.TestStack.pop()
            testCase.assertTrue(testCase.TestStack.isEmpty())

        end

end