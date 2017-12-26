
select
    substr(dt,1,7) mt,
    dict_value,
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
    select id, title_cn, type_id, source from item_info where id is not null
    ) ii
    on rsf.item_id=ii.id
    left join 
    (
    select id, name from item_type where is_visible=1
    ) it
    on ii.type_id=it.id
    left join
    (
    select dict_key, dict_value from dictionary where group_name is not null
    and group_name='ticket_source'
    ) dic 
    on dic.dict_key=ii.source
group by
    1,2,3
;
