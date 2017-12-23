/*销售计划明细表*/
select
    partition_date,
    performance_id,
    customer_id,
    salesplan_sellout_flag
from
    mart_movie.detail_myshow_salesplan
where
    salesplan_id is not null
    and partition_date>='$time1'
    and partition_date<'$time2'
