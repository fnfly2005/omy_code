
select
    substr(pay_time,1,7) mt,
    sum(quantity) as sku_num
from
    mart_movie.detail_maoyan_order_sale_cost_new_info
where
    pay_time is not null
    and pay_time>='$$begindate'
    and pay_time<'$$enddate'
    and deal_id in (
        select
            deal_id
        from
            mart_movie.dim_deal_new
        where
            category=12
            )
group by
    1
;
