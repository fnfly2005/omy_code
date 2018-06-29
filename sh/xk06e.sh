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

mp=`fun dim_myshow_pv.sql`
mm=`fun dim_myshow_mv.sql`
md=`fun myshow_dictionary.sql`
fmw=`fun detail_flow_mv_wide_report.sql ut`

file="xk06"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    mm.event_id,
    mm.page_identifier,
    page_name_my,
    event_name_lv1,
    event_name_lv2,
    user_int,
    mm.biz_par,
    biz_typ,
    page_loc,
    md1.value2 as biz_bg_v,
    cid_type,
    event_type,
    md2.value2 as user_int_v,
    biz_bg,
    page_cat,
    uv
from (
    $mm
    ) mm
    left join (
        $mp
        ) mp
    on mp.page_identifier=mm.page_identifier
    left join (
        $md
        and key_name='biz_bg'
        ) md1
    on md1.key=mp.biz_bg
    left join (
        $md
        and key_name='user_int'
        ) md2
    on md1.key=mm.user_int
    left join (
        select 
            partition_date as dt,
            event_id,
            event_type,
            approx_distinct(union_id) uv
        $fmw
        group by
            1,2,3
        ) as fpw
    on mm.event_id=fpw.event_id
order by
   12,15,16,17 desc
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


