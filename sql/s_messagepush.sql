/*开售提醒表*/
select
    PhoneNumber mobile,
    PerformanceID
from
    S_MessagePush
where
    PhoneNumber is not null
