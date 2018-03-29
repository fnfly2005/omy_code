/*团购结算*/
select distinct
    order_id,
    deal_id
from
    mart_movie.detail_maoyan_order_sale_cost_new_info
where
    pay_time is not null
    and pay_time>='$$begindate'
    and pay_time<'$$enddate'
