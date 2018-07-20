/*订单支付明细表*/
select
    partition_date as dt,
    order_id,
    sellchannel,
    customer_id,
    performance_id,
    meituan_userid,
    show_id,
    totalprice,
    grossprofit,
    setnumber,
    salesplan_count,
    setnumber*salesplan_count as ticket_num,
    expressfee,
    discountamount,
    income,
    expense,
    totalticketprice,
    ticket_price,
    sell_price,
    project_id,
    bill_id,
    salesplan_id,
    city_id,
    pay_time,
    substr(pay_time,12,2) as ht
from
    mart_movie.detail_myshow_salepayorder
where
    partition_date>='$$begindate'
    and partition_date<'$$enddate'
