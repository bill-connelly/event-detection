function [ output ] = detect_ca( epoch_onset, is_stim )
%TODO: WRITE PROPER DOC

using_c = true; %Do you want to use C functions? You must run BUILD.m if you set this to true

temp_baseline = 5; %Number of samples before the tempalte event starts to rise

output = struct; %Structure to hold output.

%testing if using_c is set correctly
if using_c
    if ~exist('exp_smooth_c')
        error('Compiled functions not found. Please compile functions by running BUILD.m or change line 4 of detect_ca.m to: using_c = false;')
    end
end

%Grab the raw data. Data MUST be one cell per column, and the first column
%representing background signal.
[fname, pname] = uigetfile('*.csv','Select a CSV file', 'MultiSelect', 'off');
path = strcat(pname, fname);
data = csvread(path);
[num_samples, ~] = size(data);

%Ask user for inter-sample duration. This MUST be a fixed.
%dt = input('What is the time between samples in seconds? ');
dt = 0.2558;
t_vec = [0:dt:dt*(num_samples-1)]';
%Make template
%template_tau = input('What is the approximate decay constant (tau) of your transients, in seconds? ');
template_tau = 3.5;
%template_duration = input('What is the length of the template, in seconds? (Longer templates are stricter. Templates longer than 100 samples will crash C) ');
template_duration = 20;
[ template, ~ ] = make_template( template_tau, template_duration, dt, temp_baseline );

%Convert raw data to smoothed deltaF/F
[ deltaf_values, smoothed_deltaf, ~, ~, bad_cells ] = deltaf(data(:,2:end), data(:,1), dt, using_c );

output.smoothed_deltaf = smoothed_deltaf;
output.deltaf = deltaf_values;


%Use template to detect events in smoothed deltaF/F
 [ fit_score ] = template_fit( deltaf_values, template, using_c );
output.fit_score = fit_score;
 
%Display fitscore
[ fig_handle, plot_handles, slider_handle, button_handle, value_handle, fig_lim ] = display_fit(  deltaf_values, fit_score, t_vec);


%create the listener for the slide and deal with version problems
v = version('-release');
if str2num( v(1:end-1) ) < 2011
    slider_listener = addlistener(h,'ActionEvent',@(hObject, event) change_line(hObject, event,x,hplot));
else
    slider_listener = addlistener(slider_handle,'ContinuousValueChange',@(hObject, event) change_line(hObject, event));
end

%Set callback from button-press and value
set(button_handle, 'Callback', @set_thresh);
set(value_handle, 'Callback', @set_thresh_val);

%Wait for button press. It creates threshold when button callback runs
threshold = inf;
while threshold == inf
    pause(0.1);    
end

%Find the INDEXES of the events
event_indexs = find_events(fit_score, threshold, length(template), temp_baseline);

%Display All Events
[~] = display_all_events(deltaf_values, smoothed_deltaf, event_indexs, length(template), temp_baseline);

[epoch_data] = calculate_epoch_data(smoothed_deltaf, event_indexs, epoch_onset, dt, is_stim, length(template), bad_cells);
output.event_data = epoch_data;




%Call back events called from Thresholding User Interface window. WARNING:
%GLOBAL VARIABLES AHEAD
    function change_line(hObject,event)
        n = get(hObject,'Value');
        set(value_handle, 'String', num2str(n));
        newdata = ones(1, length(t_vec)) * n;
        for sp = 1:fig_lim
            set(plot_handles(sp, 3),'Ydata', newdata);
        end
    end

    function set_thresh_val(hObject, event)
        temp_threshold = str2num( get(value_handle, 'String') );
        set(slider_handle,'value', temp_threshold);
        newdata = ones(1, length(t_vec)) * temp_threshold;
        for sp = 1:fig_lim
            set(plot_handles(sp, 3),'Ydata', newdata);
        end
    end

    function set_thresh(hObject, event)
        threshold = get(slider_handle, 'Value');
        delete(slider_listener);
        close(fig_handle);
    end

    
    

end

