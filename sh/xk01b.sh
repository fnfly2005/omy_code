#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
#修改字典表地址
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == dx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}

mpw=`fun detail_myshow_pv_wide_report.sql ut`
spo=`fun detail_myshow_salepayorder.sql ut`
ss=`fun detail_myshow_salesplan.sql t`
md=`fun myshow_dictionary.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    fp1.dt,
    fp1.pt,
    fp1.uv,
    sp1.order_num,
    sp1.totalprice
from (
    select
        sp0.dt,
        md.value2 as pt,
        sum(sp0.order_num) as order_num,
        sum(sp0.totalprice) as totalprice
    from (
        select
            partition_date as dt,
            sellchannel,
            count(distinct order_id) as order_num,
            sum(totalprice) as totalprice
        $spo
            and sellchannel not in (9,10,11)
        group by
            partition_date,
            sellchannel
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
    left join (
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
                partition_date,
                app_name
            ) as fpw
        left join (
            $md
            and key_name='app_name'
            ) md
        on fpw.app_name=md.key
        group by
            1,2
        ) as fp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
