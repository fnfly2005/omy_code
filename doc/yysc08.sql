
select
    vp.dt,
    vp.ht,
    dp.city_name,
    dp.category_name,
    dp.shop_name,
    dp.performance_id,
    dp.performance_name,
    vp.uv,
    case when sp.performance_id is null then 0
    else sp.order_num end as order_num,
    case when sp.performance_id is null then 0
    else sp.ticket_num end as ticket_num, 
    case when sp.performance_id is null then 0
    else sp.totalprice end as totalprice,
    case when sp.performance_id is null then 0
    else sp.grossprofit end as grossprofit
from (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    and (performance_name like '%$performance_name%'
    or '测试'='$performance_name')
    and (performance_id in ($performance_id)
    or -99 in ($performance_id))
    ) as dp
    join (
    select
        dt,
        ht,
        case when 1 in ($dim) then md.value2 
        else 'all' end as pt,
        performance_id,
        sum(uv) uv
    from (
        select
            partition_date as dt,
            substr(stat_time,12,2) ht,
            app_name,
            case when page_identifier<>'pages/show/detail/index' then custom['performance_id']
            else custom['id']
            end as performance_id,
            approx_distinct(union_id) as uv
        from
            mart_flow.detail_flow_pv_wide_report
        where 
            partition_date>='$$begindate'
            and partition_date<'$$enddate'
            and partition_log_channel='movie'
            and partition_app in (
            'movie',
            'dianping_nova',
            'other_app',
            'dp_m',
            'group'
            )
            and page_identifier in ('c_Q7wY4',
            'pages/show/detail/index')
        group by
            1,2,3,4
        ) fp
        left join (
        select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
        and key_name='app_name'
        ) md
        on md.key=fp.app_name
    group by
        1,2,3,4
    ) vp
    on vp.performance_id=dp.performance_id
    left join (
        select
            dt,
            ht,
            case when 1 in ($dim) then md.value2 
            else 'all' end as pt,
            performance_id,
            sum(order_num) order_num,
            sum(ticket_num) ticket_num,
            sum(totalprice) totalprice,
            sum(grossprofit) grossprofit
        from (
            select
                partition_date as dt,
                substr(pay_time,12,2) as ht,
                sellchannel,
                performance_id,
                count(distinct order_id) order_num,
                sum(salesplan_count*setnumber) ticket_num,
                sum(totalprice) totalprice,
                sum(grossprofit) grossprofit
            from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
                and sellchannel not in (9,10,11)
            group by
                1,2,3,4
                ) as spo
            left join (
            select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
            and key_name='sellchannel'
            ) md
            on md.key=spo.sellchannel
        group by
            1,2,3,4
        ) sp
    on sp.performance_id=vp.performance_id
    and sp.dt=vp.dt
    and sp.ht=vp.ht
    and sp.pt=vp.pt
;
