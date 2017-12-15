select
    customer_type_name,
    area_1_level_name,
    area_2_level_name,
    category_name,
    count(distinct performance_id) ap_num
from
    (
    select ShowID show_id, TPID customer_id, TicketClassID, TicketPrice, SellPrice from origindb.dp_myshow__s_salesplan where TPTicketStatus in (2,3) and (IsLimited = 1 or (IsLimited=0 and CurrentAmount>0))
    ) ssp
    join 
    (
    select show_id, performance_id, activity_id, category_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_show
    ) ds
    on ssp.show_id=ds.show_id
    left join
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_type_name, customer_type_id from mart_movie.dim_myshow_customer where customer_id is not null
    ) dc 
    on dc.customer_id=ssp.customer_id
group by
    1,2,3,4
    
