function [IP_threshold_new] = Find_IP_threshold_using_Slope(IP, threshold_times)
        % Find the IP threshold using slope of sorted-IP distribution.
        % sort IP.
        [E,index] = sortrows(IP,3);
        size_IP = size(IP);
        size_IP = size_IP(1);
        IP_sorted = E(:,3);
        
        % find slope of sort-IP
        slope = zeros(size_IP-1,1);
        for k = 2: size_IP
            slope(k-1) = IP_sorted(k) - IP_sorted(k-1);
        end
        
        % find the IP threshold 
        % only check the IP>IP_too_small
        IP_too_small = 0.1;
        slope_IP = [slope(:) IP_sorted(2:size_IP)];
        index_cut = find(slope_IP(:,2) > IP_too_small);
        slope_IP_cut = slope_IP(index_cut,:);
        
        
        %[slope_IP_cut_sorted, index_slope_IP] = sortrows(slope_IP_cut,1,'descend');
        
        % using the value = slope_avg * threshold_times as the slope
        % threshold to find the first IP point whose slope is larger than the
        % slope threshold
        % threshold_times = 100;
       
        slope_avg = mean(slope);
        threshold_slope = slope_avg * threshold_times;
        

        % find the first point whose slope larger than the threshold_slope
        slope_large_index = find(slope_IP_cut(:,1) > threshold_slope);
        IP_threshold_new = slope_IP_cut(slope_large_index(1),2);
end

