/*预售短信提醒信息表*/
select
    substr(CreateTime,1,10) as dt,
    phonenumber as mobile,
    performanceid as performance_id
from
    origindb.dp_myshow__s_messagepush 
where
    phonenumber is not null
    and CreateTime>'2018-03-01'
