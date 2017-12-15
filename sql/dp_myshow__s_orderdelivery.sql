/*快递记录表*/
select
    OrderID,
    ExpressFee
from
    origindb.dp_myshow__s_orderdelivery
where
    OrderDeliveryID is not null
    and CreateTime>='-time3'
    and CreateTime<'$time2'
