/*销售计划明细表*/
select
    partition_date as dt,
    performance_id,
    customer_type_id,
    customer_id,
    shop_id,
    show_id,
    salesplan_sellout_flag,
    project_id,
    salesplan_id,
    ticketclass_id,
    city_id,
    category_id,
    sell_price
from
    mart_movie.detail_myshow_salesplan
where
    1=1
    and partition_date>='$$begindate'
    and partition_date<'$$enddate'
