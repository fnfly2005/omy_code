/*退货单表*/
select
    orderid
from
    origindb.dp_myshow__s_orderrefund
where
    orderrefundid is not null
    and createtime>='-time3'
    and createtime<'$time2'
