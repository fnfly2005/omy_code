/*缺货登记统计表*/
select
    stockoutregisterstatisticid,
    performanceid as performance_id,
    showid show_id,
    showname show_name,
    ticketprice as ticket_price
from
    origindb.dp_myshow__s_stockoutregisterstatistic
where
    1=1
