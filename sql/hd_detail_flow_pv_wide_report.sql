/*新美大流量宽表-活动*/
select
    partition_date as dt,
    app_name,
    url_parameters,
    substr(url,40,40) as url,
    page_name,
    union_id
from mart_flow.detail_flow_pv_wide_report
where partition_date>='$$begindate'
    and partition_date<'$$enddate'
    and partition_log_channel='firework'
    and partition_app in (
    'movie',
    'dianping_nova',
    'other_app',
    'dp_m',
    'group'
    )
    and page_bg='猫眼文化'
