
select
    substr(of.dt,1,7) as mt,
    it.name,
    sum(of.total_money) as total_money
from (
    /*订单表*/ select from_unixtime(payment_time/1000,'%Y-%m-%d') dt, order_id, case when order_src=10 then 1 else 0 as ismaoyan, passport_user_mobile, total_money/100 as total_money from order_form where payment_time is not null and payment_time>=1000*unix_timestamp('2018-01-01 00:00:00') and payment_time<1000*unix_timestamp('2018-03-01 00:00:00') and order_src in (2,12,15,16,8,9,10,14,7) 
    ) of
    join (
    /*销售明细表*/ select item_id, order_id, case when order_src=10 then 1 else 0 end as ismaoyan, total_money/100 as total_money from report_sales_flow where pay_no is not null and create_time>=1000*unix_timestamp('2017-12-31 00:00:00') and create_time<1000*unix_timestamp('2018-03-01 00:00:00') and order_src in (2,12,15,16,8,9,10,14,7)
    ) rsf
    on of.order_id=rsf.order_id
    and of.ismaoyan=0
    and rsf.ismaoyan=0
    join (
        /*微格项目信息表*/ select id, title_cn, type_id, source from item_info where id is not null
        ) ii
    on rsf.item_id=ii.id
    join (
        /*项目类目表*/ select id, name from item_type where is_visible=1
        ) it
    on ii.type_id=it.id
group by
    1,2
;
