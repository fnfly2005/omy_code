#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path=""
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

spo=`fun detail_myshow_salepayorder.sql` 
ss=`fun detail_myshow_salesplan.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(ss1.dt,1,7) as mt,
    avg(ss1.ap_num) as ap_num,
    avg(ss1.as_num) as as_num,
    avg(sp1.sp_num) as sp_num,
    sum(sp1.order_num) as order_num,
    sum(sp1.ticket_num) as ticket_num,
    sum(sp1.totalprice) as totalprice,
    sum(sp1.grossprofit) as grossprofit,
    avg(sp1.order_num) as order_avgnum,
    avg(fpw.uv) as uv
from (
    select
        partition_date as dt,
        count(distinct performance_id) as ap_num,
        count(distinct salesplan_id) as as_num
    from 
        mart_movie.detail_myshow_salesplan
    where
        partition_date>='\$\$monthfirst{-1m}'
        and partition_date<'\$\$monthfirst'
        and salesplan_sellout_flag=0
    group by
        1
    ) as ss1
    left join (
        select
            partition_date as dt,
            count(distinct performance_id) as sp_num,
            count(distinct order_id) as order_num,
            sum(salesplan_count*setnumber) as ticket_num,
            sum(totalprice) as totalprice,
            sum(grossprofit) as grossprofit
        from
            mart_movie.detail_myshow_salepayorder
        where
            partition_date>='\$\$monthfirst{-1m}'
            and partition_date<'\$\$monthfirst'
            and sellchannel not in (9,10,11)
        group by
            1
    ) as sp1
    on sp1.dt=ss1.dt
    left join (
        select
            partition_date as dt,
            count(distinct union_id) as uv
        from
            mart_movie.detail_myshow_pv_wide_report
        where partition_date>='\$\$monthfirst{-1m}'
            and partition_date<'\$\$monthfirst'
            and partition_biz_bg=1
        group by
            partition_date
    ) as fpw
    on ss1.dt=fpw.dt
group by
    1
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
