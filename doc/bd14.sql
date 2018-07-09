
select 
    mobile,
    $send_performance_id as send_performance_id,
    '$$enddate' as send_date,
    cast(floor(rand()*$batch_code) as bigint)+1 as batch_code,
    '$sendtag' as sendtag
from (
    select 
        mobile,
        row_number() over (order by action_id desc) rank
    from (
        select
            so.mobile,
            action_id
        from (
            select 
                mobile,
                max(action_id) action_id
            from (
                select
                    mobile,
                    action_flag
                from (
                    select 
                        mobile,
                        category_flag,
                        action_flag
                    from
                        mart_movie.dim_myshow_userlabel
                    where
                        1 in ($order_src)
                        and sellchannel in ($sellchannel_id)
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
                        and (
                            pay_num>$pay_num
                            or $pay_num=-99
                            )
                        and (
                            pay_money>$pay_money
                            or $pay_money=-99
                            )
                    union all
                    select 
                        mobile,
                        category_flag,
                        action_flag
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
                        and (
                            pay_num>$pay_num
                            or $pay_num=-99
                            )
                        and (
                            pay_money>$pay_money
                            or $pay_money=-99
                            )
                    union all
                    select 
                        mobile,
                        category_flag,
                        action_flag
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
                        and (
                            pay_num>$pay_num
                            or $pay_num=-99
                            )
                        and (
                            pay_money>$pay_money
                            or $pay_money=-99
                            )
                    ) ws
                    cross join unnest(category_flag) as t (category_id)
                where
                    category_id in ($category_id)
                    or -99 in ($category_id)
                ) sw
                cross join unnest(action_flag) as t (action_id)
            where
                action_id in ($action_id)
                or -99 in ($action_id)
            group by
                1
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
                        (send_date>=date_add('day',-$id,date_parse('$$enddate','%Y-%m-%d'))
                        and $id<>0)
                        or sendtag in ('$send_tag')
                            )
                        and sendtag not in (
                            select sendtag from upload_table.myshow_send_performance_fn where send_flag='0'
                            )
                    union all 
                    select mobile
                    from upload_table.send_wdh_user
                    where (
                        (send_date>=date_add('day',-$id,date_parse('$$enddate','%Y-%m-%d'))
                        and $id<>0)
                        or sendtag in ('$send_tag')
                            )
                        and sendtag not in (
                            select sendtag from upload_table.myshow_send_performance_fn where send_flag='0'
                            )
                    union all
                    select
                        usermobileno as mobile
                    from 
                        mart_movie.detail_myshow_saleorder
                    where
                        pay_time is not null
                        and performance_id in ($fit_pid)
                    ) m1
                ) mm
            on mm.mobile=so.mobile
        where
            mm.mobile is null
        ) as cs
    ) as c
where
    rank<=$limit
;
