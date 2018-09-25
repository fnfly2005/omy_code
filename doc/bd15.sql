
select
    so.order_id,
    maoyan_order_id,
    md2.value2 as pt,
    UserName,
    IDNumber,
    mobile,
    meituan_userid,
    so.performance_id,
    so.performance_name,
    order_create_time,
    pay_time,
    md.value2,
    show_name,
    show_id,
    ticket_price,
    salesplan_name,
    province_name,
    city_name,
    district_name,
    detailedaddress,
    ticket_num,
    totalprice,
    qrcode
from (
    select substr(pay_time,1,7) as mt, substr(pay_time,1,10) as dt, substr(pay_time,12,2) as ht, order_id, maoyan_order_id, usermobileno as mobile, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, performance_name, meituan_userid, dianping_userid, show_name, show_id, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status, setnumber, salesplan_count, setnumber*salesplan_count as ticket_num, ticket_price, province_name, city_name, district_name, ticketclass_description, detailedaddress, salesplan_id, salesplan_name from mart_movie.detail_myshow_saleorder
    where
        pay_time is not null
        and ((pay_time>='$$begindate'
        and pay_time<'$$enddate')
        or 1=$pay_flag)
        and performance_id in ($performance_id)
    ) so
    join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from mart_movie.dim_myshow_dictionary where 1=1
        and key_name='sellchannel'
        and key1>'0'
        ) md2
    on md2.key=so.sellchannel
    left join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from mart_movie.dim_myshow_dictionary where 1=1
        and key_name='order_refund_status'
        ) md
    on md.key=so.order_refund_status
    left join (
        select
            OrderID as order_id,
            UserName,
            IDNumber
        from origindb.dp_myshow__s_orderidentification where idtype=1 and (createtime>='2018-07-14' or (createtime<'2018-07-14' and ticketnumber>0))
            and performanceid in ($performance_id)
            and $typ=1
        ) soi
    using(order_id)
    left join (
        select orderID as order_id, qrcode from origindb.dp_myshow__s_orderticket where CreateTime>='$$begindate' and CreateTime<'$$enddate'
        and qrcode is not null
        and createtime>'2017-11-17'
        and $typ=2
        ) as ket
    on ket.order_id=so.order_id

;
