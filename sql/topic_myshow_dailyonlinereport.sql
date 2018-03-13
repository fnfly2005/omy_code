/*事业部KPI报表-在线*/
select
    partition_date as dt,
    customer_type_id,
    area_1_level_name,
    online_performance_num ap_num
from
    mart_movie.topic_myshow_dailyonlinereport
where
    partition_date='$$yesterday'
