%plot dco phase graph
function DCO_phase_plot(res)
   figure;
    semilogx(res.f,10*log10(res.v_phi));
    ylabel("DCO PHASE DB");
    xlabel("Hz")

end
