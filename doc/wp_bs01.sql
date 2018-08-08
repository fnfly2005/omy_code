
select
    from_unixtime(create_time/1000,'%Y-%m-%d') dt,
    item_id,
    order_id,
    order_src,
    user_id,
    order_mobile as mobile,
    receive_mobile,
    pay_no,
    (total_money/100) as total_money
from
    report_sales_flow
where
    from_unixtime(create_time/1000,'%Y-%m-%d')>'2018-03-30'
;
