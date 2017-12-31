
select distinct
    passport_user_mobile
from
    (
    select from_unixtime(payment_time/1000,'%Y-%m-%d') dt, order_id, case when order_src=1 then 1 else 0 end as ispalt, passport_user_mobile, total_money/100 as total_money from order_form where order_id is not null
    ) of
    join 
    (
    select item_id, order_id, case when order_src=1 then 1 else 0 end as ispalt, total_money/100 as total_money from report_sales_flow where order_id is not null
    ) rsf
    on of.order_id=rsf.order_id
    join
    (
    select id, title_cn, type_id, source from item_info where id is not null
    and item_no in ('1712073160')
    ) ii
    on rsf.item_id=ii.id
;
