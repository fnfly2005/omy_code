#!/bin/bash
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
path="/Users/fannian/Documents/my_code/"
fun() {
echo `cat ${path}sql/${1}.sql | sed "s/-time1/${2:-${t1% *}}/g;
s/-time2/${3:-${t2% *}}/g;s/-time3/${4:-${t3% *}}/g"`
}
sc=`fun S_Category`
sp=`fun S_Performance`
ss=`fun S_SalesPlan`
st=`fun S_TicketClass`

file="yh02"
attach="${path}doc/${file}.sql"
echo "
select
    sc.Name,
    count(distinct sp.PerformanceID),
    count(distinct case when ss.TicketPrice>ss.SellPrice then sp.PerformanceID end)
from
    (
    $ss
    ) ss
join (
    $st
    ) st using(TicketClassID)
    join (
    $sp
    ) sp on sp.PerformanceID=st.PerformanceID
    join (
    $sc
    ) sc on sc.CategoryID=sp.CategoryID
group by
    1
limit 100
"|tee ${attach}
