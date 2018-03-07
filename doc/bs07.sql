
select 
    substr(x.pay_time,1,7) mt,
    sum(quantity) sq
from mart_movie.detail_maoyan_order_new_info x
join mart_movie.detail_maoyan_order_sale_cost_new_info y
on x.order_id=y.order_id
join mart_movie.dim_deal_new z
on y.deal_id=z.deal_id
WHERE x.pay_time>='$$monthfirst{-1m}'
and x.pay_time<'$$monthfirst'
and z.category=12
group by
    1
    
