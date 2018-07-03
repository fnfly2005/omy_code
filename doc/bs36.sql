
select
    $dim,
    $dw,
    count(distinct so.$user) as usernum,
    count(distinct case when fdw>1 then so.$user end) as cross_usernum
from (
    select
        $user,
        count(distinct order_id) fon,
        count(distinct $dw) fdw,
        count(distinct dt) fdt
    from (
        select substr(pay_time,1,7) as mt, substr(pay_time,1,10) as dt, order_id, maoyan_order_id, usermobileno as mobile, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, show_name, show_id, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status, setnumber, salesplan_count, setnumber*salesplan_count as ticket_num, ticket_price, province_name, city_name, ticketclass_description, detailedaddress from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
            and sellchannel not in (9,10,11)
            and (
                (meituan_userid<>0
                and '$user'='meituan_userid')
                or (usermobileno not in (13800138000,13000000000)
                    and usermobileno is not null
                    and '$user'='mobile')
                )
            ) so
        left join (
            select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
            ) per
        on per.performance_id=so.performance_id
        left join (
            select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
            and key_name='sellchannel'
            ) md
        on md.key=so.sellchannel
        left join (
            select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
            ) cus
        on cus.customer_id=so.customer_id
    group by
        1
    ) so1
    left join (
        select substr(pay_time,1,7) as mt, substr(pay_time,1,10) as dt, order_id, maoyan_order_id, usermobileno as mobile, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, show_name, show_id, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status, setnumber, salesplan_count, setnumber*salesplan_count as ticket_num, ticket_price, province_name, city_name, ticketclass_description, detailedaddress from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
            and sellchannel not in (9,10,11)
            and (
                (meituan_userid<>0
                and '$user'='meituan_userid')
                or (usermobileno not in (13800138000,13000000000)
                    and usermobileno is not null
                    and '$user'='mobile')
                )
        ) sos
    on so1.$user=sos.$user
    left join (
        select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
        ) per
    on per.performance_id=sos.performance_id
    left join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
        and key_name='sellchannel'
        ) md
    on md.key=sos.sellchannel
    left join (
        select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
        ) cus
    on cus.customer_id=sos.customer_id
group by
    1,2
;
