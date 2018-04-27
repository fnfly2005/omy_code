
select
    case when 1 in ($dim) then substr(fpw.dt,1,7)
    else 'all' end as mt, 
    case when 2 in ($dim) then fpw.dt
    else 'all' end as dt, 
    fpw.pt,
    per.area_1_level_name,
    per.area_2_level_name,
    per.province_name,
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_id,
    per.performance_name,
    avg(fpw.uv) uv,
    avg(sp1.order_num) order_num,
    avg(sp1.ticket_num) ticket_num,
    avg(sp1.totalprice) totalprice,
    avg(sp1.grossprofit) grossprofit
from (
    select 
        dt,
        value2 as pt,
        performance_id,
        sum(uv) uv
    from (
        select
            partition_date as dt,
            case when 3 in ($dim) then app_name
            else 'all' end app_name,
            case when app_name='maoyan_wxwallet_i' then custom['id'] 
            else custom['performance_id'] end as performance_id,
            approx_distinct(union_id) as uv
        from mart_flow.detail_flow_pv_wide_report
        where partition_date>='$$begindate'
            and partition_date<'$$enddate'
            and partition_log_channel='movie'
            and partition_app in (
            'movie','dianping_nova','other_app','dp_m','group'
            )
            and app_name<>'gewara'
            and page_identifier in (
            select value
            from upload_table.myshow_pv
            where key='page_identifier'
            and nav_flag=2
            and page in ('h5','mini_programs')
            )
        group by
            1,2,3
        ) as fp1
        left join (
        select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
        and key_name='app_name'
        ) md
        on md.key=fp1.app_name
    group by
        1,2,3
    ) as fpw
    left join (
        select
            dt,
            md.value2 as pt,
            performance_id,
            sum(order_num) order_num,
            sum(ticket_num) ticket_num,
            sum(totalprice) totalprice,
            sum(grossprofit) grossprofit
        from (
            select
                partition_date as dt,
                case when 3 in ($dim) then sellchannel
                else -99 end sellchannel,
                performance_id,
                count(distinct order_id) as order_num,
                sum(salesplan_count*setnumber) as ticket_num,
                sum(totalprice) as totalprice,
                sum(grossprofit) as grossprofit
            from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
            group by
                1,2,3
            ) as spo
            left join (
            select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
            and key_name='sellchannel'
            ) md
            on md.key=spo.sellchannel
        group by
            1,2,3
        ) sp1
    on sp1.dt=fpw.dt
    and sp1.performance_id=fpw.performance_id
    and sp1.pt=fpw.pt
    left join (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) as per
    on per.performance_id=fpw.performance_id
where
    (sp1.performance_id is not null
    or 0=$ft)
group by
    1,2,3,4,5,6,7,8,9,10,11
;
