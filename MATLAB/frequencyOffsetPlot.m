%plot frequency offset
function frequencyOffsetPlot(res)
    figure;
    semilogx(res.qe_f, 10*log10(res.qe_pn_tot));
    xlabel('Frequency offset');
    ylabel('PSD QE [dBc/Hz]'); 
    grid on;
end
