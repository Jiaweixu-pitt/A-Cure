function [Aeq,beq] = rep_constraint_equations_full(reports,events)
%For each report generate consistency constraint equation based on events covered by that report. 
% Ie, each x variable corresponds to a time unit.

num_of_reports = size(reports,1);
num_of_events = size(events,2);

beq=[];
Aeq=zeros(num_of_reports,num_of_events);

for i = 1:num_of_reports
%    rfrom = rep_from(reports(i,:));
%    rto   = rep_to(reports(i,:));
%    rval = rep_val(reports(i,:));
   
   rfrom = reports(i,1);
   rto   = reports(i,2);
   rval =  reports(i,3);
   
   beq = [beq; rval];
   for j = rfrom:rto
       Aeq(i,j)=1;
    end;
end;
end