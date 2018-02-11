
select
    sp3.dt,
    sp3.bu,
    fp2.uv,
    sp3.order_num,
    sp3.ticket_num,
    sp3.totalprice
from (
    select
        dt,
        coalesce(bu,'全部') as bu,
        sum(order_num) as order_num,
        sum(ticket_num) as ticket_num,
        sum(totalprice) as totalprice
    from (
        select
            spo.dt,
            '演出' as bu,
            count(distinct spo.order_id) as order_num,
            sum(spo.salesplan_count*spo.setnumber) as ticket_num,
            sum(spo.totalprice) as totalprice
        from
            (
            select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
            and sellchannel=8
            ) spo
        group by
            spo.dt,
            '演出'
        union all
        select
            '$$today{-1d}' as dt,
            '电影' as bu,
            mdk.order_num,
            mdk.ticket_num,
            mdk.gmv as totalprice
        from (
            select sum(ordernum) as order_num, sum(seatnum) as ticket_num, sum(gmv) as gmv from mart_movie.topic_movie_deal_kpi_daily where dt='$$today_compact{-1d}' and source=8 and channel_id=80001
            ) as mdk
        ) as sp1
    group by
        dt,
        bu
    grouping sets(
        dt,
        (dt,bu)
        )
    ) as sp3
    left join (
        select
            dt,
            coalesce(bu,'全部') as bu,
            count(distinct union_id) as uv
        from (
            select
                dt,
                coalesce(md.value1,'平台') as bu,
                union_id
            from (
                select
                    partition_date as dt,
                    page_identifier,
                    union_id
                from
                    mart_flow.detail_flow_pv_wide_report
                where partition_date='$$today{-1d}'
                    and partition_log_channel='movie'
                    and partition_app='other_app'
                    and app_name='gewara'
                group by
                    partition_date,
                    page_identifier,
                    union_id
                ) as fpw
                left join (
                    select nav_flag, value, page_tag1 from upload_table.myshow_pv where key='page_identifier'
                    and page='native'
                    and page_tag1<>-1
                    ) as mp
                on fpw.page_identifier=mp.value
                left join (
                    select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
                    and key_name='page_tag1'
                    and key in (-2,0)
                    ) as md
                on mp.page_tag1=md.key
            group by
                dt,
                coalesce(md.value1,'平台'),
                union_id
            ) as fp1
        group by
            dt,
            bu
        grouping sets (
            dt,
            (dt,bu)
            )
    ) as fp2
    on sp3.dt=fp2.dt
    and sp3.bu=fp2.bu
;
