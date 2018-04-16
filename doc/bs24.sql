
select distinct
    user_id
from
    mart_flow.detail_flow_pv_wide_report
where
    partition_date>='$$begindate'
    and partition_date<'$$enddate'
    and partition_log_channel='movie'
    and partition_app in (
    'movie',
    'dianping_nova',
    'dp_m',
    'group'
    )
    and page_identifier='c_Q7wY4'
    and user_id is not null
    and page_city_name in ('郑州')
;
