/*订单关联实名制用户购票信息*/
select
    OrderID,
    PerformanceID,
    UserName,
    IDType,
    IDNumber
from
    S_OrderIdentification
where
    OrderID>=-time1
    and OrderID<-time2
