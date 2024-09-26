classdef DigitalLoopFilter < handle
    properties
        dlf_int          
        dlf_prop         
        dlf_out     
        p
    end
    
    methods
        % Constructor
        function obj = DigitalLoopFilter()
             %18 int , 11 frac
            obj.dlf_int     =0;   
             %9 int 11 frac
            obj.dlf_prop    =0;   
             %16 int
            obj.dlf_out     =0;

            obj.p.dlf_int_res = 2^11;
            obj.p.dlf_int_max = (2^(17+11)-1)/2^11;

            obj.p.dlf_prop_res =  2^11;
            obj.p.dlf_prop_max = (2^(9+11)-1)/2^11;

            obj.p.dlf_out_res = 2^16;
            obj.p.dlf_out_max = obj.p.dlf_out_res/2;

            obj.p.knormal_res = 2^3;
            obj.p.knormal_max = (2^(8+3)-1)/2^3;
        end
        
        % Calculate dpd out
         function obj = main(obj, dpd_out, beta_shift, K_norm)
            %integrate the phase error
            obj.dlf_int          = obj.dlf_int + dpd_out;
         % <18.11>
            obj.dlf_int          = min(max(round(obj.dlf_int*obj.p.dlf_int_res)/obj.p.dlf_int_res, -obj.p.dlf_int_max), obj.p.dlf_int_max);


            % save dpd_out in dlf_porp 
            obj.dlf_prop         = dpd_out;
            % <9.11>
            obj.dlf_prop         = min(max(round(obj.dlf_prop*obj.p.dlf_prop_res)/obj.p.dlf_prop_res, -obj.p.dlf_prop_max), obj.p.dlf_prop_max);
            
            
%             % Eventually, dlf_out needs to be an integer number of 16 bits
%             % total S<1.15> which spans [-0.5, 0.5)

            %k make the filter

            tmp                 = bitshift(obj.dlf_int*obj.p.dlf_int_res, -beta_shift, 'int64')/obj.p.dlf_int_res;

            obj.dlf_out         = K_norm*(tmp + obj.dlf_prop);
            %dlf_out to an integer that represent number capacitors
            obj.dlf_out         = min(max(round(obj.dlf_out),-obj.p.dlf_out_max),obj.p.dlf_out_max);
        end
        
    end
end