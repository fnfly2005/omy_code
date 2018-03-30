/*订单来源报表*/
select
    `from` x_from,
    item_id,
    pay_money,
    order_id
from
    report_sales_from
where
    `from` is not null
    and create_time>=1000*unix_timestamp('-time1 00:00:00')
    and create_time<1000*unix_timestamp('-time2 00:00:00')
