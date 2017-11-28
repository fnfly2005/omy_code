#!/bin/bash
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
path="/Users/fannian/Documents/my_code/"

fut() {
echo `grep -iv "\-time" ${path}sql/${1}.sql`
}
so=`fut S_Order` 
sos=`fut S_OrderSalesPlanSnapshot`
st=`fut S_TicketClass`
ba=`fut BS_ActivityMap`
sod=`fut S_OrderDelivery`
sc=`fut S_Customer`

file="bd01"
attach="${path}doc/${file}.sql"
echo "
select
    sc.Name,
    so.OrderID,
    so.PaidTime,
    so.RefundStatus,
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
    PerformanceID=${3}
    ) sos
    on sos.OrderID=so.OrderID
left join (
    ${sc}
where
    TPID>=6
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
limit 10000
"|tee ${attach}
