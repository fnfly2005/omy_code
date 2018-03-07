/*猫眼团单订单*/
select
    order_id
from
    mart_movie.detail_maoyan_order_new_info
where
    pay_time is not null
    and pay_time>='$$begindate'
    and pay_time<'$$enddate'
