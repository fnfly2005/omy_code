
select 
    cit.city_name,
    count(distinct case when customer_type_name='自营' then performance_id end) as us_num,
    count(distinct performance_id) pf_num
from 
    mart_movie.dim_myshow_city cit
    left join mart_movie.dim_myshow_salesplan ss
    on cit.city_id=ss.city_id
where
    salesplan_sellout_flag=0
group by 
    1
;
