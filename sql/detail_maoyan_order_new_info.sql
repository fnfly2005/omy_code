/*猫眼团单订单*/
select
    order_id,
    user_id,
    poi_id,
    quantity,
    mobile_phone,
    order_time,
    total_money/100 total_money,
    channel
from
    mart_movie.detail_maoyan_order_new_info
where
    pay_time is not null
    and category=12
    and pay_time>='$$begindate'
    and pay_time<'$$enddate'
