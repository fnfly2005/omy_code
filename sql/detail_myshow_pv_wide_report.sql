/*新美大流量宽表*/
select
    partition_date as dt,
    stat_time,
    app_name,
    page_name_my,
    page_city_name,
    union_id,
    performance_id,
    page_cat,
    category_id,
    pagedpcity_id,
    geodpcity_id,
    page_stay_time
from 
    mart_movie.detail_myshow_pv_wide_report
where partition_date>='$$begindate'
    and partition_date<'$$enddate'
