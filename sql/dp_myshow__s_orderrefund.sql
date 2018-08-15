/*退货单表*/
select
    orderid order_id
from
    origindb.dp_myshow__s_orderrefund
where
    1=1
    and finishtime is not null
