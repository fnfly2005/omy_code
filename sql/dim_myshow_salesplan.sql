/*销售计划维表*/
select
    shop_id,
    category_name,
    show_starttime,
    performance_id,
    performance_name,
    show_id,
    ticket_price,
    salesplan_ontime,
    salesplan_createtime,
    customer_id,
    customer_name,
    customer_type_name,
    customer_lvl1_name,
    city_name
from
    mart_movie.dim_myshow_salesplan
