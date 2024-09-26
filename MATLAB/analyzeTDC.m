%analyze the tdc and make samples out of them
function tdc=analyzeTDC(tdc,next_ref_rise)

       cyc_len = diff(tdc.rise_vec(1:tdc.rise_indx));        
       tdc.rise_fall_time = zeros(1, 2*tdc.rise_indx-1);
       tdc.rise_fall_time(1:2:end) = tdc.rise_vec(1:tdc.rise_indx);
       tdc.rise_fall_time(2:2:end) = tdc.rise_vec(1:tdc.rise_indx-1) + cyc_len/2;
       tdc.rise_fall_time           = tdc.rise_fall_time - next_ref_rise;
       tdc.rise_fall_val = (1 - (-1).^(1:numel(tdc.rise_fall_time)))/2;
       tdc.smpl_v = 0*tdc.smpl_t;

       for cnt = 1:numel(tdc.rise_fall_val)
           tdc.smpl_v(tdc.smpl_t > tdc.rise_fall_time(cnt)) = tdc.rise_fall_val(cnt);
       end

       tdc.rise_vec_rdy = false;
       tdc.rise_indx    = 1;

end