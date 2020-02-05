function [recon_events, recon_error]=lsq_reconstruct(A, y,events)
%calculating recon_events and recon_error
invhat2 = pinv(A)*y;
recon_error = sqrt(mean((invhat2-events).^2));
recon_events = invhat2;
end
