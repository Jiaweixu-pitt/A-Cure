function [recon_reports, TOL] = report_set_recon_data(reports,events)
%From report set to data 

[reports_duration,reports_values]=rep_constraint_equations_full(reports,events);


[recon_reports,TOL] = lsq_reconstruct_only(reports_duration, reports_values);
end

