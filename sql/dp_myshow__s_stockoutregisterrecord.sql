/*缺货登记明细表*/
select
    stockoutregisterstatisticid,
    usermobileno as mobile,
    smssendstatus,
    sellchannel
from
    origindb.dp_myshow__s_stockoutregisterrecord
where
    1=1
