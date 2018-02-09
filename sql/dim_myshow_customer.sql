/*客户维表*/
select
   customer_id,
   customer_type_id,
   customer_type_name,
   customer_lvl1_name,
   customer_name,
   customer_code
from
    mart_movie.dim_myshow_customer
where
    customer_id is not null
