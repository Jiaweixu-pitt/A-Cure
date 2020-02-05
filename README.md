# A-Cure: An Accurate Information Reconstruction from Inaccurate Data Sources
Storage and Share of A-Cure Matlab Code

This is the Matlab code for A-Cure. It applies 
  1. IP-EF-SRMSE method (best of all three)
  2. IP-Spike-SRMSE method
  3. IP-Cumulative-SRMSE method
  
  to dectect/delete noisy reports and reconstruct four disease data from aggregated reports set including both normal and noisy reports.

More detail in reference: Jiawei Xu, Vladimir Zadorozhny, and John Grant. IncompFuse: **A-Cure**: An Accurate Information Reconstruction from Inaccurate Data Sources. Information Systems.

More detail for IP in reference: Xu, Jiawei, Vladimir Zadorozhny, and John Grant. "**IncompFuse**: a logical framework for historical information fusion with inaccurate data sources." Journal of Intelligent Information Systems (2019): 1-19.

## 1. How to run

1. Download/Clone the A-Cure project as A-Cure.zip.

2. Extract it and you should have the A-Cure folder containing all code.

3. Open Matlab (We ran this code on Matlab R2018a), 
	- add the A-Cure folder to path, 
	- **click into** the A-Cure folder (A-Cure folder should be the "current folder" for Matlab. You can execute pwd() in the command window to check it),
	- delete the folder **outPut**. (if this fold not deleted, it will show a Warning when running the code, but it is ok)
	- execute the folowing command in the command window: run_A_Cure (or open the file run_A_Cure.m and run the code)
	- the running process is:
	
	![image of running process](https://github.com/Jiaweixu-pitt/A-Cure/blob/master/img_for_readme/output_explain_2.png)
	
4. Results and explanation of variables

	![image of results](https://github.com/Jiaweixu-pitt/A-Cure/blob/master/img_for_readme/output_explain_3.png)

	- Acc: Accuracy
	- RMSE_Clean: reconstruction RMSE with the report sets wihout noisy reports (using Least Square method if not mentioned)
	- RMSE_Noise: reconstruction RMSE with the report sets wih noisy reports (using Least Square method if not mentioned)
	- RMSE_[method]: reconstruction RMSE with the cleaned report sets by a certain method, IP_Cumulative_SRMSE, IP_Spkie_SRMSE, or IP_EF_SRMSE
	
5. Output
	1. **Folder**: outPut
	![image of results](https://github.com/Jiaweixu-pitt/A-Cure/blob/master/img_for_readme/output_explain.png)
		- explanation of experimental settings (please check the paper for details):
			- NoiP10_NoiS2: 'Small portion low severity noise',
			- NoiP10_NoiS4: 'Small portion high severity noise',
			- NoiP20_NoiS2: 'large portion low severity noise',
			- NoiP20_NoiS4: 'large portion high severity noise'.
	
	2. **Image**: Reconstruction RMSE of different diseases using different methods with different experimental settings:
		- **Measles**: Measles_RMSE.png
		![image of Measles](https://github.com/Jiaweixu-pitt/A-Cure/blob/master/Measles_RMSE.png)
		
		- **Hepatitis**: Hepatitis_RMSE.png
		![image of Hepatitis](https://github.com/Jiaweixu-pitt/A-Cure/blob/master/Hepatitis_RMSE.png)
		
		- **Pertussis**: Pertussis_RMSE.png
		![image of Pertussis](https://github.com/Jiaweixu-pitt/A-Cure/blob/master/Pertussis_RMSE.png)
		
		- **Smallpox**: Smallpox_RMSE.png
		![image of Smallpox](https://github.com/Jiaweixu-pitt/A-Cure/blob/master/Smallpox_RMSE.png)
	

## 2. IP-EF-SRMSE method
**Input**

	disease data: Tycho.mat from https://www.tycho.pitt.edu
  
**Output**
	
	folder: ../output/IP_EF_SRMSE
  
	result file: /output/IP_EF_SRMSE/Results_All_IP_EF_SRMSE.mat, including:
  
  	1. Accuracy:
  	-LSQ reconstruction applying noise detection/deletion with IP-EF-SRMSE method
  
  	2. All reconstruction RMSE including:
  	-hfuse and LSQ reconstruction	
  	-with noisy reports
  	-without noisy reports (clean)
  	-applying noise detection/deletion with IP-EF-SRMSE method
  
**Experimental Setup**:
	
	4 different diseases

	4 different report sets with different noise setting. For details please check the paper.
  
**Matlab Code dependencies:**

	IP-EF-SRMSE method:
	
	-IP_EF_SRMSE_func.m 
		-IP_calculation_v2_2.m:  % Create reports set based on the pre-defined parameters , % Modify the reports set by adding noisy reports based on the % pre-defined parameters, % calculate the IP, bip, pr, dr, % Also list the noisy reports.
		
			-collect_reports_norm.m: % Randomly create reports set using disease data and the pre-defined parameters. Reports have: start time, end time, total value
			
				-gen_report.m: % Generate report.
				
			-create_noise_report.m: % Randomly create noisy reports based the pre-defined parameters.
			
			-create_pair_reports.m: % Create all possible report pairs.
			
			-BIP.m: % Calculate BIP.
			
			-IP_v13_2.m: % Calculate IP.
			
				-duration_ratio.m: % Calculate the proximity ratio.
				
				-proximity_ratio_new_2.m: % Calculate the proximity ratio.
				
		-rep_constraint_equations_full.m: % Re-format the report: duration matrix, and total value, respectively.
		
		-Energy_Trans_M4.m: % Energy Flow algorithm to calculate the Energy of all report nodes.
		
		-Relative_Energy.m: % Obtain relative energy (E(i)/E_Max) from absolute energy.
		
		-sm_reconstr_2.m: % Use H-Fuse to reconstruct the disease data from the aggregated reports set.
		
		-lsq_reconstruct.m: % Use Least Square method to reconstruct the disease data from the aggregated reports set, and calculate RMSE.
		
		-lsq_reconstruct_only.m: % Use Least Square method to reconstruct the disease data from aggregated reports set.
		
		-gen_new_report_after_EFlow_Thresh.m: % Used in the section to provide reference for the 'Spike' threshold. neglect it if using an alternative way to define 'Spike'.
		
		-report_set_recon_data.m: % Used in the section as an alternative way to define the 'Spike' threshold, consists of two parts:
			-rep_constraint_equations_full.m % introduced before
			--lsq_reconstruct_only.m % introduced before
			

## 3. IP-Spike-SRMSE method
**Input**

	disease data: Tycho.mat from https://www.tycho.pitt.edu
  
**Output**
	
	folder: ../output/IP_Spike_SRMSE
  
	result file: /output/IP_Spike_SRMSE/Results_All_IP_Spike_SRMSE.mat, including:
  
  	1. Accuracy:
  	-LSQ reconstruction applying noise detection/deletion with the IP-Spike-SRMSE method
  
  	2. All reconstruction RMSE including:
  	-LSQ reconstruction	
  	-with noisy reports
  	-without noisy reports (clean)
  	-applying noise detection/deletion with the IP-Spike-SRMSE method
  
**Experimental Setup**:
	
	4 different diseases

	4 different report sets with different noise setting. For details please check the paper.
  
**Matlab Code dependencies:**

	IP-Spike-SRMSE method:
	
	-IP_Spike_SRMSE_func.m 
		-IP_calculation_v2_2.m:  % Create reports set based on the pre-defined parameters , % Modify the reports set by adding noisy reports based on the, % pre-defined parameters, % calculate the IP, BIP, pr, dr, % Also list the noisy reports.
		
			-collect_reports_norm.m: % Randomly create reports set using disease data and the pre-defined parameters. Reports have: start time, end time, total value
			
				-gen_report.m: % Generate report.
				
			-create_noise_report.m: % Randomly create noisy reports based the pre-defined parameters.
			
			-create_pair_reports.m: % Create all possible report pairs. 
			
			-BIP.m: % Calculate BIP.
			
			-IP_v13_2.m: % Calculate IP.
			
				-duration_ratio.m: % Calculate the proximity ratio.
				
				-proximity_ratio_new_2.m: % Calculate the proximity ratio.
				
		-rep_constraint_equations_full.m: % Re-format the report: duration matrix, and total value, respectively.
		
		-Find_IP_threshold_using_Slope.m: % Find the IP threshold using slope, detials in the paper.
		
		-lsq_reconstruct.m: % Use the Least Square method to reconstruct the disease data from the aggregated reports set, and calculate RMSE.
		
		-lsq_reconstruct_only.m: % Use the Least Square method to reconstruct the disease data from aggregated reports set.
				
		-report_set_recon_data.m: % Used in the section as an alternative way to define the 'Spike' threshold, consists of two parts:
			-rep_constraint_equations_full.m % See earlier.
			--lsq_reconstruct_only.m % See earlier.
			
## 4. IP-Cumulative-SRMSE method
**Input**

	disease data: Tycho.mat from https://www.tycho.pitt.edu
  
**Output**
	
	folder: ../output/IP_Cumulative_SRMSE
  
	result file: /output/IP_Cumulative_SRMSE/Results_All_IP_Cumulative_SRMSE.mat, including:
  
  	1. Accuracy:
  	-LSQ reconstruction applying noise detection/deletion with the IP-Cumulative-SRMSE method
  
  	2. All reconstruction RMSE including:
  	-LSQ reconstruction	
  	-with noisy reports
  	-without noisy reports (clean)
  	-applying noise detection/deletion with the IP-Cumulative-SRMSE method
  
**Experimental Setup**:
	
	4 different diseases

	4 different report sets with different noise setting. For details please check the paper.
  
**Matlab Code dependencies:**

	IP-Cumulative-SRMSE method:
	
	-IP_Cumulative_SRMSE_func.m 
		-IP_calculation_v2_2.m:  % Create reports set based on the pre-defined parameters , % Modify the reports set by adding noisy reports based on the % pre-defined parameters, % calculate the IP, BIP, pr, dr, % Also list the noisy reports.
		
			-collect_reports_norm.m: % Randomly create reports set using disease data and the pre-defined parameters. Reports have: start time, end time, total value
			
				-gen_report.m: % Generate report.
				
			-create_noise_report.m: % Randomly create noisy reports based on the pre-defined parameters.
			
			-create_pair_reports.m: % Create all possible report pairs. 
			
			-BIP.m: % Calculate the BIP.
			
			-IP_v13_2.m: % Calculate the IP.
			
				-duration_ratio.m: % Calculate the duration ratio.
				
				-proximity_ratio_new_2.m: % Calculate the proximity ratio.
				
		-rep_constraint_equations_full.m: % Re-format the report: duration matrix, and total value, respectively.		
		
		-lsq_reconstruct.m: % Use the Least Square method to reconstruct the disease data from the aggregated reports set, and calculate RMSE.
		
		-lsq_reconstruct_only.m: % Use the Least Square method to reconstruct the disease data from the aggregated reports set.
		
		-report_set_recon_data.m: % Used in the section as an alternative way to define the 'Spike' threshold, consist of two parts:
			-rep_constraint_equations_full.m % See earlier.
			--lsq_reconstruct_only.m % See earlier.
			
