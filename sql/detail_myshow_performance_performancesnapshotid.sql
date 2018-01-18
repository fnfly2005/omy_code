/*项目状态快照表*/
select
    partition_date,
    performance_id
from
    mart_movie.detail_myshow_performance_performancesnapshotid
where
    ticketstatus in (2,3)
    and editstatus=1
    and partition_date>='2017-12-04'
    and partition_date<'2017-12-20'
