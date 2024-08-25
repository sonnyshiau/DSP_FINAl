%%
% lab4-2(a) 
% Specifications

fsamp = 8000;
fp = 1500;
fs = 2000;
passband_o = 2*pi*fp/fsamp;  % passband
stopband_o = 2*pi*fs/fsamp;  % stopband
delta_o = stopband_o-passband_o;
delta_p = 0.05;
delta_s = 0.01; 
%kaiser window
A = 40;
M = ceil( (A-8)/(2.285*delta_o));
N = M/2;
beta = 0.584*(A-21)^(0.4) + 0.07886*(A-21);

nn = 0:2*N;
nn = nn(:);
a = N;
win = 1/besseli(0,beta) * besseli(0,beta*sqrt(1-(nn/a - 1).^2)  );

%Apply Kaiser window to retangle window
hrecwin = myFIRrecwin((passband_o + stopband_o)/2, N);
h_kaiser =hrecwin.*win;
disp(h_kaiser')
figure(1),
[h,w] = freqz(h_kaiser);
freqz(h_kaiser)

%draw target line
passband_x  = [0,passband_o/pi];
transition_x = [passband_o/pi,stopband_o/pi];
stop_x = [stopband_o/pi, w(end)/pi];


passband_y  = linspace(0,0,length(passband_x));
transition_y = linspace(0,-40,length(transition_x));
stop_y = linspace(-40,-40,length(stop_x));

target_line_x = [passband_x,transition_x,stop_x];
target_line_y = [passband_y,transition_y,stop_y];

hold on
plot(target_line_x ,target_line_y,LineStyle="--",Color="r");

legend("lpf","target_line");
hold off
savefig("LPF.fig");
T = table(h_kaiser);
coeffs_filename = "coeffs_fp.txt";
writetable(T, "coeffs_fp.txt")

disp(T);

disp(['Filter coefficients have been saved to ', coeffs_filename]);


%%
% Plotting SNR vs Input Word Length and MAC Word Length
snr_vs_input_wl = readmatrix('find4inWL.txt');
input_wl_values = readmatrix('WL.txt');

figure(2),
plot(input_wl_values, snr_vs_input_wl);
title("SNR vs Input Word Length");
xlabel("Input Word Length (bits)");
ylabel("SNR");
savefig("SNR_IN_WL");
snr_vs_mac_wl = readmatrix('find4macWL.txt');
mac_wl_values = readmatrix('MAC_WL.txt');

figure(3),
plot(mac_wl_values, snr_vs_mac_wl);
title("SNR vs MAC Word Length");
xlabel("MAC Word Length (bits)");
ylabel("SNR");
savefig("SNR_MAC_WL");

%output from C++
input_signal = readmatrix('inputsignal.txt');
float_output = readmatrix('outputsignal_fp.txt');
fixed_output = readmatrix('outputsignal_fixed.txt');
figure(4),
freqz(input_signal);
title("Input Signal Spectrum");
savefig("input_spectrum.fig");
figure(5),
freqz(float_output);
title("output_spectrum");
savefig("output_spectrum.fig");
figure(6),
freqz(fixed_output);
title("Fixed Point output spectrum");
savefig("output_FIXED_spectrum.fig");
%%
%FROM DSP
function h = myFIRrecwin(omega_c, M)
    h = zeros(2*M+1,1);
    nn = 1:M;
    nn = nn(:);
    h(M+1) = omega_c/pi;
    h(M+2:end) = sin(omega_c*nn)./nn * (1/pi);
    h(M:-1:1) = h(M+2:end);
end


