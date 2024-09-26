classdef Period_Est
    properties
        eff_period 
        r2f 
        f2r
        p
    end
    
    methods
        % Constructor
        function obj = Period_Est(eff_p_init)
            arr=[0; 0];
            %U<6.6>
            obj.eff_period = arr;
            %U<6.6>
            obj.r2f = eff_p_init/2;
            %U<6.6>
            obj.f2r = eff_p_init/2;

            obj.p.eff_period_res = 2^6;
            obj.p.eff_period_max = (2^(6+6)-1)/2^6; 

            obj.p.r2f_res = 2^6;
            obj.p.r2f_max = (2^(6+6)-1)/2^6;

            obj.p.f2r_res = 2^6;
            obj.p.f2r_max = (2^(6+6)-1)/2^6;
        end
        
        % Calculate dpd out
        function obj = main(obj, edges, alpha)
            %check which edges is greater
            if edges(2,1) > edges(1,1)
                %U<6.6>
                %calculate the mean of f2r
                obj.f2r = (edges(2,1) - edges(1,1))*alpha + obj.f2r*(1-alpha);
                %round the value to the right resolution
                obj.f2r=min(max(round(obj.f2r*obj.p.f2r_res)/obj.p.f2r_res, 0), obj.p.f2r_max);
            else
                %U<6.6>
                %calculate the mean of f2r
                obj.r2f = (edges(1,1) - edges(2,1))*alpha + obj.r2f*(1-alpha);
                %round the value to the right resolution
                obj.r2f=min(max(round(obj.r2f*obj.p.r2f_res)/obj.p.r2f_res, 0), obj.p.r2f_max);
            end

            %U<6.6>
            obj.eff_period = obj.r2f + obj.f2r;     

            % Set finite resolution to eff_period U<6.6>
            % First do round to 6 bits of fraction
            % Then, saturate to maximum U<6.6> value                
            obj.eff_period = min(max(round(obj.eff_period*obj.p.eff_period_res)/obj.p.eff_period_res, 0), obj.p.eff_period_max);

        end
        
    end
end