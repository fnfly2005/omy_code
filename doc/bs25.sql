
select
    substr(CreateTime,1,10) as dt,
    count(distinct phonenumber) mp_num
from
    origindb.dp_myshow__s_messagepush
where
    phonenumber is not null
    and CreateTime>='$$begindate'
    and CreateTime<'$$enddate'
    and sellchannel<>8
group by
    1
;
