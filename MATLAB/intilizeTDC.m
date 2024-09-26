%initilize the parameters of the TDC
function tdc=intilizeTDC()

tdc.del_ref_el      = 64;
tdc.del_ref_mu      = 4e-12;
tdc.del_ref_sgm     = 0;
tdc.setup_ff_mu     = 0;
tdc.setup_ff_sgm    = 2e-12;
tdc.del_ref         = cumsum(tdc.del_ref_mu + tdc.del_ref_sgm*randn(1, tdc.del_ref_el));
tdc.setup_ff        = tdc.setup_ff_mu + tdc.setup_ff_sgm*randn(1, tdc.del_ref_el);      
tdc.smpl_t          = tdc.del_ref - tdc.setup_ff;
tdc.smpl_intrvl     = [min(tdc.smpl_t) max(tdc.smpl_t)];
tdc.rise_vec        = zeros(1, 4);
tdc.rise_indx       = 1;
tdc.rise_vec_rdy    = false;
tdc.nos             = tdc.del_ref_el;

end