/*微格选座订单表*/
select
    price_id,
    price_name,
    order_id,
    count(1) sku_num
from
    order_ticket
group by
    1,2,3
