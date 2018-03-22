/*用户染色项目-电影交易用户表*/
select
from (
    select 
        user_id,
        max(order_id) order_id
    from
        mart_movie.detail_order_seat_info
    where mobile_phone is not null
        and order_time>='$now.month_begin_date.date'
        and order_time<'$now.month_end_date.date'
    ) do1
    left join (
    select
    from
