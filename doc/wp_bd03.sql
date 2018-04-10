
select
    dt,
    x_from,
    price_name,
    sum(pay_money) as pay_money,
    sum(sku_num) as sku_num
from (
    select date as dt, `from` x_from, item_id, pay_money/100 pay_money, order_id from report_sales_from where `from` is not null
    and item_id in (
        select id
        from item_info
        where item_no in ('1712073160')
        )
    ) rsf
    join (
        select
            price_id,
            price_name,
            order_id,
            count(1) sku_num
        from
            order_ticket
        where item_id in (
            select id
            from item_info
            where item_no in ('1712073160')
            )
        group by
            1,2,3
        ) tic
    on tic.order_id=rsf.order_id
group by
    1,2,3
;
