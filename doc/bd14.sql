
select 
    usermobileno
from (
    select 
        usermobileno,
        row_number() over (order by 1) rank
    from (
        select distinct
            so.usermobileno
        from (
            select distinct
                performance_id
            from (
                select
                    performance_id
                from
                    mart_movie.dim_myshow_performance
                where (
                    category_name in ('$category_name')
                    or '全部' in ('$category_name')
                    )
                    and province_name in ('$area_name')
                union all
                select
                    performance_id
                from
                    mart_movie.dim_myshow_performance
                where (
                    category_name in ('$category_name')
                    or '全部' in ('$category_name')
                    )
                    and city_name in ('$area_name')
                union all
                select
                    performance_id
                from
                    mart_movie.dim_myshow_performance
                where performance_id in ($performance_id)
                ) c1
            where
                performance_id not in ($no_performance_id)
            ) ci
            join (
            select
                usermobileno,
                performance_id
            from
                mart_movie.detail_myshow_saleorder
            where order_create_time>='$$begindate'
                and order_create_time<'$$enddate'
            ) so
            on so.performance_id=ci.performance_id
            left join upload_table.myshow_mark mm
            on mm.usermobileno=so.usermobileno
            and $id=1
        where
            mm.usermobileno is null
        ) as cs
    ) as c
where
    rank<=$limit
;
