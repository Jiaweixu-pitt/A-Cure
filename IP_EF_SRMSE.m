% This is the main code for A-Cure. It applys IP-(IG)-EF-SRMSE method
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
% folder: output
% result file: /output/Results_All.mat, including:
% 1. Accuracy
% LSQ reconstruction applying noise detection/deletion with IP-EF-SRMSE method
%
% 2. All reconstruction RMSE including:
% hfuse and LSQ reconstruction
% with noisy reports
% without noisy reports (clean)
% applying noise detection/deletion with IP-EF-SRMSE method
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
output_folder = strcat(pwd,'\outPut_test_2\');
folder0 = output_folder;

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
            
            % create output folder for differnt disease and parameters setting
            folder = sprintf('%s%s\\%s%s\\',folder0,deseaseS,noise_level(i_noise),noise_severity_level(i));
            mkdir(folder);
            
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
            
            % re-format the report: duration matrix, and total value, respectively
            [reports_duration_cell.(name_txt_disease),reports_values_cell.(name_txt_disease)]=rep_constraint_equations_full(reports_cell.(name_txt_disease),events);
            
            
            % create M1(the initial Incompatability Graph (IG)) using IP
            % size of IP pairs
            size_IP =  size(IP);
            size_IP = size_IP(1);
            
            % size of report set
            A = reports_ini;
            size_A = size(A);
            num_reports = size_A(1);
            M1 = zeros(num_reports, num_reports);
            
            % in this paper,
            % if IP>0.5, the pair i_j is incompatable, the edge between i
            % and j is 1
            % if IP<=0.5, the pair i_j is incompatable, the edge between i
            % and j is 0
            % Other IP-threshold is also OK.
            IP_threshold = 0.5;
            for i_IP = 1:size_IP
                if (IP(i_IP,3) > IP_threshold)
                    M1(IP(i_IP,1),IP(i_IP,2)) = 1;
                    M1(IP(i_IP,2),IP(i_IP,1)) = 1;
                end
            end
            
            
            % Energy Flow algorithm to calculate the Energy of all reports
            % nodes.
            [ Energy, M4, timeCalculation, sumEnergy, sumEnergyEnd] = Energy_Trans_M4( num_reports, M1 );
            
            % Obtaining relative energy (E(i)/E_Max) from absolute Energy
            [ Energy_Relative_cell.(name_txt) ] = Relative_Energy( num_reports, Energy );
            
            %**************************************************************
            % the following section is a trial version (not used in this paper) of applying SRMSE to
            % detect the noisy reports.
            % The only usage of this section is to provide a reference for a
            % threshold to detect the 'spike' of S-RMSE.
            % if you use alternative way to find a threshold, for example the way in the next section
            % below, you don't need this section.
            threshE = 1:-0.01:0;
            length_threshE = length(threshE);
            recon_err = zeros(length_threshE,1);
            recon_num_reports = zeros(length_threshE,1);
            sizeNoneZero = length_threshE;
            for j = 1:length_threshE
                [ reports_duration_E,reports_values_E ] = ...
                    gen_new_report_after_EFlow_Thresh( Energy_Relative_cell.(name_txt),threshE(j), reports_cell.(name_txt_disease), reports_duration_cell.(name_txt_disease), reports_values_cell.(name_txt_disease));
                % if the number of reports = 0, break:
                if( isempty(reports_values_E))
                    sizeNoneZero = j-1;
                    break;
                    
                end
                %
                
                % RMSE with true events
                [recon_events_E0, recon_error_E0]=lsq_reconstruct(reports_duration_E, reports_values_E,events);
                recon_err0(j) =  recon_error_E0;
                recon_num_reports0(j) = length(reports_values_E);
                
                % sequencial RMSE, RMSE between n and n+1
                if(j == 1)
                    [recon_events_E, recon_error_E]=lsq_reconstruct(reports_duration_E, reports_values_E,events);
                else
                    [recon_events_E, recon_error_E]=lsq_reconstruct(reports_duration_E, reports_values_E,recon_events_E_cell{j-1});
                end
                recon_err(j) =  recon_error_E;
                recon_events_E_cell{j} = recon_events_E;
                recon_num_reports(j) = length(reports_values_E);
            end
            
            RMSE_best_1stMethod = min(recon_err0);
            
            %{
            % the following plot is SRMSE vs Energy-threshold and the
            % position of the noisy reports using the trial version of
            % SRMSE method (not used in this paper)
            
            legendString = sprintf('severe = %0.1f',severe_ratio(i));
            % plot energy_threshold vs S-RMSE
            plot(threshE(2:sizeNoneZero),recon_err(2:sizeNoneZero),'DisplayName',legendString,'Marker','o');
            hold on;
            %plot the noise reports Energy position
            y = [0,1000];
            noise_reports = [severe_reports_list, Energy_Relative_cell.(name_txt)(severe_reports_list)];
            for i_t =1:length(severe_reports_list)
                x0 = noise_reports(i_t,2);
                x =[x0,x0];
                plot(x,y);
            end
                     
            titleString = sprintf('Relative-RMSE vs Energy Threshold for %s,\n#report = %d, reports duration = %d, version IG = IP1',deseaseS,mu_rn,mu_rd);

            title(titleString);
            % xlabel
            xlabel('Energy Threshold');
            %xlabel('number of reports with a certain Energy Threshold');
            %ylabel
            ylabel('RMSE');
            %ylabel('# of reports');
            %legend('show');
            %figureString = sprintf('reports_threshE_for_%s_#report_%d_reports_duration_%d_version_IG_%d',deseaseS,mu_rn,mu_rd, version_IG);
            figureString = sprintf('Relative-RMSE_of_different_reports_severity_for_%s_#report_%d_reports_duration_%d_version_IG_IP',deseaseS,mu_rn,mu_rd);
            figureName= strcat(folder,figureString,'_report.jpg');
            saveas(gcf,figureName);
            close(gcf);
            % the above is plot code: SRMSE vs Energy-threshold
            %}           
            %**************************************************************
            % the above section is a trial version (not used in this paper) of applying SRMSE to
            % detect the noisy reports.
            
            
            %**************************************************************
            % the Following section is an alter way to define the threshold
            % for 'Spike'. The performance is also very good.
            %Sequential RMSE without delete any reports
            size_report_set = num_reports;
            reports_noise = reports_cell.(name_txt_disease);
            [recon_reports_noise, TOL] = report_set_recon_data(reports_noise,events);
            
            srmse_noise = zeros(size_report_set,1);
            for k = 1:size_report_set
                reports_del_one = reports_noise;
                reports_del_one(k,:) = [];
                [recon_reports_del_one, TOL2] = report_set_recon_data(reports_del_one,events);
                RMSE_del_one = sqrt(mean((recon_reports_del_one - recon_reports_noise).^2));
                srmse_noise(k) = RMSE_del_one;
            end
            
            mean_srmse_alternative_way = mean(srmse_noise);              
            %**************************************************************
            % the above section is an alter way to define the threshold
            % for 'Spike'. The performance is also very good.   
            
            
            % delete the reports which cause the spike larger than 
            % double of average of SRMSE screening in the section above
            % you can use an alternative way to define the threshold
            
            %threshold_E_spike = 0.4 * mean_srmse_alternative_way;
            threshold_E_spike = 2* mean(recon_err(2:sizeNoneZero));
            
            threshold_E = 0;
            threshold_reports = 2;
            
            % list the order of reports from 1 to num_reports
            col1_newEnergy = (1:1:num_reports);
            % create energy list: energy,order_number
            newEnergyList = [Energy_Relative_cell.(name_txt), col1_newEnergy'];
            % sort the energy list
            newEnergyList_sort = sortrows(newEnergyList,1);
            
            loop_point = num_reports;
            
            reports_deleted_list = int16.empty;
            reports_deleted_list_tmp = int16.empty;
            how_many_del = 0;
            how_many_del_tmp = 0;
            
            
            reports_duration_org_0 = reports_duration_cell.(name_txt_disease);
            reports_values_org_0 = reports_values_cell.(name_txt_disease);
            
            % Start the S-RMSE Screening process, for details please check the
            % paper.
            % screent the reports from highest energy to the lowsest one
            while( (newEnergyList_sort(loop_point,1) >= threshold_E) && ... % end if energy is smaller than threshold
                    loop_point >= threshold_reports ... % end if threshold # of reports have been checked
                    )
                report_delete = newEnergyList_sort(loop_point,2); %delete one report from the end
                how_many_del_tmp = how_many_del + 1;
                reports_deleted_list_tmp = reports_deleted_list;
                reports_deleted_list_tmp(how_many_del_tmp) = report_delete;
                
                reports_duration_org = reports_duration_org_0;
                reports_duration_org(reports_deleted_list,:) = [];
                reports_values_org = reports_values_org_0;
                reports_values_org(reports_deleted_list,:)=[];
                
                reports_duration_del = reports_duration_org_0;
                reports_duration_del(reports_deleted_list_tmp,:) = [];
                reports_values_del = reports_values_org_0;
                reports_values_del(reports_deleted_list_tmp,:)=[];
                
                [event_org]=lsq_reconstruct_only(reports_duration_org, reports_values_org);
                [event_del]=lsq_reconstruct_only(reports_duration_del, reports_values_del);
                
                error_del = sqrt(mean((event_del - event_org).^2));
                
                if (error_del >= threshold_E_spike)
                    reports_duration_org = reports_duration_del;
                    reports_values_org = reports_values_del;
                    
                    how_many_del = how_many_del+1;
                    reports_deleted_list(how_many_del) = report_delete;
                end
                
                loop_point = loop_point-1; % from the end to the start
            end
            
            % reconstruction with IP-EF
            [event_org]=lsq_reconstruct_only(reports_duration_org, reports_values_org);
            RMSE_Best_2ndMethod = sqrt(mean((event_org - events).^2));
            
            % reconstruction with LSQ (noise)
            event_noise = lsq_reconstruct_only(reports_duration_org_0, reports_values_org_0);
            RMSE_Noise = sqrt(mean((event_noise - events).^2));
            
            % reconstrution with LSQ (clean)
            reports_duration_clean = reports_duration_org_0;
            reports_duration_clean(severe_reports_list,:) = [];
            reports_values_clean = reports_values_org_0;
            reports_values_clean(severe_reports_list,:)=[];
            event_clean = lsq_reconstruct_only(reports_duration_clean, reports_values_clean);
            RMSE_clean = sqrt(mean((event_clean - events).^2));
            
            % applying HFuse method to do the reconstruction for noise, IP-EF, and clean reports sets
            % reference of HFuse paper:
            % Liu, Zongge, et al. "H-fuse: Efficient fusion of aggregated 
            % historical data." Proceedings of the 2017 SIAM International 
            % Conference on Data Mining. Society for Industrial and Applied
            % Mathematics, 2017.
            
            % HFuse with noise
            [recon_events_hfuse_noise, recon_error_hfuse_noise] = sm_reconstr_2(reports_duration_org_0, reports_values_org_0, events);
            
            % HFuse with IP-EF
            [recon_events_hfuse_IP_EF, recon_error_hfuse_IP_EF] = sm_reconstr_2(reports_duration_org, reports_values_org, events);
            
            % HFuse with clean
            [recon_events_hfuse_clean, recon_error_hfuse_clean] = sm_reconstr_2(reports_duration_clean, reports_values_clean, events);
            
            % storage the RMSE into the structure
            str_RMSE_IP_EF_LSQ.(name_txt)= RMSE_Best_2ndMethod;
            str_RMSE_Noise_LSQ.(name_txt) = RMSE_Noise;
            str_RMSE_clean_LSQ.(name_txt)= RMSE_clean;
            
            str_RMSE_IP_EF_hfuse.(name_txt)= recon_error_hfuse_IP_EF;
            str_RMSE_Noise_hfuse.(name_txt) = recon_error_hfuse_noise;
            str_RMSE_clean_hfuse.(name_txt)= recon_error_hfuse_clean;
            
            %save variables of RMSE to file
            RMSE_IP_EF_SRMSE = RMSE_Best_2ndMethod;
            variableName = strcat(folder,'variable_RMSE.mat');
            save(variableName,'RMSE_Noise','RMSE_IP_EF_SRMSE', 'RMSE_clean');
            
            %{
            The following sections are 2 plots:
            1. plot 3 RMSE to compare: 'Noise', 'IP-EF-SRMSE', 'Clean'
            2. plot noise sets VS delete sets by IP-EF-SRMSE method
            
            % Following section: plot 3 RMSE to compare
            x_bar = {'Noise', 'IP-EF-SRMSE', 'Clean'};
            y_bar = [RMSE_Noise,RMSE_Best_2ndMethod, RMSE_clean];
            figure1 = figure;
            % Create axes
            axes1 = axes('Parent',figure1);
            hold(axes1,'on');
            % Create bar
            bar(y_bar);
            box(axes1,'on');
            % Set the remaining axes properties
            set(axes1,'XTick',[1 2 3 4],'XTickLabel',x_bar);
            ylabel('RMSE');
            
            figureString1 = sprintf('Three_RMSE__for_%s_#report_%d_reports_duration_%d_version_IG_IP',deseaseS,mu_rn,mu_rd);
            figureName1= strcat(folder,figureString1,'_report.jpg');
            figureName11= strcat(folder,figureString1,'_report.fig');
            saveas(gcf,figureName1);
            saveas(gcf,figureName11);
            close(gcf);
            % Above section: plot 3 RMSE to compare
            
            % Following section: plot noise sets VS delete sets by IP-EF-SRMSE method
            y_plot = ones(length(reports_deleted_list),1);
            scatter(reports_deleted_list,y_plot,'Marker','x');
            hold on
            
            y2_plot = zeros(length(severe_reports_list),1);
            scatter(severe_reports_list,y2_plot);
            
            %plot the noise reports Energy position
            y = [0,2];
            
            for i_t =1:length(severe_reports_list)
                x0 = severe_reports_list(i_t);
                x =[x0,x0];
                plot(x,y,'LineStyle','--','Color',[0 1 0]);
                
            end
            
            set(gca,'YLim',[0 2],'YTick',0:1,'YTickLabel',{'Noise Reports';'Deleted Reports'});
            title('Noise reports VS Reports deleted through 2nd Method');
            %xlabel
            xlabel('Reports order');
            figureString2 = sprintf('Noise_Reportse_VS_Reports_deleted__for_%s_#report_%d_reports_duration_%d_version_IG_IP',deseaseS,mu_rn,mu_rd);
            figureName2= strcat(folder,figureString2,'_report.jpg');
            saveas(gcf,figureName2);
            close(gcf);
            % above section: plot noise sets VS delete sets by IP-EF-SRMSE method
                       
            %}
            % The above sections are 2 plots:
            % 1. plot 3 RMSE to compare: 'Noise', 'IP-EF-SRMSE', 'Clean'
            % 2. plot noise sets VS delete sets by IP-EF-SRMSE method
            
            % confusion matrix
            size_reports_cm =  size(reports_ini);
            size_reports_cm = size_reports_cm(1);
            
            noise_reports_target = severe_reports_list;
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
variableName = strcat(folder0,'Results_All.mat');
save(variableName,'str_Acc', 'str_RMSE_clean_hfuse', 'str_RMSE_clean_LSQ',...
    'str_RMSE_IP_EF_hfuse','str_RMSE_IP_EF_LSQ',...
    'str_RMSE_Noise_hfuse', 'str_RMSE_Noise_LSQ');

