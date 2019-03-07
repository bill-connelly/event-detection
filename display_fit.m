function [ fig_handle, plot_handles, slider_handle, button_handle, value_handle, fig_lim ] = display_fit(  deltaf_values, fit_score, t_vec )
% This is a nasty function for displaying the graphs, and GUI.

threshold = 1; %threshold set to 1 just incase the user clicks ok straight away
[~, num_cells] = size( deltaf_values );

fit_std = std(fit_score, 0, 1); %columnwise (cellwise) standard deviation bigger std = more events

[~, std_rank] = sort(fit_std, 'descend'); %get ranking, bigger first

%Horrible stuff to deal with if the user has less than 9 cells
if num_cells < 9
    fig_lim = num_cells;
    switch num_cells
        case 8
            x_figs = 3;
            y_figs = 3;           
        case 7
            x_figs = 3;
            y_figs = 3;        
        case 6
            x_figs = 3;
            y_figs = 2;             
        case 5
            x_figs = 3;
            y_figs = 2;            
        case 4
            x_figs = 3;
            y_figs = 2;            
        case 3
            x_figs = 3;
            y_figs = 1;         
        case 2
            x_figs = 2;
            y_figs = 1;           
        case 1
            x_figs = 1;
            y_figs = 1;          
    end
else
    fig_lim = 9;
    x_figs = 3;
    y_figs = 3;
end

screen_size = get(0, 'ScreenSize');
fig_handle = figure('Position', [80 80 screen_size(3)-160 screen_size(4)-160]); %create outer figure
horiz_line = ones(length(t_vec), 1); %a vector for the threshold line


% Plot the subfigures ranked to likelyhood of event. Could change this
for sp = 1:fig_lim
    subplot(x_figs,y_figs,sp);
    plot_handles(sp,:) = plot(t_vec, fit_score(:, std_rank(sp)), t_vec, deltaf_values(:, std_rank(sp)), t_vec, horiz_line);
end

%Create the user interface. Note there are two styles of listeners here one
%is for older matlab, one is for more modern matlab.
slider_handle = uicontrol('style','slider','String', 'Threshold', 'units','pixel','Position',[20 20 300 20], 'value', 1, 'SliderStep', [0.01 0.1], 'max', 20, 'min', 1);
value_handle = uicontrol('style', 'edit','Position', [350 20 50 20], 'String', '1');
button_handle = uicontrol('style','pushbutton', 'String', 'OK', 'position', [450 20 50 20 ]);
tightfig(fig_handle);

%     function shitface(hObject, eventdata, handles)
%        eventdata 
%         
%     end


end

