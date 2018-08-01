#!/bin/bash
#分平台流量销售
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
mpw=`fun detail_myshow_pv_wide_report.sql um`
md=`fun myshow_dictionary.sql`
file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(fp1.dt,1,7) as mt,
    fp1.pt,
    avg(fp1.uv) uv,
    avg(sp1.order_num) order_num,
    avg(sp1.totalprice) totalprice
from (
    select
        fpw.dt,
        case when md.value2 is null then '其他'
        else md.value2 end as pt,
        sum(fpw.uv) as uv
    from (
        select
            partition_date as dt,
            app_name,
            count(distinct union_id) as uv
        $mpw
        group by
            1,2
        ) as fpw
    left join (
        $md
        and key_name='app_name'
        ) md
    on fpw.app_name=md.key
    group by
        1,2
    ) as fp1
    join (
    select
        sp0.dt,
        md.value2 as pt,
        sum(sp0.order_num) as order_num,
        sum(sp0.totalprice) as totalprice
    from (
        select
            spo.dt,
            spo.sellchannel,
            count(distinct spo.order_id) as order_num,
            sum(spo.totalprice) as totalprice
        from (
            $spo
            and sellchannel not in (9,10,11)
            ) spo
        group by
            spo.dt,
            spo.sellchannel
        ) as sp0
        left join (
            $md
            and key_name='sellchannel'
            ) as md
        on sp0.sellchannel=md.key
    group by
        sp0.dt,
        md.value2
    ) as sp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
group by
    1,2
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
