
select
    fp1.dt,
    fp1.pt,
    fp1.uv,
    sp1.order_num,
    sp1.totalprice
from (
    select
        fpw.dt,
        case when md.value2 is null then '其他'
        else md.value2 end as pt,
        sum(fpw.uv) as uv
    from (
        select
            partition_date as dt,
            app_name,
            count(distinct union_id) as uv
        from
            mart_flow.detail_flow_pv_wide_report
        where partition_date='$$today{-1d}'
            and partition_log_channel='movie'
            and partition_app in (
            'movie',
            'dianping_nova',
            'other_app',
            'dp_m',
            'group'
            )
            and page_identifier in (
            select value
            from upload_table.myshow_pv
            where key='page_identifier'
            and page_tag1>=0
            )
        group by
            partition_date,
            app_name
        ) as fpw
    left join (
        select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
        and key_name='app_name'
        ) md
    on fpw.app_name=md.key
    group by
        1,2
    ) as fp1
    left join (
    select
        sp0.dt,
        md.value2 as pt,
        sum(sp0.order_num) as order_num,
        sum(sp0.totalprice) as totalprice
    from (
        select
            spo.dt,
            spo.sellchannel,
            count(distinct spo.order_id) as order_num,
            sum(spo.totalprice) as totalprice
        from
            (
            select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
            ) spo
        group by
            spo.dt,
            spo.sellchannel
        ) as sp0
        left join
        (
        select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
        and key_name='sellchannel'
        ) as md
        on sp0.sellchannel=md.key
    group by
        sp0.dt,
        md.value2
    ) as sp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
;
