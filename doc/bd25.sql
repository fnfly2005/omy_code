
select
    count(distinct mobile) num 
from (
    select PhoneNumber mobile, PerformanceID from S_MessagePush where PhoneNumber is not null
    and PerformanceID in (42526)
    ) mes
limit 100000;
