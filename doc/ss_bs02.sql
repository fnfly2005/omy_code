
select so.order_id,
sellchannel,
dianping_userid,
meituan_userid,
usermobileno,
city_id,
salesplan_id,
supply_price,
sell_price,
salesplan_count,
totalprice,
maoyan_order_id,
customer_id,
order_reserve_status,
order_deliver_status,
order_refund_status,
order_create_time,
pay_time,
ticketed_time,
totalticketprice,
performance_id,
performance_name,
shop_name,
ticketclass_id,
ticketclass_description,
show_id,
show_name,
show_starttime,
salesplan_name,
setnumber,
ticket_price
from (select orderid as order_id, sellchannel, dpuserid as dianping_userid, mtuserid as meituan_userid, usermobileno, dpcityid as city_id, salesplanid as salesplan_id, salesplansupplyprice as supply_price, salesplansellprice as sell_price, salesplancount as salesplan_count, totalprice, myorderid as maoyan_order_id, tpid as customer_id, reservestatus as order_reserve_status, deliverstatus as order_deliver_status, refundstatus as order_refund_status, createtime as order_create_time, paidtime as pay_time, ticketedtime as ticketed_time, totalticketprice from S_Order where OrderID>2875394) as so
join (select orderid as order_id, performanceid as performance_id, performancename as performance_name, shopname as shop_name, ticketid as ticketclass_id, ticketname as ticketclass_description, showid as show_id, showname as show_name, showstarttime as show_starttime, salesplanname as salesplan_name, setnum as setnumber, salesplanticketprice as ticket_price from S_OrderSalesPlanSnapshot where OrderID>2875394) as sos
on so.order_id=sos.order_id
limit 20000;

