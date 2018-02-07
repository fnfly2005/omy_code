
select
    s2.mt,
    s2.pt,
    order_num,
    totalprice,
    uv
from (
    select
        mt,
        value2 as pt,
        sum(order_num) order_num,
        sum(totalprice) totalprice
    from (
        select
            substr(dt,1,7) as mt,
            sellchannel,
            count(distinct order_id) as order_num,
            sum(totalprice) as totalprice
        from (
            select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$$today{-1d}' and partition_date<'$$today{0d}'
            ) as spo
        group by
            1,2
        ) as s1
        left join (
        select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
        and key_name='sellchannel'
        ) as md
        on md.key=s1.sellchannel
    group by
        1,2
    ) as s2
    left join (
        select
            substr(dt,1,7) as mt,
            value2 as pt,
            sum(uv) as uv
        from (
            select
                partition_date as dt,
                app_name,
                approx_distinct(union_id) as uv
            from
                mart_flow.detail_flow_pv_wide_report
            where
                partition_date>='$time1'
                and partition_date<'$time2'
                and partition_log_channel='movie'
                and partition_app in (
                select key
                from upload_table.myshow_dictionary
                where key_name='partition_app'
                )
                and page_identifier in (
                select value
                from upload_table.myshow_pv
                where key='page_identifier'
                and page_tag1>=0
                )
            group by
                1,2
            ) fpw
            left join (
            select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
            and key_name='app_name'
            ) as md
            on md.key=fpw.app_name
        group by
            1,2
        ) as p1
    on s2.mt=p1.mt
    and s2.pt=p1.pt
;
