/*实时订单表*/
select
    order_id,
    sellchannel,
    usermobileno as mobile,
    totalprice
from 
    upload_table.detail_myshow_s_order_realtime
where
    pay_time is not null
