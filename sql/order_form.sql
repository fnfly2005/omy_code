/*订单表*/
select
    from_unixtime(payment_time/1000,'%Y-%m-%d') dt,
    order_id,
    total_money/100 as total_money
from
    order_form
where
    payment_time is not null
    and payment_time>=1000*unix_timestamp('-time1 00:00:00')
    and payment_time<1000*unix_timestamp('-time2 00:00:00')
    and order_src in (2,12,15,16,8,9,14,7)
