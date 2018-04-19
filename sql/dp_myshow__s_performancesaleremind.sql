/*项目定时开售提醒表*/
select
    PerformanceID as performance_id,
    OnSaleStatus,
    OnSaleTime,
    CountdownTime,
    NeedRemind
from
    origindb.dp_myshow__s_performancesaleremind
where
    Status=1
