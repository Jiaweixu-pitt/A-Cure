function [ reports_duration_m,reports_values_m ] = gen_new_report_after_EFlow_Thresh( Energy_Relative,threshE, reports, reports_duration, reports_values)

% generate new reports list by deleting the reports whose energy is
% higher than threshE

%threshE = 0.9;
A = reports_duration;
size_A = size(A);
num_reports = size_A(1);

list_report_delete = double.empty;
for i = 1: num_reports
    if (Energy_Relative(i) >= threshE)
        list_report_delete = [list_report_delete,i];
    end
end

reports_modified = reports;
reports_modified(list_report_delete,:) = [];

reports_duration_m = reports_duration;
reports_duration_m(list_report_delete,:) = [];
reports_values_m = reports_values;
reports_values_m(list_report_delete,:)=[];

end

