/*新美大流量宽表*/
select
    partition_date,
    union_id
from
    mart_flow.detail_flow_pv_wide_report
where
    partition_date>='-time1'
    and partition_date<'-time2'
