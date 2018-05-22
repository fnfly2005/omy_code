
select
    case when md1.value2 is not null then md1.value2
    when fp.fromTag=0 then '其他'
    when fp.fromTag is null then '其他'
    else fp.fromTag end fromTag,
    fp.dt,
    fp.pt,
    per.performance_id,
    per.performance_name,
    sum(uv) uv,
    sum(totalprice) as totalprice,
    sum(order_num) order_num,
    sum(ticket_num) as ticket_num,
    sum(grossprofit) as grossprofit
from (
    select
        fromTag,
        fp1.dt,
        md2.value2 as pt,
        performance_id,
        sum(uv) as uv
    from (
        select
            case when page_identifier='c_Q7wY4' 
                then custom['fromTag']
            else utm_source
            end as fromTag,
            partition_date as dt,
            app_name,
            case when page_identifier<>'pages/show/detail/index'
                    then custom['performance_id']
                else custom['id'] end as performance_id,
            count(distinct union_id) as uv
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
        group by
            1,2,3,4
        ) as fp1
        left join (
        select key, value1, value2, value3 from upload_table.myshow_dictionary_s where key_name is not null
        and key_name='app_name'
        ) md2
        on fp1.app_name=md2.key
        and performance_id in ($id)
    where
        performance_id in ($id)
    group by
        1,2,3,4
    ) fp
    left join (
        select
            fromTag,
            dt,
            value2 as pt,
            performance_id,
            sum(totalprice) as totalprice,
			sum(order_num) order_num,
            sum(ticket_num) as ticket_num,
            sum(grossprofit) as grossprofit
        from (
            select
                fromTag,
                dt,
                sellchannel,
                performance_id,
                sum(totalprice) as totalprice,
                count(distinct fp2.order_id) as order_num,
                sum(ticket_num) as ticket_num,
                sum(grossprofit) as grossprofit
            from (
                select distinct
                    case when event_id='b_WLx9n' then custom['fromTag']
                    else utm_source
                    end as fromTag,
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
                    and event_id in ('b_WLx9n','b_w047f3uw')
                ) as fp2
                join (
                    select
                        partition_date as dt,
                        sellchannel,
                        performance_id,
                        order_id,
                        sum(totalprice) as totalprice,
                        sum(salesplan_count*setnumber) as ticket_num,
                        sum(grossprofit) as grossprofit
                    from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
                        and sellchannel in (1,2,3,5,6,7,13)
                        and performance_id in ($id)
                    group by
                        1,2,3,4
                    ) spo
                on fp2.order_id=spo.order_id
            group by
                1,2,3,4
            ) as sdo
            left join (
                select key, value1, value2, value3 from upload_table.myshow_dictionary_s where key_name is not null
                and key_name='sellchannel'
                ) md3
            on md3.key=sdo.sellchannel 
        group by
            1,2,3,4
        ) as sp
    on sp.fromTag=fp.fromTag
    and sp.dt=fp.dt
    and sp.pt=fp.pt
    and sp.performance_id=fp.performance_id
    left join (
        select key, value1, value2, value3 from upload_table.myshow_dictionary_s where key_name is not null
            and key_name='fromTag'
        ) md1
    on fp.fromTag=md1.key
    join (
        select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
        and performance_id in ($id)
        ) per
    on fp.performance_id=per.performance_id
group by
    1,2,3,4,5
;
