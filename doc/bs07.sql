
select 
    substr(dt,1,7) as mt,
    sum(total_money) as total_money,
    count(distinct oni.order_id) as order_num,
    sum(quantity) sku_num,
    count(distinct deal_id) dea_num
from (
    select substr(pay_time,1,10) dt, order_id, user_id, poi_id, quantity, mobile_phone, order_time, total_money/100 total_money, channel, case when channel_name is null then '其他' else channel_name end as channel_name from mart_movie.detail_maoyan_order_new_info where pay_time is not null and category=12 and pay_time>='$$begindate' and pay_time<'$$enddate'
    ) oni
    join (
    select order_id, deal_id from mart_movie.detail_maoyan_order_sale_cost_new_info where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
    ) cni
    on oni.order_id=cni.order_id
group by 
    1
;
