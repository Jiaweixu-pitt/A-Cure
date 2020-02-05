function [ Energy_Relative ] = Relative_Energy( userSize, Energy )
%Calculate Relative Energy
N = userSize;
E_Max = max(Energy);
Energy_Relative = zeros(N,1);

if (E_Max == 0)
    Energy_Relative = Energy; % isolated node, not divided by 0
else
    for i=1:N
        Energy_Relative(i) = Energy(i)/E_Max;
    end
end

end

