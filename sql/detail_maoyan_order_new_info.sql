/*猫眼团单订单*/
select
    substr(pay_time,1,10) dt,
    order_id,
    user_id,
    poi_id,
    quantity,
    mobile_phone,
    order_time,
    total_money/100 total_money,
    channel,
    case when channel_name is null then '其他'
    else channel_name end as channel_name
from
    mart_movie.detail_maoyan_order_new_info
where
    pay_time is not null
    and category=12
    and pay_time>='$$begindate'
    and pay_time<'$$enddate'
