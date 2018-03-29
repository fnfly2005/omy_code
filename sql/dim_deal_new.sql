/*团单项目维表*/
select
    deal_id,
    customerid as customer_code,
    title,
    regexp_extract(cityids,'[0-9]+') as mt_city_id
from
    mart_movie.dim_deal_new
where
    category=12
