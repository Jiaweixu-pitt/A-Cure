function [ Energy, M4, timeCalculation, sumEnergy, sumEnergyEnd] = Energy_Trans_M4( userSize, M1 )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
% Energy Spreading, Get the final energy and transformation matrix
N = userSize;
time0 = cputime;
portion = 0.75;
startEnergy=1;
sumEnergy=startEnergy*N;

Energy = zeros(N,1);

for i = 1:N
    Energy(i) = startEnergy;
end

% transformation started
threshHold = startEnergy/10e2;
%threshHold = 1.0e-4;
ssdNow = 1;
loopCount = 0;
% start iteration
while(ssdNow > threshHold && loopCount <= 2000000)
    loopCount = loopCount+1;
    %calculate function
    Function = zeros(N,1);
    for i = 1:N
        Function(i) = -log10(Energy(i)/sumEnergy);
    end
    
    % calculate M2 M2(i,j) = 0 if M1(i,j)=0; M2(i,j) = Function(i) if M1(i,j) !=0;
    M2 = M1;
    for i=1:N
        for j= 1:N
            if(M2(i,j)>threshHold)
                M2(i,j) = Function(i);
            end
        end
    end
    M2 = portion*M2;
    
    % Calculate M3 = F(M1, Function).
    M3 = transpose(Function)*M1;
    
    % Calculate M4 = F(M2,M3)
    M4 = M2;
    for i=1:N
        for j= 1:N
            if(i == j)
                M4(i,j) = 1-portion;
            elseif(M4(i,j)>threshHold)
                M4(i,j) = M4(i,j)/M3(j);
            end
            
        end
    end
    
    % Calculate New Energy
    EnergyNew = M4*Energy;
    %
    EnergyOld = Energy;
    Energy = EnergyNew;
    
    ssd = 0;
    for x = 1:N
        ssd = ssd + (Energy(x)-EnergyOld(x))^2;
    end
    ssd = sqrt(ssd);
    %ssdNow = ssd/(N-1);
    ssdNow = ssd;
end

timeCalculation = cputime - time0;


sumEnergyEnd = 0;
for i = 1:N
    if( Energy(i) < threshHold)   % if the energy is close to 0, set it to 0
        Energy(i) = 0;    
    end
    sumEnergyEnd = sumEnergyEnd + Energy(i);
    
end

end

