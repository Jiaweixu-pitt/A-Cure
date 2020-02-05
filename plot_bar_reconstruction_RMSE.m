function [flag] = plot_bar_reconstruction_RMSE(disease, startPoint, endPoint, ...
    IP_Cumulative_str_RMSE_Noise,...
    IP_Cumulative_str_RMSE_IP_Cumulative_SRMSE,...
    IP_Spike_SRMSE_str_RMSE_IP_Spike_SRMSE,...
    IP_EF_SRMSE_str_RMSE_IP_EF_LSQ, ...
    IP_Cumulative_str_RMSE_Clean)

% plot reconstruction RMSE for a certain disease data
% initialize
field_cumu_noise = fieldnames(IP_Cumulative_str_RMSE_Noise);
field_cumu_clean = fieldnames(IP_Cumulative_str_RMSE_Clean);
field_cumu = fieldnames(IP_Cumulative_str_RMSE_IP_Cumulative_SRMSE);
field_spike = fieldnames(IP_Spike_SRMSE_str_RMSE_IP_Spike_SRMSE);
field_EF = fieldnames(IP_EF_SRMSE_str_RMSE_IP_EF_LSQ);
num_bars = 20;
disease_y = zeros(num_bars,1);

order = 1;

% collect data
for i = startPoint:endPoint
    disease_y(order) = IP_Cumulative_str_RMSE_Noise.(field_cumu_noise{i});
    disease_y(order + 1) = IP_Cumulative_str_RMSE_IP_Cumulative_SRMSE.(field_cumu{i});
    disease_y(order + 2) = IP_Spike_SRMSE_str_RMSE_IP_Spike_SRMSE.(field_spike{i});
    disease_y(order + 3) = IP_EF_SRMSE_str_RMSE_IP_EF_LSQ.(field_EF{i});
    disease_y(order + 4) = IP_Cumulative_str_RMSE_Clean.(field_cumu_clean{i});
    order = order + 5;
end

% plot bar of the RMSE data
disease_y_rs = reshape(disease_y',[5,4]);
disease_y_rs_2 = disease_y_rs';
X = categorical({'Small portion low severity noise','Small portion high severity noise','large portion low severity noise','large portion high severity noise'});
X = reordercats(X, {'Small portion low severity noise','Small portion high severity noise','large portion low severity noise','large portion high severity noise'});

h1 = bar(X, disease_y_rs_2);
legend(h1,{'LSQ_Noise', 'IP_Cumulative_SRMSE', 'IP_Spike_SRMSE', 'IP_EF_SRMSE', 'LSQ_Clean'}, 'Interpreter', 'none', 'Location','northwest');
name_title = strcat('Reconstruction RMSE: ', disease);
title(name_title);
ylabel('Reconstruction RMSE');

name_file = strcat(disease,'_RMSE.png');
saveas(gcf,name_file);
close(gcf);
flag = strcat('plot of construction RMSE for ',disease,' done');


end

