/*快递记录表*/
select
    OrderID,
    ExpressFee
from
    S_OrderDelivery
where
    OrderDeliveryID is not null
    and CreateTime>='-time3'
    and CreateTime<'-time2'
