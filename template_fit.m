function [ fit_score ] = template_fit( full_data, template, using_c )
%Implementation of sliding template fit from Clements and Bekker 1997.
% 1) Slides the data in the vector template along the vector or matrix data.
% 2) At each datapoint of data figures out the appropriate amount to scale and
%   offset the data to get a least squared fit
% 3) Returns a vector of the scale amount divided by the standard error of
%   the fit. Big numbers mean better fits to bigger events.

% Differs slightly from Clements and Bekkers form, in that small amplitude
% noise is removed in an arbitrary fashion.

%By Dr W Connelly and Dr S Hulme 2014

[number_samples, number_cells] = size(full_data);

data_length = number_samples;
template_length = length(template);
sum_template = sum(template);

fit_score = zeros(data_length, number_cells);

for n = 1:number_cells

    data = full_data(:,n);

    %pretreat data to remove tiny noise
    %noise_index = find(data<std(data)/2);
    noise_index = data<0.1;
    data(noise_index) = 0;    

    if using_c
        fit_score(:, n) = template_fitter(full_data(:,n), template);
    else
        for i = 1:data_length-template_length

            numerator = dot(template, data(i:i+template_length-1)) - sum_template*sum(data(i:i+template_length-1))/template_length;
            denominator = dot(template,template)-sum_template^2 / template_length;

            scale = numerator/denominator; %calculate scale

            offset = (sum(data(i:i+template_length-1)) - scale * sum_template)/template_length; % calculate offset


            fitted_template = template * scale + offset; %best fit template

            error = sum( (data(i:i+template_length-1) - fitted_template).^2 ); % caculate sum of squares
            standard_error = sqrt( error/(template_length-1) ); % calculate standard error
            fit_score(i, n) = scale/standard_error;    % multiple the reciprocal of the SE by scale to overcome perfect fits achieve by zero scale.
        end
    end
end



end

