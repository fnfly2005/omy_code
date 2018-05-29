
select
    case when md.value2 is not null then md.value2
    else fromtag end fromtag,
    dt,
    md2.value2 as pt,
    uv,
    order_num
from (
    select
        fp1.fromtag,
        fp1.dt,
        fp1.app_name,
        approx_distinct(fp1.union_id) as uv,
        count(distinct order_id) as order_num
    from (
        select
            partition_date as dt,
            app_name,
            case when regexp_like(url_parameters,'[Ff]romTag=') then split_part(regexp_extract(url_parameters,'[Ff]romTag=[^&]+'),'=',2)
            when regexp_like(substr(url,40,40),'fromTag%3D') then split_part(regexp_extract(url,'fromTag%3D[^%]+'),'%3D',2)
            when regexp_like(substr(url,40,40),'from=') then split_part(regexp_extract(url,'from=[^&]+'),'=',2)
            else 'other'
            end as fromtag,
            union_id
        from
            mart_flow.detail_flow_pv_wide_report
        where partition_date>='$$begindate'
            and partition_date<'$$enddate'
            and (
                (partition_log_channel='firework'
                and $source=1)
                or (partition_log_channel='cube'
                and $source=2)
                )
            and partition_app in (
            'movie',
            'dianping_nova',
            'other_app',
            'dp_m',
            'group'
            )
            and regexp_like(page_name,'$id')
        ) fp1
        left join (
            select 
                partition_date as dt,
                app_name,
                union_id,
                order_id
            from mart_flow.detail_flow_mv_wide_report
            where partition_date>='$$begindate'
                and partition_date<'$$enddate'
                and partition_log_channel='movie'
                and partition_etl_source='2_5x'
                and partition_app in ('movie', 'dianping_nova', 'other_app', 'dp_m', 'group')
                and event_id='b_WLx9n'
            ) as fmw
        on fp1.dt=fmw.dt
        and fp1.app_name=fmw.app_name
        and fp1.union_id=fmw.union_id
    group by
        1,2,3
    ) fp2
    left join (
            select key, value1, value2, value3 from upload_table.myshow_dictionary_s where key_name is not null
            and key_name='fromTag'
            ) md
    on md.key=fp2.fromtag
    left join (
            select key, value1, value2, value3 from upload_table.myshow_dictionary_s where key_name is not null
            and key_name='app_name'
            ) md2
    on md2.key=fp2.app_name
;
