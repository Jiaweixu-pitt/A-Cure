function [ IP, bip, pr, dr, reports_ini, reports_noise, noise_reports] = IP_calculation_v2_2( events,ip_version,noise_number,noise_min,noise_max,mu_rn,var_rn,mu_rd,var_rd,period)

% v1: generating simulated data: uniformly distibuted with parameters
% v2: loading events (real disease data)
% v2_2: same as v2, but can choose pr for periodic example, however, we don't
% have periodic cases
% experiment simulation of newly defined Incompatibility Probability.

% convert matrix to vector
data = events;

% create reports
reports = collect_reports_norm(data, mu_rn, var_rn, mu_rd, var_rd);% start_point, end_point, Value

% Randomly create noisy reports based the pre-defined parameters.
[reports_noise, noise_reports, noise_ratio ] = create_noise_report(reports, noise_number,noise_min,noise_max);


% Apply reports with noise
reports_ini = reports;  % original reports set 
reports = reports_noise; % noisy reports set


time_full_start = cputime;
% Create all possible report pairs 
% 1. pairwise properties: (#of1, #of2, D1, D2, V1, V2,  O)
% for the pair, T1 always < T2. report 1 starts earlier always.
% #1: report number of report1
% #2: report number of report2
% O: overlap; D1: duration of the 1st report; D2: duration of the 2nd
% report; RO1 = O/D1; RO2 = O/D2; V1: value of report 1; V2: value of
% report2.
% for each report (T, T', V)
[pair_reports] = create_pair_reports(reports);


%2. Calculate the incompatibility probability (IP)
size_pr = size(pair_reports);
size_pr = size_pr(1);
IP = zeros(size_pr,3); % #R1, #R2, #IP pairwise
bip = zeros(size_pr,3);
pr = zeros(size_pr,3);
dr = zeros(size_pr,3);

% Choose the definition of IP formula
% For details please check our previous paper:
% Xu, J., Zadorozhny, V., & Grant, J. (2019). 
% IncompFuse: a logical framework for historical information fusion with 
% inaccurate data sources. Journal of Intelligent Information Systems, 1-19.

% ip_version = 13 is used in this paper:
% ip = f(bip, pr_new, and dr) = BIP*(1-dr)*pr+(1-BIP)*(1-pr)*pr
% dr = abs(d2-d1)/max(d2,d1)
% pr = 1- dis/two-report-total-duration
% all previous versions deleted
time_IP_start = cputime;
switch ip_version   
    case 13
        for i = 1: size_pr
            IP(i,1) = pair_reports(i,1);
            IP(i,2) = pair_reports(i,2);
            order_report1 = IP(i,1);
            order_report2 = IP(i,2);
            t1 = reports(order_report1,1);
            t1_end = reports(order_report1,2);
            t2 = reports(order_report2,1);
            t2_end = reports(order_report2,2);
            D1 = pair_reports(i,3);
            D2 = pair_reports(i,4);
            V1 = pair_reports(i,5);
            V2 = pair_reports(i,6);
            O = pair_reports(i,7);
            
            id_report1 = IP(i,1);
            id_report2 = IP(i,2);
            report1 = reports(id_report1,:);
            report2 = reports(id_report2,:);
            neg_flag = 0;
            
            
            bip(i,1) = IP(i,1);
            bip(i,2) = IP(i,2);
            
            % Calculate BIP
            bip(i,3) = BIP(O,D1,D2,V1,V2,neg_flag);
            
            pr(i,1) = IP(i,1);
            pr(i,2) = IP(i,2);
            
            dr(i,1) = IP(i,1);
            dr(i,2) = IP(i,2);
            
            % Calculate IP
            [ IP(i,3), pr(i,3), dr(i,3) ] = IP_v13_2( bip(i,3), report1, report2, neg_flag,period );
        end
end

time_IP = cputime - time_IP_start;
time_full = cputime - time_full_start;
end




