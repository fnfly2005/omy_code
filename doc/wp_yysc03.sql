
select
    dt,
    x_from,
    count(distinct of.order_id) so_num,
    sum(of.total_money) so_gmv
from (
        select id, title_cn, type_id, source from item_info where id is not null
        and item_no in ('1712073160')
        ) ii
    join (
        select item_id, order_id, total_money/100 as total_money from report_sales_flow where pay_no is not null and order_src in (2,12,15,16,8,9,14,7)
        ) rsf
    on rsf.item_id=ii.id
    join (
        select from_unixtime(payment_time/1000,'%Y-%m-%d') dt, order_id, total_money/100 as total_money from order_form where payment_time is not null and order_src in (2,12,15,16,8,9,14,7)
        ) of
    on of.order_id=rsf.order_id
group by
    1,2
;
