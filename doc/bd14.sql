
select 
    mobile,
    $send_performance_id as send_performance_id,
    '$$enddate' as send_date,
    cast(floor(rand()*$batch_code) as bigint)+1 as batch_code,
    '$sendtag' as sendtag
from (
    select 
        mobile,
        row_number() over (order by 1) rank
    from (
        select distinct
            so.mobile
        from (
            select
                usermobileno as mobile
            from
                mart_movie.detail_myshow_saleorder
            where
                performance_id in (
                    select distinct
                        performance_id
                    from (
                        select
                            performance_id
                        from
                            mart_movie.dim_myshow_performance
                        where (
                                performance_id in ($item_id)
                                or -99 in ($item_id)
                                )
                            and (
                                performance_id in ($performance_id)
                                or -99 in ($performance_id)
                                )
                            and (
                                shop_id in ($shop_id)
                                or -99 in ($shop_id)
                                )
                        ) c1
                    where performance_id not in ($no_performance_id)
                    )
            union all
            select 
                order_mobile as mobile
            from
                upload_table.detail_wg_saleorder
            where
                $order_src=1
                and item_id in (
                    select distinct
                        item_id
                    from (
                        select
                            item_id
                        from
                            upload_table.dim_wg_item
                        where (
                                item_no in ($item_id)
                                or -99 in ($item_id)
                                )
                            and (
                                title_cn like '%$performance_name%'
                                or '测试'='$performance_name'
                                )
                            and (
                                venue_name like '%$shop_name%'
                                or '测试'='$shop_name'
                                )
                        ) as di
                    where item_id not in ($no_performance_id)
                    ) 
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
        ) as cs
    ) as c
where
    rank<=$limit
;
