/*交易时销售计划快照表*/
select
    orderid as order_id,
    performanceid as performance_id,
    performancename as performance_name,
    shopname as shop_name,
    ticketid as ticketclass_id,
    ticketname as ticketclass_description,
    showid as show_id,
    showname as show_name,
    showstarttime as show_starttime,
    salesplanname as salesplan_name,
    setnum as setnumber,
    salesplanticketprice as ticket_price
from
    S_OrderSalesPlanSnapshot
where
    OrderID>-time1
