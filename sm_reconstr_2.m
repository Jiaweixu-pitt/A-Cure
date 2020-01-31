function [recon_events, recon_error] = sm_reconstr_2(A, y, events)
% reconstruction using smoothness regularization (usin pinv for final reconstruction)
% version 2, calculate the RMSE

        N = size(A,2);
        h=[1 -1];
        c1=[h(1); zeros(N-2,1)];
        r1=zeros(1,N);
        r1(1:2)=h.';
        Hsm=toeplitz(c1,r1);
        
        Asm = [A;Hsm];
        ysm = [y; zeros(N-2+1,1)];
        
        %xhat_sm = (pinv(Asm)*ysm).';
        xhat_sm = (pinv(Asm)*ysm);
        
        recon_error = sqrt(mean((xhat_sm-events).^2));
        recon_events = xhat_sm;
        
end

