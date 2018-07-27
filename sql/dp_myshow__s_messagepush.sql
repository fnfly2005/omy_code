/*开售提醒信息表*/
select
    substr(CreateTime,1,10) as dt,
    phonenumber as mobile,
    performanceid as performance_id
from
    origindb.dp_myshow__s_messagepush 
where
    phonenumber is not null
    and CreateTime>'2018-03-01'
    and regexp_like(phonenumber,'^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$')
    and phonenumber not in (13800138000,13000000000)
