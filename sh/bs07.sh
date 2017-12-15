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
dc=`fun dim_myshow_customer`
ssp=`fun dp_myshow__s_salesplan`
ds=`fun dim_myshow_show`

file="bs07"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(PaidTime,1,7) mt,
    sum(TotalPrice) TotalPrice,
    sum(SetNum*SalesPlanCount) t_num,
    count(distinct so.OrderID) so_nume,
    count(distinct performance_id) sp_num
from
    (
    $so
    ) so
    join 
    (
    $sos
    ) sos
    on so.OrderID=sos.OrderID
group by
    1
$lim
">${attach}
echo "select
    count(distinct shop_id) as_num,
    count(distinct case when customer_type_id=2 then shop_id end) s_num
from
    (
    $ssp
    ) ssp
    join 
    (
    $ds
    ) ds
    on ssp.show_id=ds.show_id
    join
    (
    $dc
    ) dc 
    on dc.customer_id=ssp.customer_id
    ">>${attach}
echo "
select substr(x.pay_time,1,7) mt,
    sum(quantity) sq
from mart_movie.detail_maoyan_order_new_info x
join mart_movie.detail_maoyan_order_sale_cost_new_info y
on x.order_id=y.order_id
join mart_movie.dim_deal_new z
on y.deal_id=z.deal_id
WHERE x.pay_time>='2017-10-01'
and x.pay_time<'2017-12-01'
and z.category=12
group by
    1
    ">>${attach}
echo "succuess,detail see ${attach}"
