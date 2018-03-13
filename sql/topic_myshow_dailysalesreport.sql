/*事业部KPI报表-在线*/
select
    partition_date as dt,
    customer_type_id,
    area_1_level_name,
    performance_num sp_num,
    round(TotalPrice,0) TotalPrice,
    round(GrossProfit,0) GrossProfit
from
    mart_movie.topic_myshow_dailyonlinereport
where
    partition_date='$$yesterday'
