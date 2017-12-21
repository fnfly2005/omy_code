/*客户维表*/
select
   customer_id,
   case when customer_type_id=1 then customer_shortname
   else customer_type_name end customer_type_name,
   customer_type_id
from
    mart_movie.dim_myshow_customer
where
    customer_id is not null