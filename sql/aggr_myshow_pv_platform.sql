select 
    partition_date,
    sum(uv) as uv
from 
    mart_movie.aggr_myshow_pv_platform
where 
    partition_date>='$$begindate'
    and partition_date<'$$enddate'
group by 
    1
