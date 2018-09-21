
select
    vp.dt,
    vp.ht,
    vp.mit,
    vp.pt,
    vp.page_city_name,
    dp.city_name,
    dp.category_name,
    dp.shop_name,
    dp.performance_id,
    dp.performance_name,
    vp.uv,
    coalesce(sp.order_num,0) as order_num,
    coalesce(sp.ticket_num,0) as ticket_num, 
    coalesce(sp.totalprice,0) as totalprice,
    coalesce(sp.grossprofit,0) as grossprofit,
    coalesce(ush_num,0) as ush_num,
    coalesce(out_num,0) as out_num
from (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, province_id, city_id, city_name, shop_id, shop_name from mart_movie.dim_myshow_performance where 1=1
        and (regexp_like(performance_name,'$performance_name')
        or '全部'='$performance_name')
        and (performance_id in ($performance_id)
        or -99 in ($performance_id))
        ) as dp
    join (
    select
        dt,
        ht,
        mit,
        case when 4 in ($dim) then value2
        else '全部' end as pt,
        page_city_name,
        performance_id,
        sum(uv) uv
    from (
        select
            case when 1 in ($dim) then partition_date 
            else 'all' end as dt,
            case when 2 in ($dim) then substr(stat_time,12,2) 
            else 'all' end as ht,
            case when 3 in ($dim) then (floor(cast(substr(stat_time,15,2) as double)/$tie)+1)*$tie
            else 'all' end as mit,
            app_name,
            case when 5 in ($dim) then page_city_name
            else 'all' end as page_city_name,
            performance_id,
            count(distinct union_id) uv
        from mart_movie.detail_myshow_pv_wide_report where partition_date>='$$begindate' and partition_date<'$$enddate'
            and page_name_my='演出详情页'
            and (performance_id in ($performance_id)
            or -99 in ($performance_id))
            and ((substr(stat_time,12,2)>=$hts and substr(stat_time,12,2)<$hte)
                or (2 not in ($dim) and 3 not in ($dim)))
        group by
            1,2,3,4,5,6
        ) fp
        join (
            select key_name, key, key1, key2, value1, value2, value3, value4 from mart_movie.dim_myshow_dictionary where 1=1
                and key_name='app_name'
                and value2 in ($pt)
            ) md
        on md.key=fp.app_name
    group by
        1,2,3,4,5,6
    ) vp
    on vp.performance_id=dp.performance_id
    left join (
        select
            case when 1 in ($dim) then partition_date
            else 'all' end as dt,
            case when 2 in ($dim) then substr(pay_time,12,2)
            else 'all' end as ht,
            case when 3 in ($dim) then (floor(cast(substr(pay_time,15,2) as double)/$tie)+1)*$tie
            else 'all' end as mit,
            case when 4 in ($dim) then md.value2
            else '全部' end as pt,
            performance_id,
            count(distinct order_id) order_num,
            sum(ticket_num) ticket_num,
            sum(totalprice) totalprice,
            sum(grossprofit) grossprofit
        from (
            select
                partition_date,
                pay_time,
                sellchannel,
                performance_id,
				order_id,
				(salesplan_count*setnumber) as ticket_num,
				totalprice,
				grossprofit
            from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
                and (performance_id in ($performance_id)
                or -99 in ($performance_id))
                and ((substr(pay_time,12,2)>=$hts and substr(pay_time,12,2)<$hte)
                    or (2 not in ($dim) and 3 not in ($dim)))
                ) as spo
            join (
                select key_name, key, key1, key2, value1, value2, value3, value4 from mart_movie.dim_myshow_dictionary where 1=1
                and key_name='sellchannel'
                and value2 in ($pt)
                ) md
            on md.key=spo.sellchannel
        group by
            1,2,3,4,5
        ) sp
    on sp.performance_id=vp.performance_id
    and sp.dt=vp.dt
    and sp.ht=vp.ht
    and sp.mit=vp.mit
    and sp.pt=vp.pt
    and 5 not in ($dim)
    left join (
        select
            case when 1 in ($dim) then substr(createtime,1,10)
            else 'all' end as dt,
            case when 2 in ($dim) then substr(createtime,12,2)
            else 'all' end as ht,
            case when 3 in ($dim) then (floor(cast(substr(createtime,15,2) as double)/$tie)+1)*$tie
            else 'all' end as mit,
            case when 4 in ($dim) then md.value2
            else '全部' end as pt,
            performance_id,
            count(distinct mobile) as ush_num
        from (
            select CreateTime, phonenumber as mobile, sellchannel, performanceid as performance_id from origindb.dp_myshow__s_messagepush where phonenumber is not null and createtime>='$$begindate' and createtime<'$$enddate'
                and (performanceid in ($performance_id)
                or -99 in ($performance_id))
                and ((substr(createtime,12,2)>=$hts and substr(createtime,12,2)<$hte)
                    or (2 not in ($dim) and 3 not in ($dim)))
            ) ush
            join (
                select key_name, key, key1, key2, value1, value2, value3, value4 from mart_movie.dim_myshow_dictionary where 1=1
                    and key_name='sellchannel'
                    and value2 in ($pt)
                ) md
            on ush.sellchannel=md.key
        group by
            1,2,3,4,5
        ) us
    on us.performance_id=vp.performance_id
    and us.dt=vp.dt
    and us.ht=vp.ht
    and us.mit=vp.mit
    and us.pt=vp.pt
    and 5 not in ($dim)
    left join (
        select
            case when 1 in ($dim) then substr(createtime,1,10)
            else 'all' end as dt,
            case when 2 in ($dim) then substr(createtime,12,2)
            else 'all' end as ht,
            case when 3 in ($dim) then (floor(cast(substr(createtime,15,2) as double)/$tie)+1)*$tie
            else 'all' end as mit,
            case when 4 in ($dim) then md.value2
            else '全部' end as pt,
            performance_id,
            count(distinct mobile) as out_num
        from (
            select
                createtime,
                performance_id,
                sellchannel,
                mobile
            from mart_movie.detail_myshow_stockout where createtime>='$$begindate' and createtime<'$$enddate'
                and (performance_id in ($performance_id)
                or -99 in ($performance_id))
                and ((substr(createtime,12,2)>=$hts and substr(createtime,12,2)<$hte)
                    or (2 not in ($dim) and 3 not in ($dim)))
            ) out
            join (
                select key_name, key, key1, key2, value1, value2, value3, value4 from mart_movie.dim_myshow_dictionary where 1=1
                    and key_name='sellchannel'
                    and value2 in ($pt)
                ) md
            on out.sellchannel=md.key
        group by
            1,2,3,4,5
        ) ou
    on ou.performance_id=vp.performance_id
    and ou.dt=vp.dt
    and ou.ht=vp.ht
    and ou.mit=vp.mit
    and ou.pt=vp.pt
    and 5 not in ($dim)
;
