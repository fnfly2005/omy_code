
select
    fp1.dt,
    fp1.fromtag,
    uv,
    order_num
from (
    select
        dt,
        case when regexp_like(url_parameters,'[Ff]romTag=') then split_part(regexp_extract(url_parameters,'[Ff]romTag=[^&]+'),'=',2)
        when regexp_like(url,'fromTag%3D') then split_part(regexp_extract(url,'fromTag%3D[^%]+'),'%3D',2)
        when regexp_like(url,'from=') then split_part(regexp_extract(url,'from=[^&]+'),'=',2)
        else 'other'
        end as fromtag,
        approx_distinct(union_id) as uv
    from
        (
        select partition_date as dt, app_name, url_parameters, substr(url,40,40) as url, page_name, union_id from mart_flow.detail_flow_pv_wide_report where partition_date>='$$begindate' and partition_date<'$$enddate' and partition_log_channel='firework' and partition_app in ( 'movie', 'dianping_nova', 'other_app', 'dp_m', 'group' ) and page_bg='猫眼文化'
        and regexp_like(page_name,'$id')
        ) as fpw
    group by
        1,2
    ) fp1
    left join (
        select 
            partition_date as dt,
            case when regexp_like(substr(url,1,6),':') then split_part(regexp_extract(url,'[Ff]romTag=[^&]+'),'=',2)
            else split_part(regexp_extract(url,'fromTag%3D[^%]+'),'%3D',2)
            end as fromtag,
            count(distinct order_id) as order_num
        from mart_flow.detail_flow_mv_wide_report
        where partition_date>='$$begindate'
            and partition_date<'$$enddate'
            and partition_log_channel='movie'
            and partition_etl_source='2_5x'
            and partition_app in ('movie', 'dianping_nova', 'other_app', 'dp_m', 'group')
            and event_id='b_WLx9n'
        group by 
            1,2
        ) as fmw
    on fp1.dt=fmw.dt
    and fp1.fromtag=fmw.fromtag
;
