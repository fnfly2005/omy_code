
select
    os,
    page_tag1,
    name,
    count(1) pv,
    count(distinct union_id) uv
from
    (
    select partition_date as dt, stat_time, app_name, page_identifier, os, custom, union_id from mart_flow.detail_flow_pv_wide_report where partition_date>='$time1' and partition_date<'$time2' and partition_log_channel='movie' and partition_app in ( select key from upload_table.myshow_dictionary where key_name='partition_app' ) and page_identifier in ( select value from upload_table.myshow_pv where key='page_identifier' )
    and app_name='gewara'
    ) fpw
    left join 
    (
    select page_tag1, value, name from upload_table.myshow_pv where key='page_identifier'
    and page='native'
    ) mp
    on fpw.page_identifier=mp.value
group by
    1,2,3
union all
select
    os,
    page_tag1,
    'all' as name,
    count(1) pv,
    count(distinct union_id) uv
from
    (
    select partition_date as dt, stat_time, app_name, page_identifier, os, custom, union_id from mart_flow.detail_flow_pv_wide_report where partition_date>='$time1' and partition_date<'$time2' and partition_log_channel='movie' and partition_app in ( select key from upload_table.myshow_dictionary where key_name='partition_app' ) and page_identifier in ( select value from upload_table.myshow_pv where key='page_identifier' )
    and app_name='gewara'
    ) fpw
    left join 
    (
    select page_tag1, value, name from upload_table.myshow_pv where key='page_identifier'
    and page='native'
    ) mp
    on fpw.page_identifier=mp.value
group by
    1,2,3
union all
select
    os,
    'all' page_tag1,
    'all' name,
    count(1) pv,
    count(distinct union_id) uv
from
    (
    select partition_date as dt, stat_time, app_name, page_identifier, os, custom, union_id from mart_flow.detail_flow_pv_wide_report where partition_date>='$time1' and partition_date<'$time2' and partition_log_channel='movie' and partition_app in ( select key from upload_table.myshow_dictionary where key_name='partition_app' ) and page_identifier in ( select value from upload_table.myshow_pv where key='page_identifier' )
    and app_name='gewara'
    ) fpw
    left join 
    (
    select page_tag1, value, name from upload_table.myshow_pv where key='page_identifier'
    and page='native'
    ) mp
    on fpw.page_identifier=mp.value
group by
    1,2,3
;
