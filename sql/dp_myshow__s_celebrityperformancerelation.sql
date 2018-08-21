/*艺人项目关系表*/
select
    celebrityname,
    performanceid as performance_id
from
    origindb.dp_myshow__s_celebrityperformancerelation
where
    status<>0
