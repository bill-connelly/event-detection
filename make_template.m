function [ template, t_vec ] = make_template( tau, template_duration, dt, temp_baseline )
%Create a Calcium Transient like waveform. Can also be used for EPSPs

template_length = floor(template_duration/dt);
t_vec = 0:dt:template_duration-dt;
x_vec = 0:template_length-1;

template = zeros(template_length, 1);
tau = round(tau/dt);

%Sum of two exponentials
%factor = -((rise/decay)^(rise/(decay-rise)))*((rise-decay)/decay);
%template(3:end) = 1/factor * (exp(-x_vec(1:end-2)/decay) - exp(-x_vec(1:end-2)/rise)) ;

%Gaussian
%template = 1/(tau*sqrt(2*pi)) .* exp(-((x_vec-tau*3).^2)/(2*tau^2));

%Alpha Function
template(temp_baseline:end) = (x_vec(1:end-(temp_baseline-1)))/tau .* exp(-(x_vec(1:end-(temp_baseline-1)) - tau)/tau) ; 

end

