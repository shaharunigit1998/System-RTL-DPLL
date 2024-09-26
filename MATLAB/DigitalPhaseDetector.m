classdef DigitalPhaseDetector < handle
    properties
        prev_edges;
        finst; 
        f_error;
        dpd_out;
        rst_cnt;
        p;
    end
    
    methods
        % Constructor
        function obj = DigitalPhaseDetector()
            %U<6.10>
            obj.finst       = zeros(2, 1);
            %U<6.10>
            obj.f_error     = zeros(2, 1);
            %U<6.10>
            obj.prev_edges  = zeros(2, 1);
            %U<9.10>
            obj.dpd_out     = 0;
            
            obj.rst_cnt     = 1;

            obj.p.finst_res = 2^10;
            obj.p.finst_max = (2^(6+10)-1)/2^10;

            obj.p.f_error_res = 2^10;
            obj.p.f_error_max = (2^(6+10)-1)/2^10;

            obj.p.dpd_out_res = 2^10;
            obj.p.dpd_out_max = (2^(9+10)-1)/2^10;

            obj.p.prev_edges_res = 2^10;
            obj.p.prev_edges_max = (2^(6+10)-1)/2^10;
        end
        
        % Calculate dpd out
        % edges         - U<6.6>
        % eff_period    - U<6.6>
        % FRAC          - U<0.16>
        function obj = main(obj, edges, eff_period, FRAC)

            % Calculate instanteneous normalized (to fRef) fractional (mod(,1)) frequency
           
            obj.finst = mod(-(edges - obj.prev_edges), eff_period);
            %U<6.10>
           obj.finst=min(max(round(obj.finst*obj.p.finst_res)/obj.p.finst_res, 0), obj.p.finst_max);

            % Compute instanteneous frequency error
            obj.f_error = mod(obj.finst - FRAC*eff_period + 0.5*eff_period, eff_period) - 0.5*eff_period;

            %U<6.10>

            obj.f_error=min(max(round(obj.f_error*obj.p.f_error_res)/obj.p.f_error_res,-obj.p.f_error_max), obj.p.f_error_max);
       
            % Sum to get phase eror
             %U<9.10>
            obj.dpd_out = obj.dpd_out + (obj.rst_cnt == 0)*mean(obj.f_error);
            obj.dpd_out=min(max(round(obj.dpd_out*obj.p.dpd_out_res)/obj.p.dpd_out_res, -obj.p.dpd_out_max), obj.p.dpd_out_max);

            % Save for next time
            obj.prev_edges  = edges;
            obj.rst_cnt     = obj.rst_cnt - (obj.rst_cnt > 0);
           
            %U<6.10>
            obj.prev_edges=min(max(round(obj.prev_edges*obj.p.prev_edges_res)/obj.p.prev_edges_res, 0), obj.p.prev_edges_max);
        end        
    end
end
