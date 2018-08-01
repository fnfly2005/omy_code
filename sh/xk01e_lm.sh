#!/bin/bash
path=""
fun() {
    tmp=`cat ${path}sql/${1} | grep -iv "/\*"`
    if [ -n $2 ];then
        if [[ $2 =~ d ]];then
            tmp=`echo $tmp | sed 's/where.*//'`
        fi
        if [[ $2 =~ u ]];then
            tmp=`echo $tmp | sed 's/.*from/from/'`
        fi
        if [[ $2 =~ t ]];then
            tmp=`echo $tmp | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
        fi
        if [[ $2 =~ m ]];then
            tmp=`echo $tmp | sed "s/begindate/monthfirst{-1m}/g;s/enddate/monthfirst/g"`
        fi
    fi
    echo $tmp
}

spo=`fun detail_myshow_salepayorder.sql m`
per=`fun dim_myshow_performance.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sp1.mt,
    per.performance_name,
    sp1.order_num,
    sp1.ticket_num,
    sp1.totalprice,
    sp1.grossprofit,
    sp1.rank
from (
    select
        mt,
        performance_id,
        order_num,
        ticket_num,
        totalprice,
        grossprofit,
        row_number() over (partition by mt order by totalprice desc) as rank
    from (
        select
            substr(spo.dt,1,7) mt,
            performance_id, 
            count(distinct spo.order_id) as order_num,
            sum(ticket_num) as ticket_num,
            sum(spo.totalprice) as totalprice,
            sum(spo.grossprofit) as grossprofit
        from (
            $spo
                and sellchannel not in (9,10,11)
            ) spo
        group by
            1,2
        ) as sp0
    ) as sp1
    left join (
    $per
    ) as per
    on per.performance_id=sp1.performance_id
where
    sp1.rank<=30
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
