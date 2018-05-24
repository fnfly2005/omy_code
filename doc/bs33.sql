
select
    partition_date as dt,
    order_id,
    sellchannel,
    dianping_userid,
    meituan_userid,
    supply_price,
    salesplan_count,
    totalprice,
    maoyan_order_id,
    customer_id,
    wxopenid,
    order_create_time,
    pay_time,
    setnumber,
    ticket_price,
    settlementpayment_id
from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
    and sellchannel=5
;
