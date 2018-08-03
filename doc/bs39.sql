
select
    partition_date as dt,
    approx_distinct(union_id) as uv
from mart_flow.detail_flow_mv_wide_report where partition_date>='$$begindate' and partition_date<'$$enddate' and partition_log_channel='movie' and partition_app in ( 'movie', 'dianping_nova', 'other_app', 'dp_m', 'group' )
    and partition_app='other_app'
    and app_name='gewara'
    and page_identifier='c_f740bkf7'
group by
    1
;
