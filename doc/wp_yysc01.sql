
select
    dt,
    name,
    title_cn,
    count(distinct of.order_id) so_num,
    sum(of.total_money) so_gmv
from
    (
    select from_unixtime(payment_time/1000,'%Y-%m-%d') dt, order_id, total_money/100 as total_money from order_form where payment_time is not null and order_src in (2,12,15,16,8,9,14,7)
    ) of
    join 
    (
    select item_id, order_id, total_money/100 as total_money from report_sales_flow where pay_no is not null and order_src in (2,12,15,16,8,9,14,7)
    ) rsf
    on of.order_id=rsf.order_id
    join
    (
    select id, title_cn, type_id from item_info where id is not null
    and item_no in ('1706302530')
    ) ii
    on rsf.item_id=ii.id
    join 
    (
    select id, name from item_type where is_visible=1
    ) it
    on ii.type_id=it.id
group by
    1,2,3
;

select
    substr(dt,1,7) mt,
    name,
    count(distinct of.order_id) so_num,
    sum(of.total_money) so_gmv
from
    (
    select from_unixtime(payment_time/1000,'%Y-%m-%d') dt, order_id, total_money/100 as total_money from order_form where payment_time is not null and order_src in (2,12,15,16,8,9,14,7)
    ) of
    join 
    (
    select item_id, order_id, total_money/100 as total_money from report_sales_flow where pay_no is not null and order_src in (2,12,15,16,8,9,14,7)
    ) rsf
    on of.order_id=rsf.order_id
    join
    (
    select id, title_cn, type_id from item_info where id is not null
    ) ii
    on rsf.item_id=ii.id
    join 
    (
    select id, name from item_type where is_visible=1
    and name in ('流行')
    ) it
    on ii.type_id=it.id
group by
    1,2
;
