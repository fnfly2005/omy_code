#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

cgr=`fun dp_myshowcoupon__s_coupongroup.sql` 
cou=`fun dp_myshowcoupon__s_coupon.sql`
cur=`fun dp_myshowcoupon__s_couponuserecord.sql`
spo=`fun detail_myshow_salepayorder.sql`

file="yysc10"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    spo.dt,
    cgr.batch_id,
    cgr.batch_name,
    cgr.denomination,
    cgr.begindate,
    cgr.enddate,
    count(distinct cur.order_id) as use_num,
    sum(spo.salesplan_count*spo.setnumber) as ticket_num,
    sum(spo.totalprice) as totalprice,
    sum(spo.grossprofit) as grossprofit
from (
    $cgr
    ) cgr
    join (
    $cou
    ) cou
    on cgr.batch_id=cou.batch_id
    join (
    $cur
    ) cur
    on cou.coupon_id=cur.coupon_id
    join (
    $spo
    and discountamount>0
    ) spo
    on spo.order_id=cur.order_id
group by
    spo.dt,
    cgr.batch_id,
    cgr.batch_name,
    cgr.denomination,
    cgr.begindate,
    cgr.enddate
$lim">${attach}

echo "succuess,detail see ${attach}"

