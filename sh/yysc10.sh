#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

cgr=`fun dim_myshow_batch.sql`
cou=`fun dp_myshowcoupon__s_coupon.sql`
cur=`fun dp_myshowcoupon__s_couponuserecord.sql`
spo=`fun detail_myshow_salepayorder.sql`
bat=`fun detail_myshow_batch.sql`
per=`fun dim_myshow_performance.sql`


file="yysc10"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    case when \$dt=1 then cs.dt
    else 'all' end as dt,
    category_name,
    cs.batch_id,
    batch_name,
    batch_value,
    begindate,
    enddate,
    sum(sued_num) sued_num,
    sum(use_num) use_num,
    sum(ticket_num) as ticket_num,
    sum(totalprice) as totalprice,
    sum(grossprofit) as grossprofit
from (
    select
        spo.dt,
        case when \$cat=1 then per.category_name
        else 'all' end as category_name,
        cgr.batch_id,
        cgr.batch_name,
        cgr.batch_value,
        cgr.begindate,
        cgr.enddate,
        count(distinct spo.order_id) as use_num,
        sum(spo.salesplan_count*spo.setnumber) as ticket_num,
        sum(spo.totalprice) as totalprice,
        sum(spo.grossprofit) as grossprofit
    from (
        $cgr
        and status=1
        ) cgr
        left join (
        $cou
        ) cou
        on cgr.batch_id=cou.batch_id
        left join (
        $cur
        and useddate>='\$\$begindate'
        and useddate<'\$\$enddate'
        ) cur
        on cou.coupon_id=cur.coupon_id
        left join (
        $spo
        and discountamount>0
        ) spo
        on spo.order_id=cur.order_id
        left join (
        $per
        ) per
        on per.performance_id=spo.performance_id
    group by
        1,2,3,4,5,6,7
    ) cs
    left join (
    $bat
    ) bat
    on bat.batch_id=cs.batch_id
    and bat.dt=cs.dt
where
    sued_num>0
    or use_num>0
group by
    1,2,3,4,5,6,7
$lim">${attach}

echo "succuess,detail see ${attach}"

