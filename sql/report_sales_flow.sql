/*销售明细表*/
select
    item_id,
    order_id,
    total_money/100 as total_money
from
    report_sales_flow
where
    pay_no is not null
    and create_time>=1000*unix_timestamp('-time3 00:00:00')
    and create_time<1000*unix_timestamp('-time2 00:00:00')
    and order_src in (2,12,15,16,8,9,14,7)
