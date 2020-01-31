function [ dr ] =  duration_ratio(report1, report2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Duration rate: dr =  abs(d1 - d2)/max(d1,d2)
d1 = report1(2) - report1(1);
d2 = report2(2) - report2(1);
dr =  abs(d1 - d2)/max(d1,d2);

end

