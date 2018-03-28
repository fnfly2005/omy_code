#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
per=`fun dim_myshow_performance.sql`
sre=`fun S_SettlementRefund.sql`
cus=`fun dim_myshow_customer.sql`

file="cw01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(spo.dt,1,7) mt,
    customer_type_name,
    customer_lvl1_name,
    case when sre.order_id is null then 'no'
    else 'yes' end as isrefund,
    count(distinct spo.order_id) as order_num,
    sum(spo.salesplan_count*spo.setnumber) as ticket_num,
    sum(spo.totalprice) as totalprice,
    sum(spo.grossprofit) as grossprofit,
    sum(spo.expressfee) as expressfee,
    sum(spo.discountamount) as discountamount,
    sum(spo.income) as income,
    sum(spo.expense) as expense,
    sum(spo.totalticketprice) as totalticketprice
from (
    $spo
    ) spo
   join (
   $per
   and category_name='休闲展览'
   ) per
   on spo.performance_id=per.performance_id
   left join (
   $sre
   ) sre
   on spo.order_id=sre.order_id
   left join (
   $cus
   ) cus
   on cus.customer_id=spo.customer_id
group by
    1,2,3,4
$lim">${attach}

echo "succuess,detail see ${attach}"
