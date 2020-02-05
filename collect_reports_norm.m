function collected_reports = collect_reports_norm(events, m_num_of_reports,d_num_of_reports, m_reported_duration, d_reported_duration)
% collect multiple, possibly overlapping reports about the number of events within
% reported intervals
% 
%  
rng(1);
num_of_reports = round(m_num_of_reports + d_num_of_reports.*randn);
if num_of_reports <= 0 
         num_of_reports = 1;
end
collected_reports = zeros(num_of_reports,3);

for i = 1:num_of_reports
  max_time = length(events);
  from = randi(max_time-1);
  reported_duration = round(m_reported_duration + d_reported_duration.*randn);
  if reported_duration <= 0
      reported_duration = 1;
  end    
  tmp = from+reported_duration;
  if tmp <= max_time 
    to = tmp;
  else 
    to = max_time;
  end
  collected_reports(i,:) = gen_report(events, from, to); %%% total number of events
end  
end

