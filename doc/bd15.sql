
select distinct
    so.order_id,
    maoyan_order_id,
    IDNumber,
    UserName,
    mobile,
    so.performance_id,
    order_create_time,
    value2,
    show_name,
    show_id,
    ticket_price,
    salesplan_name,
    detailedaddress,
    TicketNumber
from (
    select substr(pay_time,1,7) as mt, substr(pay_time,1,10) as dt, substr(pay_time,12,2) as ht, order_id, maoyan_order_id, usermobileno as mobile, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, show_name, show_id, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status, setnumber, salesplan_count, setnumber*salesplan_count as ticket_num, ticket_price, province_name, city_name, ticketclass_description, detailedaddress, salesplan_id, salesplan_name from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
    and performance_id in ($performance_id)
    ) so
    left join (
    select id, PerformanceID as performance_id, OrderID as order_id, UserName, IDNumber, TicketNumber from origindb.dp_myshow__s_orderidentification where TicketNumber>0
    and performanceid in ($performance_id)
    ) soi
    using(order_id)
    left join (
    select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
    and key_name='order_refund_status'
    ) md
    on md.key=so.order_refund_status
;
