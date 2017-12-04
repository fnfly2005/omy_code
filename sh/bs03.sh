#!/bin/bash
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
path="/Users/fannian/Documents/my_code/"
fun() {
echo `cat ${path}sql/${1}.sql | sed "s/-time1/${2:-${t1% *}}/g;
s/-time2/${3:-${t2% *}}/g;s/-time3/${4:-${t3% *}}/g" | grep -iv "/\*"`
}
so=`fun dp_myshow__s_order`
sos=`fun dp_myshow__s_ordersalesplansnapshot`
sd=`fun dp_myshow__s_dpcitylist`
sc=`fun dp_myshow__s_category`
sp=`fun dp_myshow__s_performance`
bam=`fun dp_myshow__bs_activitymap`
scu=`fun dp_myshow__s_customer`

file="bs03"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    s1.dt,
    s1.tp_type,
    s1.s_p_num,
    s2.a_p_num,
    s1.TotalPrice
from
(select
    substr(so.PaidTime,1,10) dt,
    'all' tp_type,
    count(distinct sos.PerformanceID) s_p_num,
    sum(so.TotalPrice) TotalPrice
from
    (
    $sos
    ) sos
    join 
    (
    $so
    ) so on so.OrderID=sos.OrderID
group by
    1,2
union all
select
    substr(so.PaidTime,1,10) dt,
    so.tp_type,
    count(distinct sos.PerformanceID) s_p_num,
    sum(so.TotalPrice) TotalPrice
from
    (
    $sos
    ) sos
    join 
    (
    $so
    ) so on so.OrderID=sos.OrderID
group by
    1,2) s1
join 
(select
    bam.tp_type,
    count(distinct case when sp.BSPerformanceID is not null then sp.BSPerformanceID else sp.PerformanceID end) a_p_num
from
    (
    $sp
    and TicketStatus in (2,3)
    and EditStatus=1
    ) sp
    left join 
    (
    $bam
    ) bam on sp.BSPerformanceID=bam.ActivityID
group by
    1
union all
select
    'all' tp_type,
    count(distinct case when sp.BSPerformanceID is not null then sp.BSPerformanceID else sp.PerformanceID end) a_p_num
from
    (
    $sp
    and TicketStatus in (2,3)
    and EditStatus=1
    ) sp
group by
    1
    ) s2 on s2.tp_type=s1.tp_type
union all
select
    'week' dt,
    s1.tp_type,
    s1.s_p_num,
    s2.a_p_num,
    s1.TotalPrice
from
(select
    'all' tp_type,
    count(distinct sos.PerformanceID) s_p_num,
    sum(so.TotalPrice) TotalPrice
from
    (
    $sos
    ) sos
    join 
    (
    $so
    ) so on so.OrderID=sos.OrderID
group by
    1
union all
select
    so.tp_type,
    count(distinct sos.PerformanceID) s_p_num,
    sum(so.TotalPrice) TotalPrice
from
    (
    $sos
    ) sos
    join 
    (
    $so
    ) so on so.OrderID=sos.OrderID
group by
    1) s1
join 
(select
    bam.tp_type,
    count(distinct case when sp.BSPerformanceID is not null then sp.BSPerformanceID else sp.PerformanceID end) a_p_num
from
    (
    $sp
    and TicketStatus in (2,3)
    and EditStatus=1
    ) sp
    left join 
    (
    $bam
    ) bam on sp.BSPerformanceID=bam.ActivityID
group by
    1
union all
select
    'all' tp_type,
    count(distinct case when sp.BSPerformanceID is not null then sp.BSPerformanceID else sp.PerformanceID end) a_p_num
from
    (
    $sp
    and TicketStatus in (2,3)
    and EditStatus=1
    ) sp
group by
    1
    ) s2 on s2.tp_type=s1.tp_type
$lim">${attach}

echo "
select
    dt,
    tp_type,
    PerformanceID,
    PerformanceName,
    TotalPrice,
    rank
from
(select
    dt,
    tp_type,
    PerformanceID,
    PerformanceName,
    TotalPrice,
    row_number() over (PARTITION BY dt,tp_type order by TotalPrice desc) rank
from
(select
    substr(so.PaidTime,1,10) dt,
    'all' tp_type,
    sos.PerformanceID,
    sos.PerformanceName,
    sum(so.TotalPrice) TotalPrice
from
    (
    $sos
    ) sos
    join 
    (
    $so
    ) so on so.OrderID=sos.OrderID
group by
    1,2,3,4
union all
select
    substr(so.PaidTime,1,10) dt,
    so.tp_type,
    sos.PerformanceID,
    sos.PerformanceName,
    sum(so.TotalPrice) TotalPrice
from
    (
    $sos
    ) sos
    join 
    (
    $so
    ) so on so.OrderID=sos.OrderID
group by
    1,2,3,4) s1
    ) s2
where
    rank<=10
union all
select
    'week' dt,
    tp_type,
    PerformanceID,
    PerformanceName,
    TotalPrice,
    rank
from
(select
    tp_type,
    PerformanceID,
    PerformanceName,
    TotalPrice,
    row_number() over (PARTITION BY tp_type order by TotalPrice desc) rank
from
(select
    'all' tp_type,
    sos.PerformanceID,
    sos.PerformanceName,
    sum(so.TotalPrice) TotalPrice
from
    (
    $sos
    ) sos
    join 
    (
    $so
    ) so on so.OrderID=sos.OrderID
group by
    1,2,3
union all
select
    so.tp_type,
    sos.PerformanceID,
    sos.PerformanceName,
    sum(so.TotalPrice) TotalPrice
from
    (
    $sos
    ) sos
    join 
    (
    $so
    ) so on so.OrderID=sos.OrderID
group by
    1,2,3) s1
    ) s2
where
    rank<=10
$lim">>${attach}

echo "succuess,detail see ${attach}"
