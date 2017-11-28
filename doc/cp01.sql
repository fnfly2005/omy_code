/*分渠道页面跳失率*/
select
    partition_date,
    case app_name
        when 'group' then '美团'
        when 'dianping_nova' then '点评'
        when 'movie' then '猫眼'
        when 'dianping_movie_wx' then '微信站'
        when 'all' then '整体'
    end app_name,
    sv,
    jv
from
(select
    partition_date,
    app_name,
    count(distinct session_id) sv,
    count(distinct case when pv=1 then session_id end) jv
from
    (
    select
        partition_date,
        app_name,
        session_id,
        count(1) pv
    from (
    /*新美大流量PV宽表*/ select partition_date, app_name, session_id, union_id, page_id from mart_flow.detail_flow_pv_wide_report where partition_date>='2017-10-01' and partition_date<'2017-11-01'
    and app_name in ('group','dianping_nova','movie','dianping_movie_wx')
    and page_id=40000386
    ) dfp1
    group by
        1,2,3) df1
group by
    1,2
union all
select
    partition_date,
    'all' app_name,
    count(distinct session_id) sv,
    count(distinct case when pv=1 then session_id end) jv
from
    (
    select
        partition_date,
        session_id,
        count(1) pv
    from (
    /*新美大流量PV宽表*/ select partition_date, app_name, session_id, union_id, page_id from mart_flow.detail_flow_pv_wide_report where partition_date>='2017-10-01' and partition_date<'2017-11-01'
    and app_name in ('group','dianping_nova','movie','dianping_movie_wx')
    and page_id=40000386 
    ) dfp2
    group by
        1,2) df2
group by
    1,2) dfp 
