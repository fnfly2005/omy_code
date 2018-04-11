/*团购结算*/
select
    substr(pay_time,1,10) dt,
    order_id,
    deal_id,
    quantity,
    purchase_price,
    purchase_price-settle_price*quantity
from
    mart_movie.detail_maoyan_order_sale_cost_new_info
where
    pay_time is not null
    and pay_time>='$$begindate'
    and pay_time<'$$enddate'
