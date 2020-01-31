function [ IP, pr, dr ] = IP_v13_2( BIP, report1, report2, neg_flag,period)
% IP with duration and proximity
% _2: consider pr could be period,not used in this paper

% Calculate the duration ratio
dr =  duration_ratio(report1, report2);

% Calculate the proximity ratio
pr =  proximity_ratio_new_2(report1, report2,period);

if BIP == 0
    IP = 0;
elseif neg_flag == 0 && BIP == 1
    IP = 1;
elseif neg_flag == 1 && BIP == 1 && v1 ~= 0 && v2 ~= 0
    IP =1;
else
    IP = BIP*(1-dr)*pr + (1-BIP)*(1-pr)*pr;
end
end







