function res = BIP(O,D1,D2,V1,V2,neg_flag)
% Probability of incompatibility of two reports based on the
% relative overlap ratios RO1 and RO2. V1 and V2 are the reported values.
% neg_flag = 1 if we allow negative values in the time series data.


RO1 = O/D1;
RO2 = O/D2;

if neg_flag == 0
    if RO1 == 1 && RO2 ~= 1 && V1>V2
        res = 1;
    elseif RO2 == 1 && RO1 ~= 1 && V2>V1
        res = 1;        
    elseif RO2 == 1 && RO1 == 1 && V1 ~= V2
        res = 1;
    else
        res = abs(V1/D1-V2/D2)/max(V1/D1,V2/D2);
        %res = (O/max(D1,D2))*abs(V1/D1-V2/D2)/max(V1/D1,V2/D2);
        %res = abs(RO1*V1-RO2*V2)/max(RO1*V1, RO2*V2);
    end
elseif neg_flag == 1
    % there is negtive values
end
end





