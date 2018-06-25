
select
    fp1.dt,
    fp1.pt,
    fp1.first_uv,
    fp1.nav_uv,
    fp1.detail_uv,
    fp1.order_uv,
    sp1.order_num
from (
    select
        dt,
        value1 as pt,
        sum(fp0.first_uv) as first_uv,
        sum(fp0.nav_uv) as nav_uv,
        sum(fp0.detail_uv) as detail_uv,
        sum(fp0.order_uv) as order_uv
    from (
        select
            dt,
            app_name,
            count(distinct case when nav_flag=0 then union_id end) as first_uv,
            count(distinct case when nav_flag=1 then union_id end) as nav_uv,
            count(distinct case when nav_flag=2 then union_id end) as detail_uv,
            count(distinct case when nav_flag=4 then union_id end) as order_uv
        from (
            select distinct
                partition_date as dt,
                app_name,
                page_identifier,
                union_id
            from
                mart_flow.detail_flow_pv_wide_report
            where partition_date>='$$today{-1d}'
                and partition_date<'$$today{-0d}'
                and partition_log_channel='movie'
                and partition_app='other_app'
                and app_name in ('gewara','gewara_pc')
                and page_identifier in (
                    select 
                        value
                    from 
                        upload_table.myshow_pv
                    where key='page_identifier'
                        and page in ('native','pc')
                        and page_tag1>-2
                    )
            union all
            select distinct
                partition_date as dt,
                'gewara_pc' as app_name,
                page_identifier,
                union_id
            from
                mart_flow.detail_flow_pv_wide_report
            where partition_date>='$$today{-1d}'
                and partition_date<'$$today{-0d}'
                and partition_log_channel='movie'
                and partition_app='other_app'
                and page_identifier='pages/showsubs/order/confirm'
                and utm_source='gewara_pc'
            ) as fpw
            left join (
                select key, value, name, page, nav_flag, page_tag1, page_tag2 from upload_table.myshow_pv where key='page_identifier'
                and page in ('native','pc','mini_programs')
                and page_tag1>-2
                ) mp
            on mp.value=fpw.page_identifier
        group by
            dt,
            app_name
        ) as fp0
        left join (
            select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
            and key_name='app_name'
            ) as md
        on md.key=fp0.app_name
    group by
        dt,
        value1
    ) as fp1
    left join (
        select
            partition_date as dt,
            '格瓦拉APP' as pt,
            count(distinct order_id) as order_num
        from mart_movie.detail_myshow_salepayorder where partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}'
            and sellchannel=8
        group by
            1,2
        union all
        select
            fmw.dt,
            '格瓦拉PC' as pt,
            count(distinct fmw.order_id) as order_num
        from (
            select distinct
                partition_date as dt,
                order_id
            from mart_flow.detail_flow_mv_wide_report where partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}' and partition_log_channel='movie' and partition_etl_source='2_5x' and partition_app in ( 'movie', 'dianping_nova', 'other_app', 'dp_m', 'group' )
                and utm_source='gewara_pc'
                and event_id='b_w047f3uw'
            ) as fmw
            left join (
                select
                    partition_date as dt,
                    order_id
                from mart_movie.detail_myshow_salepayorder where partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}'
                    and sellchannel=7
                ) as fso
            on fmw.order_id=fso.order_id
            and fmw.dt=fso.dt
        group by
            1,2
    ) as sp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
;
