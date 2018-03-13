
select
    usermobileno,
    UserName,
    IDNumber,
    maoyan_order_id,
    order_create_time,
    value2
from (
    select order_id, maoyan_order_id, usermobileno, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
    and performance_id=$performance_id
    ) so
    left join (
    select PerformanceID as performance_id, OrderID as order_id, UserName, IDNumber from origindb.dp_myshow__s_orderidentification where performanceid=$performance_id
    ) soi
    using(order_id)
    left join (
    select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
    and key_name='order_refund_status'
    ) md
    on md.key=so.order_refund_status
group by
    1,2,3,4,5,6
;
