#!/bin/bash
path="/Users/fannian/Documents/my_code/"

fut() {
echo `grep -iv "\-time" ${path}sql/${1}.sql | grep -iv "/\*"`
}
if [ $1 = 1 ]
then
so=`fut S_Order` 
sos=`fut S_OrderSalesPlanSnapshot`
st=`fut S_TicketClass`
sod=`fut S_OrderDelivery`
sc=`fut S_Customer`
lim="limit 10000"
file="bd01$1"
attach="${path}doc/${file}.sql"
fi

if [ $1 = 2 ] 
then
so=`fut dp_myshow__s_order` 
sos=`fut dp_myshow__s_ordersalesplansnapshot`
st=`fut dp_myshow__s_ticketclass`
sod=`fut dp_myshow__s_orderdelivery`
sc=`fut dp_myshow__s_customer`
file="bd01$1"
attach="${path}doc/${file}.sql"
lim=";"
fi

echo "select
    sc.Name,
    so.OrderID,
    so.MYOrderID,
    so.PaidTime,
    so.RefundStatus,
    sos.PerformanceID,
    sos.PerformanceName,
    sos.ShowName,
    st.Description,
    sod.ExpressFee,
    so.SalesPlanCount,
    so.SalesPlanSellPrice,
    so.SalesPlanSupplyPrice,
    so.TotalPrice
from
    (
    ${so}
    and TPID>=6
    ) so 
join (
    ${sos}
    and PerformanceID in (${2})
    ) sos
    on sos.OrderID=so.OrderID
left join (
    ${sc}
    and TPID>=6
    ) sc 
    on sc.TPID=so.TPID
left join (
    ${st}
    ) st
    on st.TicketClassID=sos.TicketClassID
left join (
    ${sod}
    ) sod
    on sod.OrderID=so.OrderID
$lim
">${attach}
echo "succuess,detail see ${attach}"
