%{
This are tests for our LIFO octave stack class
%}

classdef test_stack < matlab.unittest.TestCase
    properties
        TestStack
    end
    methods(TestMethodSetup)
        #Initial stack setup with empty stack on each test case
        function createEmptyStack(testCase)
            testCase.TestStack = Stack()
        end
    end
    methods(Test)

        function testEmptyStackConstruction(testCase)
            #Test for empty construciton of stack
            testCase.verifyEqual(testCase.TestStack.size(), 0)
        end
        

        function testPopEmpty(testCase)
            #Test for popping of a stack an raising an error
            testCase.verifyError(testCase,@() testCase.TestStack.pop(),'Stack:empty')
        end

        function testTopEmpty(testCase):
            #Test for empty top stack
            testCase.verifyError(testCase,@() testCase.TestStack.top(),'Stack:empty')
        end

        function testPush(testCase):
            #Test for pushing onto stack
            testCase.TestStack.push({20})
            testCase.verifyEqual(testCase.TestStack.size(),1)
            testCase.verifyEqual((testCase.TestStack.top())(1),20)

            testCase.TestStack.push({22})
            testCase.verifyEqual(testCase.TestStack.size(),2)
            testCase.verifyEqual((testCase.TestStack.top())(1),22)

            testCase.TestStack.push({24})
            testCase.verifyEqual(testCase.TestStack.size(),3)
            testCase.verifyEqual((testCase.TestStack.top())(1),24)

            testCase.TestStack.push({26})
            testCase.verifyEqual(testCase.TestStack.size(),4)
            testCase.verifyEqual((testCase.TestStack.top())(1),26)
        end

        function testPop(testCase):
            #Test for popping elements off stack
            testCase.verifyEqual(testCase.TestStack.size(), 0)
            testCase.TestStack.push({20})
            testCase.TestStack.push({22})
            testCase.TestStack.push({24})
            testCase.TestStack.push({26})
            testCase.verifyEqual(testCase.TestStack.size(),4)
            testCase.verifyEqual((testCase.TestStack.top())(1),26)
            testCase.TestStack.pop()
            testCase.verifyEqual(testCase.TestStack.size(),3)
            testCase.verifyEqual((testCase.TestStack.top())(1),24)
            testCase.TestStack.pop()
            testCase.verifyEqual(testCase.TestStack.size(),2)
            testCase.verifyEqual((testCase.TestStack.top())(1),22)
            testCase.TestStack.pop()
            testCase.verifyEqual(testCase.TestStack.size(),1)
            testCase.verifyEqual((testCase.TestStack.top())(1),20)
            testCase.TestStack.pop()
            testCase.verifyEqual(testCase.TestStack.size(),0)
            testCase.verifyError(testCase,@() testCase.TestStack.pop(),'Stack:empty')
        end

        function testTop():
            #Test for checking the top of the stack
            testCase.verifyEqual(testCase.TestStack.size(), 0)
            testCase.TestStack.push({20})
            testCase.TestStack.push({22})
            testCase.verifyEqual(testCase.TestStack.size(),2)
            testCase.verifyEqual((testCase.TestStack.top())(1),22)
        end

        function testSize(testCase):
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