
select distinct
    passport_user_mobile
from
    (
    select from_unixtime(payment_time/1000,'%Y-%m-%d') dt, order_id, case when order_src=10 then 1 else 0 as ismaoyan, passport_user_mobile, total_money/100 as total_money from order_form where payment_time is not null and order_src in (2,12,15,16,8,9,10,14,7)
    ) of
    join 
    (
    select item_id, order_id, case when order_src=10 then 1 else 0 end as ismaoyan, total_money/100 as total_money from report_sales_flow where pay_no is not null and order_src in (2,12,15,16,8,9,10,14,7)
    ) rsf
    on of.order_id=rsf.order_id
    join
    (
    select id, title_cn, type_id, source from item_info where id is not null
    and item_no in ('1801158077')
    ) ii
    on rsf.item_id=ii.id
;
