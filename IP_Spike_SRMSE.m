% This is the main code for A-Cure. It applys IP-Spike-SRMSE method
% to dectect noisy reports for reconstruction of four disease data
% More detail in reference:
%****************************
% Jiawei Xu, Vladimir Zadorozhny, and John Grant.
% IncompFuse: A-Cure: An Accurate Information Reconstruction from Inaccurate Data Sources.
% Information Systems.
%****************************
%
% We ran this code on Matlab R2018a
%
% Input
% disease data: Tycho.mat
% from https://www.tycho.pitt.edu

% Output
% folder: output/IP_Spike_SRMSE/
% result file: output/IP_Spike_SRMSE/Results_All_IP_Spike_RMSE.mat, including:
% 1. Accuracy
% LSQ reconstruction applying noise detection/deletion with IP-EF-SRMSE method
%
% 2. All reconstruction RMSE including:
% LSQ reconstruction
% with noisy reports
% without noisy reports (clean)
% applying noise detection/deletion with IP-Spike-SRMSE method
%
% Experimental Setup:
% 4 different disease
% 4 different reports set with different noise setting.
% details please check the paper.


% loading input disease data
current_folder = pwd;
data_file = strcat(pwd,'\Tycho.mat');
load(data_file);

% setting up output folder
output_folder = strcat(pwd,'\outPut\IP_Spike_SRMSE\');
folder0 = output_folder;
mkdir(folder0);

% Calculation Start:
% nDisease = 1:4 will calculate all 4 disease
% nDisease = 1:1 will calculate measles only
% nDisease = 2:2 will calculate hepatitis only
% nDisease = 3:3 will calculate pertussis only
% nDisease = 4:4 will calculate smallpox only
for nDisease = 1:4
    switch nDisease
        case 1
            events = events_measle;
            deseaseS = 'measles';
        case 2
            events = events_hepatitis;
            deseaseS = 'hepatitis';
        case 3
            events = events_pertussis;
            deseaseS = 'pertussis';
        otherwise
            events = events_smallpox;
            deseaseS = 'smallpox';
    end
    
    period = 0; % data has no periodicity
    ip_version = 13; % version to define ip, which is used in this paper
    
    % Parameters to set up number of noisy reports
    noise_number = [10, 20];
    noise_level =["NoiP10", "NoiP20"];
    
    % Parameters to set up noise severity ratio
    noise_min = 1;  % noise fluctuation lowest edge
    noise_max =  2; % noise fluctuation highest edge
    noise_severity = [0.2, 0.4]; % 0.2 = 20% of normal value
    noise_severity_level =["NoiS2","NoiS4"];
    severe_ratio = noise_severity;
    
    % Parameters to set up reports set (Gaussian distribution)
    mu_rn = 100; % mean of # of reports
    var_rn = 5;  % variance of # of reports
    mu_rd = 50;  % mean of report duration
    var_rd = 5;  % variance of report duration
    
    name_txt_disease = strcat(deseaseS);%variable for output file name
    
    % for certain disease calculating with different parameters of
    % noisy reports set up
    for i_noise = 1: length(noise_number)
        for i = 1 : length(severe_ratio)
            
            
            % file name
            name_txt = strcat(name_txt_disease,'_',noise_level(i_noise),'_',noise_severity_level(i));
            
            % set up # of noise and noise severity
            noise_number_now = noise_number(i_noise);
            noise_min_now = noise_min * noise_severity(i);
            noise_max_now = noise_max * noise_severity(i);
            
            % Created reports set based on the pre-defined parameters
            % Modify the reports set by adding noisy reports based on the
            % pre-defined parameters
            % calculate the IP, bip, pr, dr
            % Also list the noisy reports.
            [ IP, bip, pr, dr, reports_ini, reports_cell.(name_txt_disease), severe_reports_list] = IP_calculation_v2_2( events,ip_version,noise_number_now,noise_min_now,noise_max_now,mu_rn,var_rn,mu_rd,var_rd,period);
            
            reports_noise = reports_cell.(name_txt_disease);
            noise_reports = severe_reports_list;
            
            str_ip.(name_txt) = IP;
            str_bip.(name_txt) = bip;
            str_ip_mean.(name_txt) = mean(IP(:,3));
            str_ip_max.(name_txt) = max(IP(:,3));
            str_bip_max.(name_txt) = max(bip(:,3));
            
            % auto find the IP threshold as non_zero_threshold
            % threshold_times = 100; //orginal setting
            % using Slop algorithm, details in the paper
            threshold_times = 100;
            [IP_threshold_new] = Find_IP_threshold_using_Slope(IP,threshold_times);
            
            str_ip_threshold.(name_txt) = IP_threshold_new;
            
            non_zero_threshold = IP_threshold_new;
            indices_IP_nonzero = find(IP(:,3)> non_zero_threshold);
            
            X = IP;
            indices = find(X(:,3)< non_zero_threshold);
            X(indices,:) = [];
            size_X = size(X);
            size_X = size_X(1);
            X_new = [X(1:size_X,1);X(1:size_X,2)];
            Reports_collect = X_new; % non-zero IP reports all collected here
            
            % count the occurrences of each element in a vector
            [occ_X_new,ele_X_new]=hist(X_new,unique(X_new));
            
            % create report set with [order, #occ in non-0 IP distribution]            
            size_report_set = size(reports_noise);
            size_report_set = size_report_set(1);
            
            report_set_after_IP = zeros(size_report_set,2);
            report_set_after_IP(:,1) = 1:size_report_set;% give orders
            report_set_after_IP(ele_X_new,2) = occ_X_new;% which report
            %has several non-zero IP cases
            
            %sort report_set based the the 2nd col: how many times non-0 IP
            %cases
            %report_set_after_IP_sort = sortrows(report_set_after_IP,2,'descend');
            
            % for reports with noise
            % get duration matrix and values
            [recon_reports_noise] = report_set_recon_data(reports_noise,events);
            RMSE_Noise = sqrt(mean((recon_reports_noise - events).^2));
            
            % for reports without noise
            reports_clean = reports_noise;
            reports_clean(noise_reports,:) = [];
            [recon_reports_clean] = report_set_recon_data(reports_clean,events);
            RMSE_Clean = sqrt(mean((recon_reports_clean - events).^2));
            
            
            %Sequential RMSE without delete any reports
            %tihs is a method to provide reference to define the threshold
            % for detecting/deleting noise report
            % threshold = n*mean_srmse, n is a number.
            srmse_noise = zeros(size_report_set,1);
            for k = 1:size_report_set
                reports_del_one = reports_noise;
                reports_del_one(k,:) = [];
                [recon_reports_del_one] = report_set_recon_data(reports_del_one,events);
                RMSE_del_one = sqrt(mean((recon_reports_del_one - recon_reports_noise).^2));
                srmse_noise(k) = RMSE_del_one;
            end
            
            mean_srmse = mean(srmse_noise);
            
            
            %S-RMSE (with deleting) using order from IP
            
            %sort report_set based the the 2nd col: how many times non-0 IP
            %cases
            report_set_after_IP_sort = sortrows(report_set_after_IP,2,'ascend');
            
            
            %the opposite oder to compare
            %report_set_after_IP_sort = sortrows(report_set_after_IP,2,'descend');
            
            
            loop_point = size_report_set;
            
            reports_deleted_list = int16.empty;
            reports_deleted_list_tmp = int16.empty;
            how_many_del = 0;
            how_many_del_tmp = 0;
            
            % threshold to delete a report whose SRMSE is too large
            % it is n*mean_srmse
            threshold_rmse_del = mean_srmse * 1;
            threshold_reports = 0;
            
            % final reportset ini
            reports_final = reports_noise;
            
            % while will end if threshold # of reports have been checked
            % and report has non-0 IP existence
            %{
            while(loop_point > threshold_reports && ...
                    report_set_after_IP_sort(loop_point,2) > 0)
            %}
            
            % while will end if threshold # of reports have been checked
            while(loop_point > threshold_reports)
                
                report_delete = report_set_after_IP_sort(loop_point,1); %delete one report from the end
                how_many_del_tmp = how_many_del + 1;
                reports_deleted_list_tmp = reports_deleted_list;
                reports_deleted_list_tmp(how_many_del_tmp) = report_delete;
                
                % reports with current checking report
                reports_1 = reports_noise;
                reports_1(reports_deleted_list,:) = [];
                
                
                % reports without current checking report
                reports_2 = reports_noise;
                reports_2(reports_deleted_list_tmp,:) = [];
                
                % compare the RMSE between two report set 1 and 2
                [recon_reports_1] = report_set_recon_data(reports_1,events);
                [recon_reports_2] = report_set_recon_data(reports_2,events);
                RMSE_1and2 = sqrt(mean((recon_reports_1 - recon_reports_2).^2));
                
                % check if current report should delete or not
                if (RMSE_1and2 >= threshold_rmse_del)
                    reports_final = reports_2;
                    
                    how_many_del = how_many_del+1;
                    reports_deleted_list(how_many_del) = report_delete;
                end
                
                loop_point = loop_point-1; % from the end to the start
            end
            
            [recon_reports_final] = report_set_recon_data(reports_final,events);
            RMSE_IP_SRMSE = sqrt(mean((recon_reports_final - events).^2));
            
            % gather the RMSE
            RMSE_total = zeros(3,1);
            RMSE_total(1) = RMSE_Noise;
            RMSE_total(2) = RMSE_Clean;
            RMSE_total(3) = RMSE_IP_SRMSE;
            
            str_RMSE_Noise.(name_txt) = RMSE_Noise;
            str_RMSE_Clean.(name_txt) = RMSE_Clean;
            str_RMSE_IP_Spike_SRMSE.(name_txt) = RMSE_IP_SRMSE;
            
            str_RMSE_total.(name_txt) = RMSE_total;
            
            
            % confusion matrix
            size_reports_cm =  size(reports_ini);
            size_reports_cm = size_reports_cm(1);
            
            noise_reports_target = noise_reports;
            noise_reports_predict = reports_deleted_list;
            
            % init
            reports_target = zeros(size_reports_cm,1);
            reports_group = zeros(size_reports_cm,1);
            
            % set non noise reports
            reports_target(1:size_reports_cm) = 1;
            reports_group(1:size_reports_cm) = 1;
            
            % set noise reports
            reports_target(noise_reports_target) = 2;
            reports_group(noise_reports_predict) = 2;
            
            % confusion matrix
            % cm(1,1) = TP, cm(1,2) = FN, cm(2,1)=FP, cm(2,2)=TN
            % True Positive Rate = TP/(TP+FN)
            % True Negative Rate: TN/(TN+FP)
            % Accuracy: (TP+TN)/ALL
            % ROC curve: FPR(1-TNR) vs TPR
            CM = confusionmat(reports_target,reports_group,'Order',[2 1]);
            
            TPR = CM(1,1)/(CM(1,1) + CM(1,2));
            TNR = CM(2,2)/(CM(2,1) + CM(2,2));
            FPR = 1 - TNR;
            Acc = (CM(1,1) + CM(2,2))/(CM(1,1) + CM(1,2) + CM(2,1) + CM(2,2));
            
            name_txt_cm = strcat(name_txt);
            str_CM.(name_txt_cm) = CM;
            str_TPR.(name_txt_cm) = TPR;
            str_FPR.(name_txt_cm) = FPR;
            str_Acc.(name_txt_cm) = Acc;
            
            
        end %end of for i = 1: length(severe_ratio)
    end % end of for i_noise = 1: length(noise_number)
end %end of for nDisease

%save all variables
variableName = strcat(folder0,'Results_All_IP_Spike_RMSE.mat');
save(variableName,'str_Acc', 'str_RMSE_Noise', 'str_RMSE_Clean',...
    'str_RMSE_IP_Spike_SRMSE');

