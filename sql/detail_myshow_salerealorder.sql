/*手工准实时订单表*/
select
    order_id,
    performance_id,
    sellchannel,
    usermobileno as mobile,
    totalprice
from 
    upload_table.detail_myshow_salerealorder
where
    pay_time is not null
