
select
    dt,
    pt,
    case when value2 is not null then value2
    when fromTag=0 then '其他'
    when fromTag is null then '其他'
    else fromTag end fromTag,
    sum(uv) uv,
    sum(order_uv) order_uv,
    sum(ticket_num) ticket_num,
    sum(totalprice) totalprice,
    sum(grossprofit) grossprofit,
    sum(refund_order_uv) as refund_order_uv
from (
    select
        fp1.dt,
        case when page_identifier='c_Q7wY4' then 'h5'
        else 'mini_programs' end pt,
        fromTag,
        approx_distinct(fp1.union_id) as uv,
        count(distinct fp2.order_id) as order_uv,
        sum(ticket_num) ticket_num,
        sum(totalprice) totalprice,
        sum(grossprofit) grossprofit,
        count(distinct refund_order_id) as refund_order_uv
    from (
        select
            dt,
            app_name,
            page_identifier,
            fromTag,
            union_id
        from (
            select
                partition_date as dt,
                app_name,
                page_identifier,
                case when page_identifier='c_Q7wY4' 
                    then custom['fromTag']
                else utm_source
                end as fromTag,
                case when page_identifier<>'pages/show/detail/index'
                        then custom['performance_id']
                    else custom['id'] end as performance_id,
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
                'c_Q7wY4',
                'pages/show/detail/index'
                )
            ) as fpd
            join (
                select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
                and category_name in ('$name')
                ) per
            on fpd.performance_id=per.performance_id
        group by
            1,2,3,4,5
        ) fp1
        left join (
            select
                fpo.dt,
                app_name,
                union_id,
                fpo.order_id,
                setnumber*salesplan_count ticket_num,
                totalprice,
                grossprofit,
                case when spo.order_id is null then fpo.order_id end refund_order_id
            from (
                select
                    partition_date as dt,
                    app_name,
                    union_id,
                    order_id
                from
                    mart_flow.detail_flow_mv_wide_report
                where partition_date>='$$begindate'
                    and partition_date<'$$enddate'
                    and partition_log_channel='movie'
                    and partition_etl_source='2_5x'
                    and partition_app in (
                    'movie',
                    'dianping_nova',
                    'other_app',
                    'dp_m',
                    'group'
                    )
                    and event_id='b_WLx9n'
                ) fpo
                left join (
                select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
                ) spo
                on fpo.order_id=spo.order_id
            ) as fp2
        on fp1.app_name=fp2.app_name
        and fp1.union_id=fp2.union_id
        and fp1.dt=fp2.dt
        and fp1.page_identifier='c_Q7wY4'
    group by
        1,2,3
    ) as fpw
    left join (
    select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
    and key_name='fromTag'
    ) md
    on fpw.fromTag=md.key
group by
    1,2,3
;
