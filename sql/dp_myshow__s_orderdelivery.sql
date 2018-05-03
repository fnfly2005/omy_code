/*快递记录表*/
select
    OrderID,
    ExpressFee,
    fetchedtime as fetched_time
from
    origindb.dp_myshow__s_orderdelivery
where
    OrderDeliveryID is not null
