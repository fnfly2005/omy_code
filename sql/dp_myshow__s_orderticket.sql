/*检票记录表*/
select
    orderID as order_id,
    qrcode
from
    origindb.dp_myshow__s_orderticket
where
    CreateTime>='$$begindate'
    and CreateTime<'$$enddate'
