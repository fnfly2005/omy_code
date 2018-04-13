/*用户染色项目-电影交易用户表-历史数据*/
select
    user_id,
    mobile,
    case when md1.key is not null then md1.value3
    else 'oth' end as user_source,
    city_id,
    movie_id,
    active_date
from (
    select 
        user_id,
        max(order_id) as order_id
    from
        mart_movie.detail_order_seat_info
    where mobile_phone is not null
        and to_date(order_time)>='$now.month_begin_date.date'
        and to_date(order_time)<='$now.month_end_date.date'
    group by
        user_id
    ) as do1
    left join (
        select
            order_id,
            mobile_phone as mobile,
            movie_id,
            cinema_id,
            order_source,
            substr(order_time,1,10) as active_date
        from
            mart_movie.detail_order_seat_info
        where to_date(order_time)>='$now.month_begin_date.date'
        and to_date(order_time)<='$now.month_end_date.date'
        ) as do2
        on do1.order_id=do2.order_id
    left join (
        select
            cinema_id,
            city_id
        from
            mart_movie.dim_cinema
            ) as cin
        on cin.cinema_id=do2.cinema_id
    left join (
        select
            key,
            value3
        from
            upload_table.myshow_dictionary
        where
            key_name='order_source'
            ) as md1
        on md1.key=do2.order_source
