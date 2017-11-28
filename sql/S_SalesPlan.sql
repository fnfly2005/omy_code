/*销售计划表*/
select
    TicketClassID,
    TicketPrice,
    SellPrice
from
    S_SalesPlan
where
    OffTime>'-time2'
    and OnTime<='-time2'
    and CurrentAmount>0
