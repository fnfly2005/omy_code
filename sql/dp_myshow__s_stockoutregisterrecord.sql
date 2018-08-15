/*缺货登记明细表*/
select
    stockoutregisterstatisticid,
    usermobileno as mobile,
    smssendstatus,
    sellchannel,
    mtuserid,
    createtime
from
    origindb.dp_myshow__s_stockoutregisterrecord
where
    createtime>='$$begindate'
    and createtime<'$$enddate'
