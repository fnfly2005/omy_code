/*订单表*/
select
    from_unixtime(payment_time/1000,'%Y-%m-%d') dt,
    order_id,
    case when order_src=1 then 1
    else 0 end as ispalt,
    passport_user_mobile,
    total_money/100 as total_money
from
    order_form
where
    order_id is not null
