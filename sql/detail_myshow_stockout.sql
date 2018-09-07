/*演出缺货登记事实明细表*/
select
    mobile,
    dpuser_id,
    mtuser_id,
    sellchannel,
    smssendstatus,
    createtime,
    performance_id,
    show_id,
    ticketclass_id,
    ticketprice
from
    mart_movie.detail_myshow_stockout
where
    createtime>='$$begindate'
    and createtime<'$$enddate'
