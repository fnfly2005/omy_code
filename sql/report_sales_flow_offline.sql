/*销售明细表*/
select
    item_id,
    order_id,
    case when order_src=1 then 1
    else 0 end as ispalt,
    total_money/100 as total_money
from
    report_sales_flow
where
    order_id is not null
