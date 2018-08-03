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

fmw=`fun detail_flow_mv_wide_report.sql u`
file="bs39"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    partition_date as dt,
    approx_distinct(union_id) as uv
$fmw
    and partition_app='other_app'
    and app_name='gewara'
    and page_identifier='c_f740bkf7'
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
