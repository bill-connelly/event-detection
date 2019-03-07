function [ all_events ] = display_all_events(deltaf_values, smoothed_deltaf, event_indexs, temp_length, temp_baseline)
%Chops up the deltaf_values as per the logical matrix event_index into
%temp_length vectors. col_event is a vector where the event stored in
%all_events(:,n) came from the cell col_event(n)

[num_samples, ~] = size(deltaf_values);

%find where events start
[row_event, col_event] = find(event_indexs);
%find were events end (and if off bottom of matrix, set to bottom of matrix)
row_ends = row_event+temp_length-1;
row_ends(row_ends>num_samples) = num_samples;

%This is a not ideal soltuion. 
all_events = zeros(temp_length+temp_baseline, length(col_event));
all_smooth_events = zeros(temp_length+temp_baseline, length(col_event));
for i = 1:length(col_event)
    event_length = row_ends(i)-row_event(i)+1;
    all_events(1:event_length+temp_baseline,i) = deltaf_values(row_event(i)-temp_baseline:row_ends(i), col_event(i));
    all_smooth_events(1:event_length+temp_baseline,i) = smoothed_deltaf(row_event(i)-temp_baseline:row_ends(i), col_event(i));
end
figure()
subplot(1,2,1)
plot(all_events)
subplot(1,2,2)
plot(all_smooth_events)
end