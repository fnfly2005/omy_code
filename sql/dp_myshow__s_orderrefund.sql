/*退货单表*/
select
    orderid order_id
from
    origindb.dp_myshow__s_orderrefund
where
    orderrefundid is not null
    and finishtime is not null
