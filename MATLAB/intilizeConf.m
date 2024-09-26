
%initilize conf values
function conf=intilizeConf()

conf.dco.elec.C0    = 40e-12; % Self-capacitance
conf.dco.elec.L     = 600e-12; % Inductance
conf.dco.ns_sgm     = 30e-6;
conf.ref.rj_sgm     = 2e-12;
conf.lock_len       = 2^18;
conf.sim_len        = conf.lock_len + 2^22;
conf.n_psd          = 2^20;
end