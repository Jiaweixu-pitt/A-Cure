function [reports_noise, peaks, range_peak] = create_noise_report(reports, noise_number,min,max)
% Create noisy report

% Flag_repeat = 1; % when 0, no repeat

if noise_number == 0
    reports_noise = reports;
    peaks = 0;
    range_peak = 0;
else
    size_reports = size(reports);
    size_reports = size_reports(1);
    
    %peaks = zeros(noise_number,1);
%     peaks = randi([1,size_reports],noise_number,1);
    peaks = randperm(size_reports,noise_number)'; % no repeat element
    
%     % check repeat or not
%     if(length(peaks) == length(unique(peaks)))
%         Flag_repeat = 0;
%     end
    
    % adding random noise from xmin to xmax, if it is
    % min = 2;
    % max = 3;
    range_peak = (max-min).*rand(noise_number,1) + min;
    

    
    
    reports_noise = reports;
    
    
    for i = 1:size(peaks)
%         peaks(i) = round(size_reports/(noise_number+1),0)*i; % round to nearest int
%         if(peaks(i) > size_reports)
%             peaks(i) = size_reports;
%         end
        reports_noise( peaks(i),3) = round(reports_noise( peaks(i),3)*range_peak(i));

    end
end
end

