function [recon_events, TOL]=lsq_reconstruct_only(A, y)
% A: reports duration
% y: reports value
% PINV(A,TOL) treats all singular values of A that are less than TOL as
%   zero. By default, TOL = max(size(A)) * eps(norm(A)).

    %invhat2 = pinv(A)*y;
    TOL = max(size(A)) * eps(norm(A));
    invhat2 = pinv(A)*y;

%recon_error = sqrt(mean((invhat2-events).^2));
recon_events = invhat2;
end

