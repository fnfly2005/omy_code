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

mpw=`fun detail_myshow_pv_wide_report.sql ut`
spo=`fun detail_myshow_salepayorder.sql ut` 
ssp=`fun detail_myshow_salesplan.sql ut`
cat=`fun dim_myshow_category.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    spo.dt,
    category_name,
    ap_num,
    sp_num,
    order_num,
    ticket_num,
    totalprice,
    grossprofit,
    uv
from (
    select
        partition_date as dt,
        category_id,
        count(distinct performance_id) sp_num,
        count(distinct order_id) as order_num,
        sum(salesplan_count*setnumber) as ticket_num,
        sum(totalprice) as totalprice,
        sum(grossprofit) as grossprofit
    $spo
        and sellchannel not in (9,10,11)
    group by
        1,2
    ) as spo
    left join (
        select
            partition_date as dt,
            category_id,
            count(distinct performance_id) as ap_num
        $ssp
            and salesplan_sellout_flag=0
        group by
            1,2
        ) ssp
    on spo.category_id=ssp.category_id
    and spo.dt=ssp.dt
    left join (
        select
            partition_date as dt,
            category_id,
            count(distinct union_id) uv
        $mpw
            and page_name_my='演出详情页'
        group by
            1,2
        ) as mpw
    on mpw.dt=spo.dt
    and mpw.category_id=spo.category_id
    left join (
        $cat
        ) as cat
    on cat.category_id=spo.category_id
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
