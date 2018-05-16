
select 
    mobile,
    $send_performance_id as send_performance_id,
    '$$enddate' as send_date,
    cast(floor(rand()*$batch_code) as bigint)+1 as batch_code,
    '$sendtag' as sendtag
from (
    select
        mobile,
        row_number() over (order by pr) rank
    from (
        select
            mobile,
            min(pr) pr
        from (
            select
                mobile,
                4 pr
            from
                mart_movie.dim_myshow_movieuser
            where
                4 in ($dim)
                and active_date>=date_add('day',-$at,current_date)
                and city_id in (
                    select 
                        mt_city_id
                    from (
                        select city_id, mt_city_id, case when mt_city_id=0 then '其他城市' else city_name end as city_name, case when mt_city_id=0 then '其他城市' else province_name end as province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
                        and province_name in ('$area_name')
                        union all
                        select city_id, mt_city_id, case when mt_city_id=0 then '其他城市' else city_name end as city_name, case when mt_city_id=0 then '其他城市' else province_name end as province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
                        and city_name in ('$area_name')
                        ) c1
                    )
                and (
                    movie_id in ($movie_id)
                    or -99 in ($movie_id)
                    )
            union all
            select
                mobile,
                5 pr
            from
                mart_movie.dim_myshow_movieusera
            where
                5 in ($dim)
                and active_date>=date_add('day',-$at,current_date)
                and city_id in (
                    select distinct
                        mt_city_id
                    from (
                        select city_id, mt_city_id, case when mt_city_id=0 then '其他城市' else city_name end as city_name, case when mt_city_id=0 then '其他城市' else province_name end as province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
                        and province_name in ('$area_name')
                        union all
                        select city_id, mt_city_id, case when mt_city_id=0 then '其他城市' else city_name end as city_name, case when mt_city_id=0 then '其他城市' else province_name end as province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
                        and city_name in ('$area_name')
                        ) c1
                    )
                and (
                    movie_id in ($movie_id)
                    or -99 in ($movie_id)
                    )
            union all
            select
                cast(mobile as bigint) mobile,
                0 pr
            from
                upload_table.fn_uploadmobile_data
            where
                0 in ($dim)
                and length(mobile)=11
                and mobile is not null
                and regexp_like(mobile,'^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$')
            union all
            select
                cast(mobile as bigint) mobile,
                1 pr
            from
                upload_table.wdh_uploadmobile_data
            where
                1 in ($dim)
                and mobile is not null
                and regexp_like(mobile,'^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$')
            union all
            select
                usermobileno as mobile,
                2 pr
            from
                mart_movie.detail_myshow_saleorder
            where
                2 in ($dim)
                and sellchannel in ($sellchannel_id)
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
            union all
            select 
                order_mobile as mobile,
                3 pr
            from
                upload_table.detail_wg_saleorder
            where
                3 in ($dim)
                and item_id in (
                    select distinct
                        item_id
                    from (
                        select
                            item_id
                        from
                            upload_table.dim_wg_item
                        where (
                                type_lv1_name in ('$category_name')
                                or '全部' in ('$category_name')
                                ) 
                            and (
                                city_name in ('$area_name')
                                or province_name in ('$area_name')
                                or '全部' in ('$area_name')
                                )
                            and (
                                item_no in ($performance_id)
                                or -99=$performance_id
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
            ) mu
        group by
            1
        ) mou
        left join (
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
            ) mm
        on mm.mobile=mou.mobile
    where
        mm.mobile is null
    ) as c
where
    rank<=$limit
;
