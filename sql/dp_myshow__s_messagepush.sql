/*开售提醒信息表*/
select
    CreateTime,
    phonenumber as mobile,
    sellchannel,
    performanceid as performance_id
from
    origindb.dp_myshow__s_messagepush 
where
    phonenumber is not null
    and createtime>='$$begindate'
    and createtime<'$$enddate'
