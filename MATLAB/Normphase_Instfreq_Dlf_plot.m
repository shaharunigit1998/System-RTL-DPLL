%plot normalized phase graph, inst frequency graph and DLF output graph 
function Normphase_Instfreq_Dlf_plot(res,pedge,finst,n)
    figure;
    ax(1) = subplot(2,1,1);
    plot(pedge(1:n), 'o--');
    ylabel("Normalized phase");
    xlabel("Time [n.u.]");
    ax(2) = subplot(2,1,2);
    plot(finst(1:n), 'o--');
    ylabel("Instanteneous frequency");
    xlabel("Time [n.u.]")
    linkaxes(ax, 'x');
    figure;
    plot(res.dlf_out(1:n));
    ylabel("DLF output");
    xlabel("Time [n.u.]")
end
