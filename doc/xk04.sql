
select
    '$$today{-1d}' as dt,
    area_1_level_name,
    sum(seat_num) as seat_num,
    sum(ticket_num) as ticket_num
from (
    select
        area_1_level_name,
        city_name,
        shop_id,
        show_starttime,
        seat_num,
        sum(ticket_num) as ticket_num
    from (
        select distinct
            area_1_level_name,
            shs.shop_id,
            city_name,
            performance_name,
            show_id,
            substr(show_starttime,1,10) as show_starttime,
            seat_num
        from (
            select
                shop_id,
                cast(seat_num as bigint) as seat_num
            from
                upload_table.shop_seat
            ) shs
            left join (
                select shop_id, category_name, show_starttime, performance_id, performance_name, show_id, show_name, ticketclass_id, ticket_price, salesplan_ontime, salesplan_createtime, customer_id, customer_name, customer_type_name, customer_lvl1_name, shop_name, city_name, area_1_level_name from mart_movie.dim_myshow_salesplan
                where
                    show_endtime>='$$today{-7d}'
                    and show_endtime<'$$today{-0d}'
                    and category_id=1
                    and performance_name not like '%测试%'
                ) ss
            on ss.shop_id=shs.shop_id
        where
            shop_name is not null
        ) as sop
        left join (
            select
                show_id,
                sum(setnumber*salesplan_count) as ticket_num
            from
                mart_movie.detail_myshow_saleorder
            where
                pay_time is not null
            group by
                1
            ) so
        on so.show_id=sop.show_id
    group by
        1,2,3,4,5
    ) sos
group by
    1,2
union all
select
    '$$today{-1d}' as dt,
    '全部' as area_1_level_name,
    sum(seat_num) as seat_num,
    sum(ticket_num) as ticket_num
from (
    select
        area_1_level_name,
        city_name,
        shop_id,
        show_starttime,
        seat_num,
        sum(ticket_num) as ticket_num
    from (
        select distinct
            area_1_level_name,
            shs.shop_id,
            city_name,
            performance_name,
            show_id,
            substr(show_starttime,1,10) as show_starttime,
            seat_num
        from (
            select
                shop_id,
                cast(seat_num as bigint) as seat_num
            from
                upload_table.shop_seat
            ) shs
            left join (
                select shop_id, category_name, show_starttime, performance_id, performance_name, show_id, show_name, ticketclass_id, ticket_price, salesplan_ontime, salesplan_createtime, customer_id, customer_name, customer_type_name, customer_lvl1_name, shop_name, city_name, area_1_level_name from mart_movie.dim_myshow_salesplan
                where
                    show_endtime>='$$today{-7d}'
                    and show_endtime<'$$today{-0d}'
                    and category_id=1
                    and performance_name not like '%测试%'
                ) ss
            on ss.shop_id=shs.shop_id
        where
            shop_name is not null
        ) as sop
        left join (
            select
                show_id,
                sum(setnumber*salesplan_count) as ticket_num
            from
                mart_movie.detail_myshow_saleorder
            where
                pay_time is not null
            group by
                1
            ) so
        on so.show_id=sop.show_id
    group by
        1,2,3,4,5
    ) sos
group by
    1,2
;
