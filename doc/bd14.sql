
select 
    meituan_userid
from (
    select 
        meituan_userid,
        row_number() over (order by 1) rank
    from (
            select distinct
                meituan_userid
            from
                mart_movie.detail_myshow_saleorder
            where
                sellchannel in ($sellchannel_id)
                and performance_id in (
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
                                and (
                                    province_name in ('$area_name')
                                    or city_name in ('$area_name')
                                    or '全部' in ('$area_name')
                                    )
                            union all
                            select
                                performance_id
                            from
                                mart_movie.dim_myshow_performance
                            where performance_id in ($performance_id)
                            ) c1
                        where
                            performance_id not in ($no_performance_id)
                    )
        ) as cs
    ) as c
where
    rank<=$limit
;
