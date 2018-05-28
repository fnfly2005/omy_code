
select 
    mobile,
    $send_performance_id as send_performance_id,
    '$$enddate' as send_date,
    cast(floor(rand()*$batch_code) as bigint)+1 as batch_code,
    '$sendtag' as sendtag
from (
    select 
        mobile,
        row_number() over (order by action_flag) rank
    from (
        select 
            so.mobile,
            min(action_flag) action_flag
        from (
            select
                usermobileno as mobile,
                1 as action_flag
            from
                mart_movie.detail_myshow_saleorder
            where
                sellchannel in ($sellchannel_id)
                and 1 in ($order_src)
                and performance_id in (
                    select distinct
                        performance_id
                    from (
                        select
                            performance_id
                        from
                            mart_movie.dim_myshow_performance
                        where 
                            category_id in ('$category_id')
                            and (
                                performance_id in ($performance_id)
                                or -99=$performance_id
                                )
                            and (
                                performance_name like '%$performance_name%'
                                or '测试'='$performance_name'
                                )
                            and (
                                shop_name like '%$shop_name%'
                                or '测试'='$shop_name'
                                )
                        ) c1
                    where performance_id not in ($no_performance_id)
                    )
                and (
                    (
                        city_id in ($city_id)
                        and 1 in ($cp)
                        )
                    or (
                        city_id in (
                            select
                                city_id
                            from
                                mart_movie.dim_myshow_city
                            where
                                province_id in ($province_id)
                            )
                        and 2 in ($cp)
                        )
                    )
            union all
            select
                mobile,
                action_flag
            from (
                select 
                    mobile,
                    category_flag,
                    2 as action_flag
                from
                    mart_movie.dim_wg_userlabel
                where
                    2 in ($order_src)
                    and (
                        (
                            city_id in ($city_id)
                            and 1 in ($cp)
                            )
                        or (
                            city_id in (
                                select
                                    city_id
                                from
                                    mart_movie.dim_myshow_city
                                where
                                    province_id in ($province_id)
                                )
                            and 2 in ($cp)
                            )
                        )
                union all
                select 
                    mobile,
                    category_flag,
                    3 as action_flag
                from
                    mart_movie.dim_wp_userlabel
                where
                    3 in ($order_src)
                    and (
                        (
                            city_id in ($city_id)
                            and 1 in ($cp)
                            )
                        or (
                            city_id in (
                                select
                                    city_id
                                from
                                    mart_movie.dim_myshow_city
                                where
                                    province_id in ($province_id)
                                )
                            and 2 in ($cp)
                            )
                        )
                ) ws
                cross join unnest(category_flag) as t (category_id)
            where
                category_id in ($category_id)
                or -99 in ($category_id)
            ) so
            left join (
                select distinct
                    mobile
                from (
                    select 
                        mobile
                    from 
                        mart_movie.detail_myshow_msuser
                    where (
                        (send_date>=date_add('day',-$id,date_parse('$$enddate','%Y-%m-%d'))
                        and $id<>0)
                        or sendtag in ('$send_tag')
                            )
                        and sendtag not in (
                            select sendtag from upload_table.myshow_send_performance_fn where send_flag='0'
                            )
                    union all
                    select mobile
                    from upload_table.send_fn_user
                    where (
                        send_date>=current_date
                        and $id<>0
                            )
                    union all 
                    select mobile
                    from upload_table.send_wdh_user
                    where (
                        send_date>=current_date
                        and $id<>0
                            )
                    ) m1
                ) mm
            on mm.mobile=mou.mobile
        where
            mm.mobile is null
        group by
            1
        ) as cs
    ) as c
where
    rank<=$limit
;
