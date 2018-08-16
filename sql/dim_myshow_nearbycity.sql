/*演出附近城市*/
select
    dpcity_id,
    nearbydpcity_id,
    round(km_num,0) as km_num
from
    upload_table.dim_myshow_nearbycity
where
    1=1
