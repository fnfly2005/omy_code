#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
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

fpw=`fun detail_flow_pv_wide_report.sql u` 
md=`fun myshow_dictionary.sql`

file="bs32"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    case when md2.value2 is not null then md2.value2
    when fromTag=0 then '其他'
    when fromTag is null then '其他'
    else fromTag end fromTag,
    md1.value2 as pt,
    sum(uv) uv
from (
    select
        partition_date as dt,
        app_name,
        custom['fromTag'] fromTag,
        approx_distinct(union_id) as uv
    $fpw
    group by
        1,2,3
    ) fpw
    left join (
        $md
        and key_name='app_name'
        ) md1
    on md1.key=fpw.app_name
    left join (
        $md
        and key_name='fromTag'
        ) md2
    on md2.key=fpw.fromTag
group by
    1,2,3
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


