/*演出项目信息表*/
select
    PerformanceID,
    CategoryID,
    cityid,
    bsperformanceid,
    TicketStatus
from
    origindb.dp_myshow__s_performance
where
    PerformanceID is not null
