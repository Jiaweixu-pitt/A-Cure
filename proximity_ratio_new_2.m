function [ pr ] =  proximity_ratio_new_2(report1, report2,period)
% new pr version: when two reports close to each other, pr-->1
%   Detailed explanation goes here


% proximity ratio pr =  abs(center1 - center2)/total_data_duration
center1 = (report1(2) + report1(1))/2;
center2 = (report2(2) + report2(1))/2;

if (period == 0)
    r11 = report1(1);
    r12 = report1(2);
    r22 = report2(2);
    
    
    if(r12 > r22)
        two_reports_duration = r12 - r11;
    else
        two_reports_duration = r22 - r11;
    end
    pr =  1 - abs(center1 - center2)/two_reports_duration;
else
    % pri,j= 1?abs(sin(disti,j×?/p))  periodic example
    pr = 1 - abs(sin(3.1415926*abs(center1-center2)/period));
end



% %  %small pr is not allowed, start from 0.5 to 1;
%   pr = pr + 0;
%   if (pr > 1)
%       pr = 1;
%   end

end




