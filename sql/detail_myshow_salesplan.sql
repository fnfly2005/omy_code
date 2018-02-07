/*销售计划明细表*/
select
    partition_date as dt,
    performance_id,
    customer_id,
    shop_id,
    show_id,
    salesplan_sellout_flag,
    project_id,
    salesplan_id
from
    mart_movie.detail_myshow_salesplan
where
    salesplan_id is not null
    and partition_date>='$$today{-1d}'
    and partition_date<'$$today{-0d}'
