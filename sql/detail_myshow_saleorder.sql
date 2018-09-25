/*订单明细表*/
select
    substr(pay_time,1,7) as mt,
    substr(pay_time,1,10) as dt,
    substr(pay_time,12,2) as ht,
    order_id,
    maoyan_order_id,
    usermobileno as mobile,
    recipientidno,
    sellchannel,
    city_id,
    totalprice,
    customer_id,
    performance_id,
    performance_name,
    meituan_userid,
    dianping_userid,
    show_name,
    show_id,
    pay_time,
    consumed_time,
    show_endtime,
    show_starttime,
    order_create_time,
    order_refund_status,
    setnumber,
    salesplan_count,
    setnumber*salesplan_count as ticket_num,
    ticket_price,
    province_name,
    city_name,
    district_name,
    ticketclass_description,
    detailedaddress,
    salesplan_id,
    salesplan_name
from
    mart_movie.detail_myshow_saleorder
where
    pay_time is not null
    and pay_time>='$$begindate'
    and pay_time<'$$enddate'
