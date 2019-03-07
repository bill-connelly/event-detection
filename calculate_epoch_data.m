function [epoch_data_by_neuron] = calculate_epoch_data(delta_f, event_indexs, epoch_onset, dt, is_stim, event_duration, bad_cells)
%Function looks worse than it is. It steps through the event_indexs matrix
%finding when events occur, which epoch they occur in, and their
%properties. What it returns is a table where each row is an event, and
%columnwise, the data is cell num, epoch number, (bool) is stim epoch, onset
%time from epoch start, peak amplitude, time of peak, half width, num samples under
%background F signal, and index of event start from start of sampling.


num_events = sum(sum(event_indexs));

%preallocate output matrix

epoch_data_by_neuron = zeros(num_events, 8);

%epoch data is each row is an event,
%columns are, cell num, epoch number, (bool) is stim epoch, onset time from epoch
%start, peak amplitude, time of peak, half width, num samples under
%background F signal, abs index of event

[num_samples, num_cells] = size(event_indexs);

num_epochs = length(epoch_onset);
samples_per_epoch = round(num_samples/num_epochs);

event_num = 1;
for n = 1:num_cells
    event_per_cell = 1;
    event_indexs(:, n);    
    event_start_indexs = find( event_indexs(:, n) );
    event_start_times = event_start_indexs * dt;
    
    for q = 1:length(event_start_indexs)
          start_lim = event_start_indexs(q);
          end_lim = event_start_indexs(q)+event_duration;
          if end_lim > length(delta_f)
              end_lim = length(delta_f);
          end
               
          epoch_data_by_neuron(event_num, 1) = n; %cell number
          
          e = floor( event_start_indexs(q)/samples_per_epoch )+1;
          
          epoch_data_by_neuron(event_num, 2) = e; %epoch number
          epoch_data_by_neuron(event_num, 3) = is_stim(e); %is during stim
          epoch_data_by_neuron(event_num, 4) = mod(event_start_indexs(q), samples_per_epoch) * dt ; %event onset time from start of epoch    
          [epoch_data_by_neuron(event_num, 5), index_of_peak] = max(delta_f( start_lim:end_lim, n ));

          epoch_data_by_neuron(event_num, 6) = epoch_data_by_neuron(event_num, 4) + index_of_peak * dt;
          epoch_data_by_neuron(event_num, 7) =  half_width( delta_f( start_lim:end_lim, n ) ) * dt;
          epoch_data_by_neuron(event_num, 8) = bad_cells(n); %equals number of samples of this cell that are below background. Calculated in deltaf.m
          epoch_data_by_neuron(event_num, 9) = event_start_indexs(q); %index of event start from start of sampling
          event_num = event_num+1;
    end
end

figure()
%Plot stim trials on right, non stim on left
subplot(2,2,1)
scatter(epoch_data_by_neuron(logical(epoch_data_by_neuron(:, 3)), 4), epoch_data_by_neuron(logical(epoch_data_by_neuron(:, 3)),1));
subplot(2,2,3)
hist( epoch_data_by_neuron(logical(epoch_data_by_neuron(:, 3)), 4));

subplot(2,2,2)
scatter(epoch_data_by_neuron(~logical(epoch_data_by_neuron(:, 3)),4), epoch_data_by_neuron(~logical(epoch_data_by_neuron(:, 3)),1));
subplot(2,2,4)
hist( epoch_data_by_neuron(~logical(epoch_data_by_neuron(:, 3)),4));

    % calculte half width duration
    function [halfwidth] = half_width( data)
        data = data - min(data);
        fifty_percent = max(data)/2;
        rise_fifty_point = find(data > fifty_percent, 1, 'first');
        decay_fifty_point = find(data > fifty_percent, 1, 'last');
        halfwidth = (decay_fifty_point - rise_fifty_point);
    end

end

