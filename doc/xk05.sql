
select
    area_1_level_name,
    province_name,
    city_name,
    category_name,
    so.performance_id,
    performance_name,
    case when bd_name=0 then '无'
    else bd_name end as bd_name,
    totalprice,
    rank,
    all_ticketnum,
    us_ticketnum
from (
    select
        area_1_level_name,
        province_name,
        city_name,
        category_name,
        spo.performance_id,
        performance_name,
        totalprice,
        row_number() over (partition by area_1_level_name order by totalprice desc) rank
    from (
        select
            performance_id,
            sum(totalprice) as totalprice
        from
            mart_movie.detail_myshow_salepayorder
        where
            partition_date>='$$today{-7d}'
            and partition_date<'$$today{-0d}'
        group by
            1
        ) spo
        left join (
            select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
            ) per
        on per.performance_id=spo.performance_id
    ) so
    left join (
        select
            performance_id,
            max(bd_name) as bd_name,
            avg(all_ticketnum) all_ticketnum,
            avg(us_ticketnum) us_ticketnum,
        from (
            select
                dt,
                dms.performance_id,
                max(case when dpr.project_id is null then 0 else bd_name end) bd_name,
                count(distinct ticketclass_id) as all_ticketnum,
                count(distinct case when salesplan_sellout_flag=0 and customer_type_id=1 then ticketclass_id end) us_ticketnum,
            from (
                select
                    partition_date as dt,
                    customer_type_id,
                    performance_id,
                    ticketclass_id,
                    show_id,
                    salesplan_sellout_flag,
                    project_id,
                    city_id
                from
                    mart_movie.detail_myshow_salesplan
                where
                    partition_date>='$$today{-7d}'
                    and partition_date<'$$today{-0d}'
                ) dms
                left join (
                    select show_id, performance_id, substr(show_starttime,1,10) as show_starttime, show_endtime from mart_movie.dim_myshow_show where show_id is not null
                    ) sho
                on sho.show_id=dms.show_id
                left join (
                    select
                        project_id,
                        bd_name
                    from
                        mart_movie.dim_myshow_project
                    where
                        bd_name is not null
                    ) dpr
                on dpr.project_id=dms.project_id
            group by
                1,2
            ) sp
        group by
            1
        ) ss
    on so.performance_id=ss.performance_id
    and so.rank<=50
where
    so.rank<=50
;
