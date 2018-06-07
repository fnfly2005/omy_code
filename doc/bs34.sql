
select
    case when 1 in ($dim) then sp1.dt
    else 'all' end as dt,
    sp1.pt,
    avg(all_uv) as all_uv,
    avg(fp1.first_uv) as first_uv,
    avg(fp1.detail_uv) as detail_uv,
    avg(fp1.order_uv) as order_uv,
    avg(sp1.order_num) as order_num,
    avg(totalprice) as totalprice,
    avg(ticket_num) as ticket_num
from (
    select
        sp0.dt,
        md.value2 as pt,
        sum(totalprice) as totalprice,
        sum(sp0.order_num) as order_num,
        sum(ticket_num) as ticket_num
    from (
        select
            substr(pay_time,1,10) as dt,
            case when 2 in ($dim) then sellchannel
            else -99 end as sellchannel,
            sum(totalprice) as totalprice,
            count(distinct order_id) as order_num,
            sum(setnumber*salesplan_count) as ticket_num
        from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
        group by
            1,2
        ) as sp0
        left join (
            select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
            and key_name='sellchannel'
            ) as md
        on sp0.sellchannel=md.key
    group by
        1,2
    ) as sp1
    left join (
        select
            dt,
            md.value2 as pt,
            sum(all_uv) as all_uv,
            sum(fp0.first_uv) as first_uv,
            sum(fp0.detail_uv) as detail_uv,
            sum(fp0.order_uv) as order_uv
        from (
            select
                dt,
                app_name,
                approx_distinct(union_id) as all_uv,
                approx_distinct(case when nav_flag=1 then union_id end) as first_uv,
                approx_distinct(case when nav_flag=2 then union_id end) as detail_uv,
                approx_distinct(case when nav_flag=4 then union_id end) as order_uv
            from (
                select
                    partition_date as dt,
                    case when 2 in ($dim) then app_name
                    else 'all' end as app_name,
                    page_identifier,
                    union_id
                from
                    mart_flow.detail_flow_pv_wide_report
                where partition_date>='$$begindate'
                    and partition_date<'$$enddate'
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
                    and app_name in (
                        select
                            key
                        from upload_table.myshow_dictionary_s where key_name is not null
                        and key_name='app_name'
                        )
                ) as fpw
                left join (
                    select
                        value,
                        nav_flag
                    from upload_table.myshow_pv where key='page_identifier'
                    and page_tag1>=0
                    ) mp
                on mp.value=fpw.page_identifier
            group by
                1,2
            ) as fp0
            left join (
                select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
                and key_name='app_name'
                ) md
            on fp0.app_name=md.key
        group by
            1,2
        ) as fp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
group by
    1,2
;
