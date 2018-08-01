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
    category_id
from 
    mart_movie.detail_myshow_pv_wide_report
where partition_date>='$$begindate'
    and partition_date<'$$enddate'
    and partition_biz_bg=1
