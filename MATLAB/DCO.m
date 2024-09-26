classdef DCO < handle
    properties
        conf;
        ftarget;
        Kdco;
        fdco;

        cap_bank;
        mtrx;

        band_freq_rng;

        coarse; 
        fine;
        dlf_bias;

        N_coarse;
        N_fine;
    end
    
    methods
        % Constructor
        function obj = DCO()
            obj.conf.dco.elec.Cmin      = 170e-15; % Self-capacitance
            
            obj.conf.dco.elec.Ind       = 1.2e-9; % Inductance

            obj.conf.dco.elec.dC_coarse.val = 36e-15;
            obj.conf.dco.elec.dC_coarse.num = 2;

            obj.conf.dco.elec.dC_fine.val   = 4e-15;
            obj.conf.dco.elec.dC_fine.num   = 8;

            obj.conf.dco.elec.dC_var.val    = 33e-18;
            obj.conf.dco.elec.dC_var.num    = 2^8 - 1;

            obj.conf.dco.ns_sgm     = 30e-6;
            obj.conf.ref.rj_sgm     = 1e-12;
            obj.conf.lock_len       = 2^18;
            obj.conf.sim_len        = obj.conf.lock_len + 2^22;
            obj.conf.n_psd          = 2^20;
            divider             = 2;
            fRef                = 40e6;
            obj.ftarget             = divider*(130 + 1/16)*fRef;
            obj.Kdco=300e6;
            obj.fdco=0;
            
        end

        function init(obj)
            %make capcitor bank
            [N_coarse, N_fine]      = meshgrid(0:obj.conf.dco.elec.dC_coarse.num, 0:obj.conf.dco.elec.dC_fine.num);

            obj.cap_bank            = reshape(N_coarse*obj.conf.dco.elec.dC_coarse.val + N_fine*obj.conf.dco.elec.dC_fine.val, [], 1);

            obj.mtrx                = [0 obj.conf.dco.elec.dC_var.val*obj.conf.dco.elec.dC_var.num];

            [C_mtrx, C_cap_bank]    = meshgrid(obj.mtrx, obj.cap_bank);

            total_cap               = obj.conf.dco.elec.Cmin + C_cap_bank + C_mtrx;

            obj.band_freq_rng       = 1./(2*pi*sqrt(obj.conf.dco.elec.Ind*total_cap)); %     [10 10.1] 10.03            
            obj.N_coarse            = reshape(N_coarse, [], 1);
            obj.N_fine              = reshape(N_fine, [], 1);
        end

        function genieabs(obj, fTarget)

            % Perform search to yield number of coarse caps, fine capacitors, dlf_bias   

            bias_vec = (fTarget - obj.band_freq_rng(:, 1))./diff(obj.band_freq_rng, 1, 2);    
            [~, index] = min(abs(bias_vec - 0.5));
            obj.coarse      = obj.N_coarse(index);
            obj.fine        = obj.N_fine(index);
            obj.dlf_bias    = bias_vec(index)*2^16;
        end

        % Calculate DCO real
        function obj = Calfdco_real(obj, dlf) % ideal
            %calculate total capacitance
            total_cap =  obj.conf.dco.elec.Cmin + ...
                         obj.coarse*obj.conf.dco.elec.dC_coarse.val + ...
                         obj.fine*obj.conf.dco.elec.dC_fine.val + ...
                         (dlf.dlf_out + obj.dlf_bias)/2^8*obj.conf.dco.elec.dC_var.val;
            %calculate the frequency
            obj.fdco   = 1./(2*pi*sqrt(obj.conf.dco.elec.Ind*total_cap));
            
            % Add noise
            obj.fdco    = obj.fdco*(1 + obj.conf.dco.ns_sgm*randn(1));
        end
        
        % Calculate DCO ideal
        function obj = Calfdco(obj, fTarget, dlf) % ideal
            obj.fdco    =  fTarget - obj.Kdco*dlf.dlf_out;
            obj.fdco    = obj.fdco*(1 + obj.conf.dco.ns_sgm*randn(1));
        end
        
    end
end