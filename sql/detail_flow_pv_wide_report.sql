/*新美大流量宽表*/
select
    partition_date dt,
    union_id,
    case when page_id='40000390' then custom['performance_id'] end performance_id
from
    mart_flow.detail_flow_pv_wide_report
where
    partition_date>='$time1'
    and partition_date<'$time2'
