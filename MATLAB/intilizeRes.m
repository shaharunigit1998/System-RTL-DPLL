%initilize the parameters for results
function res=intilizeRes(conf, tdc)

res.fdco        = zeros(1, conf.sim_len);
res.ffsample    = zeros(1, tdc.del_ref_el);
res.risedco     = zeros(1,4);
res.dlf_out     = zeros(1, conf.sim_len_ref);
res.eff_period  = zeros(1, conf.sim_len_ref);

end