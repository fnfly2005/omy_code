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

file="bi06"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    mp.*,
    md.value2,
    page_id,
    uv
from (
    $mp
    ) mp
    left join (
        $md
        and key_name='page_cat'
        ) md
    on md.key=mp.page_cat
    left join (
        select 
            page_identifier,
            page_id,
            approx_distinct(union_id) uv
        from 
            mart_flow.detail_flow_pv_wide_report
        where
            partition_date>='\$\$today{-1d}'
            and partition_date<'\$\$today{-0d}'
            and partition_log_channel='movie'
            and partition_app in (
                'movie',
                'dianping_nova',
                'other_app',
                'dp_m',
                'group')
        group by
            1,2
        ) as fpw
    on mp.page_identifier=fpw.page_identifier
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


