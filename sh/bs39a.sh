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

mpw=`fun detail_myshow_pv_wide_report.sql ud`
file="bs39"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    partition_date as dt,
    approx_distinct(union_id) as dau
$mpw
where
    partition_date>='\$\$begindate'
    and partition_date<'\$\$enddate'
    and app_name='gewara'
    and partition_biz_bg=2
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
