clear all; %#ok<CLALL> 
close all;
clc;

set(0, 'DefaultLineLineWidth', 2);
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'DefaultAxesFontSize', 14);      

%% General parameters

conf=intilizeConf();

Kdco                = 300e6;% [MHz/Full scale]
Kdco_est            = Kdco/2;

K                   = 10^(-20/20); % Relevant range [-40, -20]
beta                = 10^(40/20);  % Relevant range [30, 60]

divider             = 2;
fRef                = 40e6;
fTarget             = divider*(130 + 1/16)*fRef;

FRAC                = mod(fTarget/divider/fRef, 1);

conf.sim_len_ref    = ceil(1.1*conf.sim_len/fTarget*fRef);

estimated_period=48;

beta_shift          = round(log2(beta));
K_norm              = min(round(2^16*K/(estimated_period*Kdco_est/fRef)*2^5)/2^5, 2^(6+5));

%buffer time
t_buffer= 4e-12;
t_current           = 0;

%% The loop

MAXSAMPLE=1000;
samples_in_hexa=0;
isample=1;

next_ideal_ref_rise = 1/fRef;
next_ref_rise       = next_ideal_ref_rise;

%set variable for the ff loop
tdc=intilizeTDC();

dco_index=1;
ff_index=1;
avgtimes=0;

edges               = zeros(2, conf.sim_len_ref); % row 1 - rises, row 2 - falls
pedge               = zeros(2, conf.sim_len_ref);
ideal_edge          = zeros(1, conf.sim_len_ref);

finst               = edges;
f_error             = edges;
samples_of_tdc      = uint64(ideal_edge);
r2fs                = ideal_edge;
f2rs                = ideal_edge;
dpd_outs            = ideal_edge; 
dlf_props           = ideal_edge;
fdcos               = ideal_edge;
prev_edges          = edges;
pedge_prev          = [0; 0];

dpd_out             = 0;
dlf_int             = 0;
dlf_out             = 0;
n                   = 0;
r2f                 = 20;
f2r                 = 20;
alpha               = 1/32; %1/64;


eff_period=edges*0;

%initilize DCO
dco=DCO();
dco.init();
dco.genieabs(fTarget);

%initilize TDC_Encoder
tdc_encoder=TDC_Encoder();

%initilize Period Estimator
pestimator=Period_Est(tdc.del_ref_el);

%initilize Digital Phase Detector
dpd=DigitalPhaseDetector();

%initilize Digital Loop Filter
dlf=DigitalLoopFilter();

%Results 
res=intilizeRes(conf, tdc);

tic;
for cntt = 1:conf.sim_len  


     %% Print progress to screen
    if(mod(cntt, floor(conf.sim_len/10)) == 0)
        time_left_est   = round(toc*(conf.sim_len/cntt - 1));
        fprintf(1, 'LOOP  : Main loop progress ... %3d%% (%gm:%gs left)\n', ...
                round(100*cntt/conf.sim_len), floor(time_left_est/60), mod(time_left_est, 60));
    end

    % Use electrical parameters to compute frequency
    dco.Calfdco_real(dlf);

    %divide the frequency by 2
    fdiv = dco.fdco/2;
    
    % Store results
    res.fdco(cntt) = dco.fdco;

    % Accumulation of TDC edges
    if (t_current > next_ref_rise+tdc.smpl_intrvl(1))&&(~tdc.rise_vec_rdy)
        tdc.rise_indx = tdc.rise_indx + 1;
        tdc.rise_vec(tdc.rise_indx) = t_current;
        if (t_current > next_ref_rise+tdc.smpl_intrvl(2))
            tdc.rise_vec_rdy = true;
        end
    else
        tdc.rise_vec(1) = t_current;
    end
    
    % Check when the dco clock passes the reference clock and calculate the phases 
    if (tdc.rise_vec_rdy)
       n = n + 1;

       % Analyze TDC
       
       tdc=analyzeTDC(tdc,next_ref_rise);
       
%        if (MAXSAMPLE>n)
%             % Assuming tdc.smpl_v is the binary array with MSB at position 64 and LSB at position 1
            binaryArray = tdc.smpl_v;
 
             % Calculate the decimal value
             decimalValue = uint64(0);
             yb = length(binaryArray);
 
             for i = 1:yb
                 if binaryArray(i) == 1
                 decimalValue = uint64(decimalValue) + uint64(2)^(i-1);
                 end
             end

       %TDC ENCODER
       tdc_encoder.main(tdc);

       %Period Estimator  
       pestimator = main(pestimator, tdc_encoder.edges, alpha);

       % TDC + effective period estimation (PEST)
       last_dco_rise            =  tdc.rise_vec(2);
       ideal_eff_period         = 1/fdiv;
       ideal_edge(n)            = (last_dco_rise - next_ref_rise)/ideal_eff_period; % Phase should reside in unitles [0, 1] interval
       tdc_ideal_encoder.edges  = ones(2, 1)*ideal_edge(n);
        
       %Digital Phase Detector
       dpd.main(tdc_encoder.edges, pestimator.eff_period, FRAC);


       % Loop filter
       dlf.main(dpd.dpd_out, beta_shift, K_norm);

       % Save for next time
       next_ideal_ref_rise  = next_ideal_ref_rise + 1/fRef;
       next_ref_rise        = next_ideal_ref_rise + conf.ref.rj_sgm*randn(1);   

       %produce for the graphs 
       fdcos(n) = dco.fdco;

       samples_of_tdc(n)= decimalValue;
       edges(:, n)      = tdc_encoder.edges;

       r2fs(n) = pestimator.r2f;
       f2rs(n) = pestimator.f2r;
       res.eff_period(n)= pestimator.eff_period;

       finst(:, n)      = dpd.finst; 
       f_error(:, n)    = dpd.f_error;
       dpd_outs(n)         = dpd.dpd_out;
       prev_edges(:,n)       =dpd.prev_edges;

       dlf_props (n)     = dlf.dlf_prop;
       res.dlf_int(n) = dlf.dlf_int;
       res.dlf_out(n)   = dlf.dlf_out;

       pedge(:, n)      = tdc_encoder.edges/pestimator.eff_period;       
      
    end

    % Advance current time
    t_current       = t_current + 1/fdiv;
end

%print samples

    file     = fopen('samples.txt', 'w');
    fprintf(file, "%x\n",samples_of_tdc(1:34263));
    fclose(file);

    file     = fopen('edges1.txt', 'w');
    fprintf(file, "%x\n",edges(1,1:34263)*2^10);
    fclose(file);

    file     = fopen('edges2.txt', 'w');
    fprintf(file, "%x\n",edges(2,1:34263)*2^10);
    fclose(file);

    file     = fopen('r2f.txt', 'w');
    fprintf(file, "%x\n",r2fs(1:34263)*2^6);
    fclose(file);

    file     = fopen('f2r.txt', 'w');
    fprintf(file, "%x\n",f2rs(1:34263)*2^6);
    fclose(file);

    file     = fopen('eff_period.txt', 'w');
    fprintf(file, "%x\n",res.eff_period(1:34263)*2^6);
    fclose(file);

    file     = fopen('finst1.txt', 'w');
    fprintf(file, "%x\n",finst(1, 1:34263)*2^10);
    fclose(file);

    file     = fopen('finst2.txt', 'w');
    fprintf(file, "%x\n",finst(2, 1:34263)*2^10);
    fclose(file);

    file     = fopen('f_error1.txt', 'w');
    fprintf(file, "%x\n",abs(f_error(1, 1:34263))*2^10);
    fclose(file);

    file     = fopen('f_error1_sign.txt', 'w');
    fprintf(file, "%x\n",floor((sign(f_error(1, 1:34263))-1)/-2));
    fclose(file);

    file     = fopen('f_error2.txt', 'w');
    fprintf(file, "%x\n",abs(f_error(2, 1:34263))*2^10);
    fclose(file);

    file     = fopen('f_error2_sign.txt', 'w');
    fprintf(file, "%x\n",floor((sign(f_error(2, 1:34263))-1)/-2));
    fclose(file);

    file     = fopen('dpd_out.txt', 'w');
    fprintf(file, "%x\n",abs(dpd_outs(1:34263))*2^10);
    fclose(file);

    file     = fopen('dpd_out_sign.txt', 'w');
    fprintf(file, "%x\n",floor((sign(dpd_outs(1:34263))-1)/-2));
    fclose(file);
    
    file     = fopen('prev_edges1.txt', 'w');
    fprintf(file, "%x\n",prev_edges(1, 1:34263)*2^10);
    fclose(file);

    file     = fopen('prev_edges2.txt', 'w');
    fprintf(file, "%x\n",prev_edges(2, 1:34263)*2^10);
    fclose(file);   

    file     = fopen('dlf_int.txt', 'w');
    fprintf(file, "%x\n",abs(res.dlf_int(1:34263))*2^11);
    fclose(file);

    file     = fopen('dlf_int_sign.txt', 'w');
    fprintf(file, "%x\n",floor((sign(res.dlf_int(1:34263))-1)/-2));
    fclose(file);

    file     = fopen('dlf_prop.txt', 'w');
    fprintf(file, "%x\n",abs(dlf_props(1:34263))*2^11);
    fclose(file);

    file     = fopen('dlf_prop_sign.txt', 'w');
    fprintf(file, "%x\n",floor((sign(dlf_props(1:34263))-1)/-2));
    fclose(file);

    file     = fopen('dlf_out.txt', 'w');
    fprintf(file, "%x\n",abs(res.dlf_out(1:34263)));
    fclose(file);

    file     = fopen('dlf_out_sign.txt', 'w');
    fprintf(file, "%x\n",floor((sign(res.dlf_out(1:34263))-1)/-2));
    fclose(file);
    
    
%% Results analysis
n_psd       = 2^round(log2(conf.n_psd/(fTarget/divider)*fRef));
fref_rgn    = floor(conf.lock_len/(fTarget/divider)*fRef):n;
OS          = floor(numel(fref_rgn)/n_psd);
fref_rgn    = (n-OS*n_psd+1):n;

qe          = pedge(:, fref_rgn) - repmat(ideal_edge(fref_rgn), 2, 1);
fs          = fRef;

qe      = mod(qe.'+0.5,1)-0.5;
qe      = qe - repmat(mean(qe), size(qe, 1), 1);

[res.qe_pn, res.qe_f] = pwelch(2*pi*mean(qe, 2), hann(n_psd), n_psd/2, n_psd, fs, 'onesided'); 
res.qe_pn          = res.qe_pn/2;

zm1_qe=exp(-2i*pi*res.qe_f/fRef);

%Calculate the Open Loop Filter as a Z transform
res.qe_hol= K*(1/beta./(1-zm1_qe) + 1)./(1 - zm1_qe);

%Calculate the VCO Closed Loop Filter as a Z transform
hvco   =          1./(1+res.qe_hol);
href   = res.qe_hol./(1+res.qe_hol);

sig_v           = (fTarget/divider)*conf.dco.ns_sgm;
svf             = (sig_v.^2)./(fTarget/divider);
res.qe_v_phi    = svf./(res.qe_f).^2;

res.qe_pn_tot = res.qe_v_phi.*abs(hvco).^2 + ((2*pi*conf.ref.rj_sgm*(fTarget/divider)).^2/fRef + res.qe_pn(:, end)).*abs(href).^2;

fs      = fTarget/divider;
ferr    = (res.fdco - fTarget)/divider;
perr    = cumsum([0 ferr(conf.lock_len+1:end)]/fs);

%print RTL graph
text_new_fdco();

[res.pn, res.f] = pwelch(2*pi*perr, hann(conf.n_psd), conf.n_psd/2, conf.n_psd, fs, 'onesided'); 
res.pn          = res.pn/2;


%print matlab graph and analytic result graph
semilogx(res.f, 10*log10(res.pn)); hold on;
semilogx(res.qe_f, 10*log10(res.qe_pn_tot)); hold off;


xlabel('Frequnecy offset[HZ]');
ylabel('PSD [dBc/Hz]'); 
title('Phase Noise');
legend('RTL results', 'Physical Results','Analytical Results');
grid on;

%calculate the jitter of the matlab results
jitter=sqrt(2*trapz(res.f,res.pn))/(2*pi*fs);
disp(['The jitter of the MATLAB is ', num2str(jitter*10^12),' picoseconds']);

figure;
ax(1) = subplot(2,1,1);
plot(pedge.', 'o--');
ylabel("Normalized phase");
xlabel("Time [n.u.]");


ax(2) = subplot(2,1,2);
plot(finst.', 'o--');
ylabel("Instanteneous frequency");
xlabel("Time [n.u.]")


linkaxes(ax, 'x');

figure;
plot(res.dlf_out);
ylabel("DLF output");
xlabel("Time [n.u.]")

%Calculate the VCO PHASE analytically 

res.v_phi           = zeros(1, n);  


sig_v=fTarget*conf.dco.ns_sgm;
svf= (sig_v.^2)./fTarget;
res.v_phi = (svf.*(res.f.^-2));

figure;
semilogx(res.f,10*log10(res.v_phi));
ylabel("DCO PHASE [dBc/Hz]");
xlabel("Hz")

%Calculate Z as Frequency Vaiable

zm1=exp(2*pi*-1i.*res.f/fRef);


%Calculate the Open Loop Filter as a Z transform
res.hol= K*(1/beta./(1-zm1)+1)./(1j*2*pi*res.f/fRef);%(1-zm1);

%Calculate the VCO Closed Loop Filter as a Z transform
hvco=1./(1+res.hol);


%Calculate the Reference Closed Loop Filter against Frequency and plot it

href=res.hol./(1+res.hol);



figure;
plot(edges.', 'o--');
ylabel("Edges");
xlabel("Iteration Number")
legend('Rise', 'Fall');





