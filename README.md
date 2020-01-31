# A-Cure
Storage and Share of A-Cure Matlab Code

This is the Matlab code for A-Cure. It applies 
  1. IP-EF-SRMSE method
  2. IP-Spike-SRMSE method
  3. IP-Cumulative-SRMSE method
  
  to dectect/delete noisy reports and reconstruct four disease data from aggregated reports set including both normal and noisy reports

More detail in reference: Jiawei Xu, Vladimir Zadorozhny, and John Grant. IncompFuse: **A-Cure**: An Accurate Information Reconstruction from Inaccurate Data Sources. Information Systems.

More detail for IP in reference: Xu, Jiawei, Vladimir Zadorozhny, and John Grant. "**IncompFuse**: a logical framework for historical information fusion with inaccurate data sources." Journal of Intelligent Information Systems (2019): 1-19.
We ran this code on Matlab R2018a.

**Input**

	disease data: Tycho.mat from https://www.tycho.pitt.edu
  
**Output**
	
	folder: ../output/
  
	result file: /output/Results_All.mat, including:
  
  	1. Accuracy:
  	-LSQ reconstruction applying noise detection/deletion with IP-EF-SRMSE method
  
  	2. All reconstruction RMSE including:
  	-hfuse and LSQ reconstruction	
  	-with noisy reports
  	-without noisy reports (clean)
  	-applying noise detection/deletion with IP-EF-SRMSE method
  
**Experimental Setup**:
	
	4 different disease

	4 different reports set with different noise setting. Details please check the paper.
  
**Matlab Code dependencies:**

	1. IP-EF-SRMSE method:
	-IP_EF_SRMSE.m
		-IP_calculation_v2_2.m:  % Created reports set based on the pre-defined parameters , % Modify the reports set by adding noisy reports based on the, % pre-defined parameters, % calculate the IP, bip, pr, dr, % Also list the noisy reports.
			-collect_reports_norm.m: % Randomly create reports set using disease data and the pre-defined parameters. Reports have: start time, end time, total value
				-gen_report.m: % generate report
			-create_noise_report.m: % Randomly create noise reports based the pre-defined parameters.
			-create_pair_reports.m: % Create all possible reports pair 
			-BIP.m: % Calculate BIP for reports pair.
			-IP_v13_2.m: % Calculate IP for report pair.
				-duration_ratio.m: % Calculate the proximity ratio
				-proximity_ratio_new_2.m: % Calculate the proximity ratio
		-rep_constraint_equations_full.m: % re-format the report: duration matrix, and total value, respectively.
		-Energy_Trans_M4.m: % Energy Flow algorithm to calculate the Energy of all reports  nodes.
		-Relative_Energy.m: % Obtaining relative energy (E(i)/E_Max) from absolute Energy.
		-sm_reconstr_2.m: % using H-Fuse to reconstruct the disease data from aggregated reports set.
