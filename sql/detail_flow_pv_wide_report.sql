/*新美大流量PV宽表*/
select
    partition_date,
    app_name,
    session_id,
    union_id,
    page_id
from
    mart_flow.detail_flow_pv_wide_report
where
    partition_date>='-time1'
    and partition_date<'-time2'
