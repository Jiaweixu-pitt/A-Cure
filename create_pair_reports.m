function [pair_reports] = create_pair_reports(reports)

% Calculate pair incompatibility

% 1. pairwise properties: (#1, #2, D1, D2, V1, V2,  O)
% for the pair, T1 always < T2. report 1 starts earlier always.
% #1: report number of report1
% #2: report number of report2
% O: overlap; D1: duration of the 1st report; D2: duration of the 2nd
% report; RO1 = O/D1; RO2 = O/D2; V1: value of report 1; V2: value of
% report2.
% for each report (T, T', V)

size_reports = size(reports);
size_reports = size_reports(1);
number_properties = 7;
% total pairs are upper triable (n-1)+(n-2)+..+1 = n(n-1)/2
size_pair_reports = size_reports * (size_reports - 1) / 2; 
pair_reports = zeros(size_pair_reports,number_properties);


pointer_pair_reports = 1;
for i = 1: size_reports
    for j = i+1 : size_reports
        
        % report_1 R1 start earlier than report_2 R2
        if(reports(i,1) < reports(j,1))
            R1_number = i;
            R2_number = j;
            R1 = reports(i,1:3);
            R2 = reports(j,1:3);
        else
            R1_number = j;
            R2_number = i;
            R1 = reports(j,1:3);
            R2 = reports(i,1:3);
        end
        
        T1 = R1(1);
        T1_quote = R1(2);
        V1 = R1(3);
        
        T2 = R2(1);
        T2_quote = R2(2);
        V2 = R2(3);
        
        D1 = T1_quote - T1 + 1; % T1 = 1, means start from day 1 ;
        % T1_quote =2, means end after day 2 (include day 2);
        % thus duration, D1 = 2 - 1 + 1 means 2 days.
        D2 = T2_quote - T2 + 1;
        
        % over_lap: O
        if( T1_quote >= T2_quote)
            O = D2;
        elseif (T2 <= T1_quote && T1_quote < T2_quote)
            O = T1_quote - T2 + 1;
        elseif (T1_quote < T2)
            O = 0;
        end
        
        pair_reports(pointer_pair_reports,1) = R1_number;
        pair_reports(pointer_pair_reports,2) = R2_number;
        pair_reports(pointer_pair_reports,3) = D1;
        pair_reports(pointer_pair_reports,4) = D2;
        pair_reports(pointer_pair_reports,5) = V1;
        pair_reports(pointer_pair_reports,6) = V2;
        pair_reports(pointer_pair_reports,7) = O;
        pointer_pair_reports = pointer_pair_reports + 1;
    end
end

end

