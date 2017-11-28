/*演出项目信息表*/
select
    PerformanceID,
    CategoryID
from
    S_Performance
where
    PerformanceID is not null
