%plot PSD graph
function PSD_plot(res)
    hold on;
    semilogx(res.f, 10*log10(res.pn));
    xlabel('Frequnecy offset');
    ylabel('PSD [dBc/Hz]'); 
    grid on;
end
