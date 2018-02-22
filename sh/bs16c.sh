#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
per=`fun dim_myshow_performance.sql`

file="bs16"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    per.performance_name,
    sp1.order_num,
    sp1.ticket_num,
    sp1.totalprice,
    sp1.grossprofit
from (
    select
        performance_id,
        order_num,
        ticket_num,
        totalprice,
        grossprofit,
        row_number() over (order by totalprice desc) as rank
    from (
        select
            performance_id, 
            count(distinct spo.order_id) as order_num,
            sum(spo.salesplan_count*spo.setnumber) as ticket_num,
            sum(spo.totalprice) as totalprice,
            sum(spo.grossprofit) as grossprofit
        from
            (
            $spo
            and sellchannel=8
            ) spo
        group by
            performance_id
        ) as sp0
    ) as sp1
    left join (
    $per
    ) as per
    on per.performance_id=sp1.performance_id
where
    sp1.rank<=10
$lim">${attach}

echo "succuess,detail see ${attach}"

