
select
    dt,
    channel_name,
    title,
    order_num,
    quantity,
    total_money,
    rank
from (
    select
        dt,
        channel_name,
        title,
        order_num,
        quantity,
        total_money,
        row_number() over (partition by dt,channel_name order by total_money desc) rank
    from (
        select
            dt,
            channel_name,
            title,
            count(distinct oni.order_id) order_num,
            sum(quantity) quantity,
            sum(total_money) total_money
        from (
            select substr(pay_time,1,10) dt, order_id, user_id, poi_id, quantity, mobile_phone, order_time, total_money/100 total_money, channel, case when channel_name is null then '其他' else channel_name end as channel_name from mart_movie.detail_maoyan_order_new_info where pay_time is not null and category=12 and pay_time>='$$begindate' and pay_time<'$$enddate'
            ) oni
            join (
            select distinct order_id, deal_id from mart_movie.detail_maoyan_order_sale_cost_new_info where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
            ) cni
            on oni.order_id=cni.order_id
            join (
            select deal_id, customerid as customer_code, title, regexp_extract(cityids,'[0-9]+') as mt_city_id from mart_movie.dim_deal_new where category=12
            ) dea
            on cni.deal_id=dea.deal_id
        group by
            1,2,3
            ) as ocd
    ) oc1
where
    rank<=10
;
