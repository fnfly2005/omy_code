
select
    substr(pay_time,1,10) dt,
    'y' as type,
    '团购' as lv1_type,
    sum(purchase_price) as totalprice,
    count(distinct order_id) as order_num,
    sum(quantity) as ticket_num
from
    mart_movie.detail_maoyan_order_sale_cost_new_info
where
    pay_time is not null
    and pay_time>='$$today{-1d}'
    and pay_time<'$$today{-0d}'
    and deal_id in (
        select
            mydealid
        from
            origindb.dp_myshow__s_deal
            )
group by
    1,2,3
union all
select
    dt,
    key1 as type,
    value4 as lv1_type,
    sum(totalprice) as totalprice,
    count(distinct order_id) as order_num,
    sum(ticket_num) as ticket_num
from (
    select substr(pay_time,1,7) as mt, substr(pay_time,1,10) as dt, substr(pay_time,12,2) as ht, order_id, maoyan_order_id, usermobileno as mobile, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, show_name, show_id, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status, setnumber, salesplan_count, setnumber*salesplan_count as ticket_num, ticket_price, province_name, city_name, ticketclass_description, detailedaddress, salesplan_id from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$today{-1d}' and pay_time<'$$today{-0d}'
    ) so
    left join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
        and key_name='sellchannel'
        ) md
    on so.sellchannel=md.key
group by
    1,2,3
;
