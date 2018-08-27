
select
    '猫眼' as das,
    ss.performance_id,
    performance_name,
    customer_type_name,
    category_name,
    province_name,
    city_name,
    shop_name,
    celebrityname,
    case salesplan_sellout_flag 
        when 0 then '在售'
        when 3 then '停售'
    else '售罄' end as salesplan_sellout_flag,
    case when onsaletime is not null then onsaletime
    else salesplan_ontime end as onsaletime,
    salesplan_ontime,
    salesplan_offtime,
    totalprice
from (
    select
        customer_type_id,
        customer_type_name,
        performance_id,
        performance_name,
        category_name,
        province_name,
        city_name,
        shop_name,
        min(salesplan_sellout_flag) as salesplan_sellout_flag,
        min(show_starttime) as show_starttime,
        max(show_endtime) as show_endtime,
        min(salesplan_ontime) as salesplan_ontime,
        max(salesplan_offtime) as salesplan_offtime
    from mart_movie.dim_myshow_salesplan where 1=1
        and category_id in ($category_id)
        and ((city_id in ($city_id) and $dit=1)
            or (city_id in (
                    select
                        city_id
                    from mart_movie.dim_myshow_city where 1=1
                        and province_id in ($province_id)
                        )
                and $dit=0))
        and (performance_id in ($performance_id)
            or -99 in ($performance_id))
        and (
            regexp_like(performance_name,'$performance_name')
            or '全部'='$performance_name'
            )
        and (
            regexp_like(customer_name,'$customer_name')
            or '全部'='$customer_name'
            )
        and (
            regexp_like(shop_name,'$shop_name')
            or '全部'='$shop_name'
            )
        and ((show_starttime>='$$begindate'
            and show_starttime<'$$enddate')
            or $timerange=0)
        and customer_type_id in ($customer_type_id)
    group by
        1,2,3,4,5,6,7,8
    ) as ss
    left join (
        select
            performanceid as performance_id,
            min(OnSaleTime) as OnSaleTime
        from origindb.dp_myshow__s_performancesaleremind where Status=1
            and onsaletime is not null
        group by
            1
        ) sps
        on sps.performance_id=ss.performance_id
    left join (
        select
            customer_type_id,
            performance_id,
            sum(totalprice) as totalprice
        from (
            select
                customer_id,
                performance_id,
                sellchannel,
                sum(totalprice) as totalprice
            from mart_movie.detail_myshow_salepayorder
            group by
                1,2,3
            ) spo
            join (
                select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where 1=1
                    and key_name='sellchannel'
                    and key1<>'0'
                ) md
            on spo.sellchannel=md.key
            left join (
                select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where 1=1
                ) cus
            on cus.customer_id=spo.customer_id
        group by
            1,2
        ) so
        on so.performance_id=ss.performance_id
        and so.customer_type_id=ss.customer_type_id
    left join (
        select
            performanceid as performance_id,
            array_agg(celebrityname) celebrityname
        from origindb.dp_myshow__s_celebrityperformancerelation where status<>0
        group by
            1
        ) cel
        on ss.performance_id=cel.performance_id
where
    salesplan_sellout_flag in ($salesplan_sellout_flag)
union all
select
    '微格' as das,
    performance_id,
    performance_name,
    '自营' as customer_type_name,
    category_name,
    province_name,
    city_name,
    shop_name,
    null as celebrityname,
    '停售' salesplan_sellout_flag,
    null as onsaletime,
    null as salesplan_ontime,
    null as salesplan_offtime,
    totalprice
from (
    select performance_id, item_id, performance_name, category_id, category_name, city_id, city_name, province_id, province_name, area_1_level_id, area_1_level_name, area_2_level_id, area_2_level_name, venue_id, shop_name, type_id, type_lv2_name, venue_type from upload_table.dim_wg_performance_s where 1=1
        and category_id in ($category_id)
        and ((city_id in ($city_id) and $dit=1)
            or (city_id in (
                    select
                        city_id
                    from mart_movie.dim_myshow_city where 1=1
                        and province_id in ($province_id)
                        )
                and $dit=0))
        and (performance_id in ($performance_id)
            or -99 in ($performance_id))
        and (
            regexp_like(performance_name,'$performance_name')
            or '全部'='$performance_name'
            )
        and (
            regexp_like(shop_name,'$shop_name')
            or '全部'='$shop_name'
            )
        and $timerange=0
        and $das=1
        and 3 in ($salesplan_sellout_flag)
        and 2 in ($customer_type_id)
    ) wpe
    left join (
        select
            item_id,
            sum(total_money) as totalprice
        from upload_table.detail_wg_saleorder
        where
            length(pay_no)>5
        group by
            1
        ) wso
    on wso.item_id=wpe.item_id
;
