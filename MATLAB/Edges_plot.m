%plot edges graph
function PSD_plot(edges)
    figure;
    plot(edges.', 'o--');
    ylabel("Edges");
    xlabel("Iteration Number")
    legend('Rise', 'Fall');
end
