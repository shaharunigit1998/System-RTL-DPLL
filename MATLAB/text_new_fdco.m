function text_new_fdco()
conf.dco.elec.C0    = 40e-12; % Self-capacitance
conf.dco.elec.L     = 600e-12; % Inductance
conf.dco.ns_sgm     = 30e-6;
conf.lock_len       = 2^18;
conf.sim_len        = conf.lock_len + 2^22;
conf.n_psd          = 2^20;
% Parameters
divider = 2;
fRef = 40e6;
fTarget = divider * (130 + 1/16) * fRef; 

% Open the file for reading
fileID = fopen('new_fdco.txt', 'r');

% Check if the file opened successfully
if fileID == -1
    error('Failed to open new_fdco.txt');
end

% Read the entire file content at once
data = textscan(fileID, '%f');
data = data{1}; % Extract data from the cell array

% Close the file
fclose(fileID);

% Store the data in the structure
  res.fdco = data;

%print the graph
fs      = fTarget/divider;
ferr    = (res.fdco - mean(res.fdco(conf.lock_len+1:end)))/divider;
perr    = cumsum([0; ferr(conf.lock_len+1:end)]/fs);

[res.pn, res.f] = pwelch(2*pi*perr, hann(conf.n_psd), conf.n_psd/2, conf.n_psd, fs, 'onesided'); 
res.pn          = res.pn/2;

figure;
semilogx(res.f, 10*log10(res.pn)); hold on;

jitter=sqrt(2*trapz(res.f,res.pn))/(2*pi*fs);
disp(['The jitter of the RTL is ', num2str(jitter*10^12),' picoseconds']);

xlabel('Frequency offset');
ylabel('PSD [dBc/Hz]'); 
grid on;
end
