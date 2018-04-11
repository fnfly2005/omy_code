/*猫眼团单订单*/
select
    order_id,
    user_id,
    poi_id,
    mobile_phone,
    order_time,
    case when pay_time>='$$begindate'
        and pay_time<'$$enddate' then 1
    else 0 end today_flag,
    total_money/100 total_money,
    channel,
    case when channel_name is null then '其他'
    else channel_name end as channel_name
from
    mart_movie.detail_maoyan_order_new_info
where
    pay_time is not null
    and category=12
    and modified>='$$begindate'
    and modified<'$$enddate'
