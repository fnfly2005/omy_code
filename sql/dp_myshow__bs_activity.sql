/*演出商品表*/
select
    ActivityID,
    TicketStatus,
    EditStatus,
    TPID
from
    origindb.dp_myshow__bs_activity
where
    TPID is not null
