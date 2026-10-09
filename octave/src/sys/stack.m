%{
LIFO stack implementation for structure objects
%}
classdef Stack < handle 
    properties (Access = private)
        Data = {} 
    endproperties 

    methods 
        function push(obj, val)
            #This funciton pushes a value onto the stack and checks its a struct object 
            if ~isstruct(val)
                error('Stack:type', 'Stack values should be structs')
            endif
            obj.Data{end+1} = val; 
        endfunction 

        function val = pop(obj)
            #This function pops the top element of the stack 
            if obj.isEmpty()
                error('Stack:empty', 'Cannot pop from an empty stack');
            endif
            #Get top element and set the last element as empty 
            val = obj.Data{end}; 
            obj.Data(end) = []; 
        endfunction 

        function val = top(obj) 
            #Peak at the top and return the top elements fo stack
            if obj.isEmpty()    #Check stack is not empty
                error('Stack:empty', 'Cannot peek an empty stack');
            endif
            val = obj.Data{end}; 
        endfunction 


        function tf = isEmpty(obj)
            #Check if stack is empty 
            tf = isempty(obj.Data); 
        endfunction 

        function n = size(obj)
            #Get the stack size 
            n = numel(obj.Data); 
        endfunction 

        function print(obj) 
            fprintf('Stack with %d error(s):\n', obj.size()); 
            for i = numel(obj.Data):-1:1 e = obj.Data{i}; 
            fprintf(' [%d] Code=%d Location=%s
            Param=%s\n', ... i, e.errCode,
            e.errLocation, e.paramError); 
        endfunction
    endmethods
endclassdef
