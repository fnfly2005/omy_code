/*票类表*/
select
    TicketClassID,
    PerformanceID,
    Description
from
    origindb.dp_myshow__s_ticketclass
where
    TicketClassID is not null
