/*快递记录表*/
select
    OrderID,
    CityName,
    ExpressFee
from
    S_OrderDelivery
where
    OrderID>=-time1
    and OrderID<-time2
