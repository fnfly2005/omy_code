
select
    mobile,
    max(substr(create_time,1,10)) as dt
from
    passport_user
where
    mobile is not null
    and length(mobile)=11
    and substr(mobile,1,2)>='13'
group by
    1
;
