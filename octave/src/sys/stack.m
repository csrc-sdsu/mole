classdef Stack < handle 
    properties (Access = private)
        Data = {} 
    end 

    methods 
        function push(obj, val) 
            obj.Data{end+1} = val; 
        end 

        function val = pop(obj) 
            assert(~obj.isEmpty(), 'Stack:empty', 'Cannot pop from an empty stack'); 
            val = obj.Data{end}; 
            obj.Data(end) = []; 
        end 

        function val = top(obj) 
            assert(~obj.isEmpty(), 'Stack:empty', 'Cannot peek an empty stack'); 
            val = obj.Data{end}; 
        end 


        function tf = isEmpty(obj) 
            tf = isempty(obj.Data); 
        end 

        function n = size(obj) 
            n = numel(obj.Data); 
        end 

        function print(obj) 
            fprintf('Stack with %d error(s):\n', obj.size()); 
            for i = numel(obj.Data):-1:1 e = obj.Data{i}; 
            fprintf(' [%d] Code=%d Location=%s
            Param=%s\n', ... i, e.errCode,
            e.errLocation, e.paramError); 
        end
    end 
    endmethods
endclassdef
