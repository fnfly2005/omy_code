/*退货单表*/
select
    orderid order_id,
    case when finishtime is null then 0
    else 1 end as issuc
from
    origindb.dp_myshow__s_orderrefund
where
    orderrefundid is not null
    and createtime<'$$enddate'
