function [ deltaf_values, smoothed_df, f_zero, av_for_min, bad_cells ] = deltaf( f_values, bg, dt, using_c )
%This function subtracts background values from f values and then converts
%these to deltaf's using a running F0 calculation. Finally it smooths the
%data using a negative exponential weighted running average.

%By Dr W Connelly and Dr S Hulme 2014

%Equations for smoothing from Jia et al Nature Protocols 6, 28–35 (2011)


tau0 = 0.75;   %time constant for exp smoothing
tau1 = 5;  %duration of running ave
tau2 = 9;  %time to look for min

[number_samples, number_cells] = size(f_values);

time_vec = 0:dt:dt*(number_samples-1);



if number_samples ~= length(bg)
   error('bg length not equal to f values length')
end

bad_cells = zeros(1,number_cells); % Vector to hold number of samples below background per cell.

for i = 1:number_cells
    f_values(:, i) = f_values(:, i) - bg;
    if min(f_values(:, i)) < 1
        num_bad = sum(f_values(:, i)<1);
        disp(['Cell number ' num2str(i) ' contains ' num2str(num_bad) ' values less that background'])
        bad_cells(i) = num_bad;
   end
end


%now perform actual task
av_for_min = zeros(number_samples, number_cells);
f_zero = zeros(number_samples, number_cells);
deltaf_values = zeros(number_samples, number_cells);
smoothed_df = zeros(number_samples, number_cells);

for i = 1:number_cells

    if using_c
        av_for_min(:, i) = running_av_filter_c(f_values(:, i),  tau1/dt );        
        f_zero(:, i) = av_min_c(av_for_min(:, i), (tau2/dt));        
        deltaf_values(:, i) = (f_values(:,i) - f_zero(:, i)) ./ f_zero(:, i);
        smoothed_df(:, i) = exp_smooth_c(deltaf_values(:, i), floor((tau0/dt)));
    else
        av_for_min(:, i) = running_av_filter(f_values(:, i), tau1/dt);
        f_zero(:, i) = av_min(av_for_min(:, i), tau2/dt);
        deltaf_values(:, i) = (f_values(:,i) - f_zero(:, i)) ./ f_zero(:, i);
        smoothed_df(:, i) = exp_smooth(deltaf_values(:, i), floor((tau0/dt)));
    end

end


%HELPER FUNCTIONS BELOW - NOT USED IN THIS VERSION BUT C FUNCTIONS PERFORM
%IDENTICAL CALCULATIONS, STUDY HERE IF YOU'RE TRYING TO FIGURE OUT WHAT C
%FUNCTIONS DO

    function [out_vector] = running_av_filter(in_vector, num_sample_window)        
        out_vector = zeros(length(in_vector), 1);
        
        window = floor(num_sample_window/2);
        num_points = length(in_vector);
        for n = 1:num_points
            startlim = n-window;
            if startlim < 1
                startlim = 1;
            end
            endlim = n+window;
            if endlim > num_points
                endlim = num_points;
            end
            out_vector(n) = mean(in_vector(startlim:endlim));
        end
    end

    function [out_vector] = av_min(in_vector, num_sample_window)
        out_vector = zeros(length(in_vector), 1);
        num_sample_window = floor(num_sample_window);
        
        for n = 1:length(in_vector)
            startlim = n-num_sample_window;
            if startlim < 1
                startlim = 1;
            end
            out_vector(n) = min(in_vector(startlim:n));
        end  
    end

    function [out_vector] = exp_smooth(in_vector, num_sample_tau)
        out_vector = zeros(length(in_vector), 1);        
        num_sample_tau = floor(num_sample_tau);
        
        for t = 1:length(in_vector)
            top_integral = sum(flipud( in_vector(1:t) ) .* omega(1:t, num_sample_tau)');
            bottom_integral = sum(omega(1:t, num_sample_tau));
            out_vector(t) = top_integral/bottom_integral;
        end
        
        function out_vector = omega(t, num_sample_tau)
           out_vector = exp(-abs(t)/num_sample_tau);
        end
    end

end

