classdef TDC_Encoder < handle
    properties
        edges;
        p;
    end
    
    methods
        % Constructor
        function obj = TDC_Encoder()
            obj.p.bbl_flt   = 4;
            %U<6.6>
            obj.edges       = zeros(2, 1);

            obj.p.edges_res = 2^10;
            obj.p.edges_max = (2^(6+10)-1)/2^10;

        end
        
        % Calculate dpd out
        function obj = main(obj, tdc)
             %make bubble killer algorithm and find the first rise/fall
             obj.edges(1) = find(~tdc.smpl_v(1:end-4) & ~tdc.smpl_v(2:end-3) & ~tdc.smpl_v(3:end-2) & ~tdc.smpl_v(4:end-1)&tdc.smpl_v(5:end),1, "first");   % Rise
             obj.edges(2) = find(tdc.smpl_v(1:end-4) & tdc.smpl_v(2:end-3) & tdc.smpl_v(3:end-2) & tdc.smpl_v(4:end-1)& ~tdc.smpl_v(5:end),1, "first");   % Fall
            %U<6.6>
            %make sure it's in the right resolution
            obj.edges = min(max(round(obj.edges*obj.p.edges_res)/obj.p.edges_res, 0), obj.p.edges_max);

        end
        
    end
end