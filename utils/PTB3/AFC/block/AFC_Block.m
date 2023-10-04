classdef AFC_Block < handle
    %AFC_Block encapsulates a set of stimuli of the same category.
    %
    %   properties
    %       stim                1 x nPos PTB3_Stim subclass array
    %       nPos                int scalar (number of AFC)
    %       texParam            function_handle (contains a cell array with
    %                               the param for stim.makeTex)
    %       method              AFC_Method object
    %       info                PTB3_Visual subclass array
    %       training            AFC_Training object
    %       preStim             PTB3_FrameBase subclass array
    %       postStim            PTB3_FrameBase subclass array
    %       tSleep              float scalar (system time of last pause)
    %       
    %   methods
    %       AFC_Block           Constructor
    %       reset               Returns AFC_Block object (resets training 
    %                               and method)
%     %       update              Returns AFC_Block object (updates method)
%     %       pos                 Returns int scalar (current position)
%     %       tag                 Returns char array (stimulus category)
%     %       iTrial              Returns int scalar (index of current trial)
%     %       nTrial              Returns int scalar (total num. of trials)
%     %       isTraining          Returns logical (true if in training)
    
    properties (GetAccess = public, SetAccess = private)
        stim
        nPos
        texParam
        method
        info
        training
        preStim
        postStim
        tSleep
    end
    
    methods
        function obj = AFC_Block(stim_, texParam_, method_, info_, ...
                varargin)
            %AFC_Block: Constructor. 
            %
            %   Input:  PTB3_Stim array
            %           function_handle (returns a cell array that contains
            %               the param for obj.stim.makeTexture)
            %           AFC_Method object
            %           PTB3_Texture array (block info)
            %               OPTIONAL key / value pairs
            %           training    AFC_Training object
            %           preStim     PTB3_FrameBase array (pre-stimulus)
            %           postStim    PTB3_FrameBase array (post-stimulus)
            %   Output: AFC_Block object
            
            if ~Misc.is(stim_, {'isa', 'PTB3_Stim'}, 'unique', 'multiple')
                error(['First parameter must be a unique PTB3_Stim ' ...
                    'subclass array with multiple elements.']);
            elseif ~Misc.is(texParam_, 'function_handle', 'scalar')
                error('Second parameter must be a function handle.');
            elseif ~(Misc.is(method_, {'isa', 'AFC_Method'}, ...
                    'scalar') && method_.nPos == numel(stim_))
                error(['Third parameter must be an AFC_Method object ' ...
                    'where property nPos = %d.'], numel(stim_));
            elseif ~Misc.is(info_, {'isa', 'PTB3_Visual'}, '~isempty')
                error(['Fourth parameter must be a non-empty ' ...
                    'PTB3_Visual subclass array.']);
            end
            
            %set mandatory parameters
            obj.stim = stim_;
            obj.nPos = numel(stim_);
            obj.texParam = texParam_;
            obj.method = method_;
            obj.info = info_;
            
            %check and set optional parameters
            nMandatory = 4;                                                 %number of mandatory input parameters
            validKey = {'training', 'preStim', 'postStim'};                 %valid keys = names of properties to set
            for i = 1 : 2 : numel(varargin)
                cKey = Misc.ordinalNumber(i / 2 + nMandatory);
                cVal = Misc.ordinalNumber((i + 1) / 2 + nMandatory);
                if ~(ischar(varargin{i}) && ismember(varargin{i}, validKey)
                    error('%s parameter is an invalid key.', cKey);
                elseif ~isempty(obj.(varargin{i}))
                    error('%s parameter is redundant.', cKey);
                elseif isequal(varargin{i}, 'training')
                    if ~(Misc.is(varargin{i}, 'AFC_Training', ...
                            'scalar') && varargin{i}.nPos == obj.nPos)
                        error(['%s parameter must be a AFC_Training ' ...
                            'object where property nPos = %d.'], cVal, ...
                            obj.nPos);
                    end
                    obj.training = varargin{i + 1};
                elseif isequal(varargin{i}, 'preStim')
                    if ~Misc.is(varargin{i}, {'isa', 'PTB3_FrameBase'}, ...
                            '~isempty')
                        error(['%s parameter must be a non-empty ' ...
                            'PTB3_FrameBase subclass array.'], cVal);
                    end
                    obj.preStim = varargin{i + 1};
                elseif isequal(varargin{i}, 'postStim')
                    if ~Misc.is(varargin{i}, {'isa', 'PTB3_FrameBase'}, ...
                            '~isempty')
                        error(['%s parameter must be a non-empty ' ...
                            'PTB3_FrameBase subclass array.'], cVal);
                    end
                    obj.postStim = varargin{i + 1};
                end
            end
        end
        
        function reset(obj)
            %reset resets block properties method (if dynamic) and 
            %training.

            if ~isempty(obj.training)
                obj.training = obj.training.reset;
            end
            if ~isa(obj.method, 'AFC_NonDynMethod')                         %non dynamic methods
                obj.method = obj.method.reset;
            end
        end

%**** CONTINUE HERE
        function update(obj, response)
            %update calls function method of property method.
            %
            %   Input:  logical scalar (user response; for QUEST only)
            
            if isa(obj.method, 'AFC_Quest')
                if nargin ~= 1, error('One parameter expected.'); end
                obj.method.update(response, obj.intensity);
            else
                if obj.isTraining, obj.training.update;
                else, obj.method.update;
                end
            end
        end

%why is pos in method        
        function x = pos(obj)
            %pos returns the current position.
            %
            %   Output: int scalar (stimulus position)

            if obj.isTraining, x = obj.training.pos;
            else, x = obj.method.pos;
            end
        end
        
%can tag be a block property        
%         function x = tag(obj)
%             %tag returns a char array that defines the stimulus category.
%             %
%             %   Output: char array    
%             
%             x = obj.stim.tag; 
%         end

%can intensity be a block property        
%         function x = intensity(obj)
%             %intensity returns the intensity of the AFC_Stim to be 
%             %shown in the current trial.
%             %
%             %   Output: float scalar
%             
%             x = obj.stim.intensity;
%         end
        
%can iTrail be a block property
        function x = iTrial(obj)
            %iTrial returns the index of the current trial.
            %
            %   Output: int scalar
            
            if obj.isTraining, x = obj.training.iTrial;
            else, x = obj.method.iTrial;
            end
        end

%can nTrial be a block property        
        function x = nTrial(obj)
            %nStim returns the total number of trials.
            %
            %   Output: int scalar
            
            if obj.isTraining, x = obj.training.nTrial;
            else, x = obj.method.nTrial;
            end
        end
        
        function x = isTraining(obj)
            %isTraining returns true if block is in training mode.
            %
            %   Output: logical scalar
           
            x = ~isempty(obj.training) && ...
                obj.training.iStim <= obj.training.nStim;
        end
    end
end

