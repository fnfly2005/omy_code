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

md=`fun myshow_dictionary.sql`
mp=`fun myshow_pv.sql d`
fpw=`fun detail_flow_pv_wide_report.sql ut`
fmw=`fun detail_flow_mv_wide_report.sql ut`

file="xk06"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    fpw.dt,
    mp.key,
    value,
    name,
    page,
    nav_flag,
    page_tag1,
    case when mp.key='page_identifier' then fpw.uv
    else fmw.uv end as uv,
    md1.value2 as nav_name,
    md2.value2 as page_name
from (
    $mp
    ) mp
    left join (
        select
            partition_date as dt,
            page_identifier,
            approx_distinct(union_id) uv
        $fpw
        and page_identifier in (
            select value
            from upload_table.myshow_pv
            where key='page_identifier')
        group by
            1,2
            ) fpw
    on mp.value=fpw.page_identifier
    and mp.key='page_identifier'
    left join (
        select
            partition_date as dt,
            event_id,
            approx_distinct(union_id) uv
        $fmw
        and event_id in (
            select value
            from upload_table.myshow_pv
            where key='event_id') 
        group by
            1,2
            ) fmw
    on fmw.event_id=mp.value
    and mp.key='event_id'
    left join (
        $md
        and key_name='nav_flag'
        ) md1
    on md1.key=mp.nav_flag
    left join (
        $md
        and key_name='page_tag1'
        ) md2
    on md2.key=mp.page_tag1
order by
	mp.key desc,
    page,
    page_tag1 desc,
    nav_flag,
    8 desc
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
