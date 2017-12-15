/*销售计划表*/
select
    ShowID show_id,
    TPID customer_id,
    TicketClassID,
    TicketPrice,
    SellPrice
from
    origindb.dp_myshow__s_salesplan
where
    TPTicketStatus in (2,3)
    and (IsLimited = 1 
    or (IsLimited=0 and CurrentAmount>0))
