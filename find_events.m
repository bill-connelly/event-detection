function [ event_indexs ] = find_events(fit_score, threshold, template_len, temp_baseline)
%Find local maxima. Brute force approach. Better ideas welcome

[num_samples, num_cells] = size(fit_score);

event_indexs = false(num_samples, num_cells);

half_temp = floor(template_len/2);

for c = 1:num_cells
    for s = 1:num_samples
        if s+half_temp > num_samples
            end_lim = num_samples;
        else
            end_lim = s+half_temp;
        end
        if s-half_temp < 1
            start_lim = 1;
        else
            start_lim = s-half_temp;
        end
        if max(fit_score(start_lim:end_lim, c)) == fit_score(s,c) && fit_score(s,c) > threshold
            event_indexs(s+temp_baseline,c) = true; %offset start time of event for baseline
        end    
    end
end


end

