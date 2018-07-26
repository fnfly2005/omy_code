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

md=`fun myshow_dictionary.sql`
file="bs16"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    md.value2 as pt,
    page_name_my,
    event_name_lv1,
    event_name_lv2,
    page_loc,
    sum(case when event_type='click' then uv end) as click_uv,
    sum(case when event_type='click' then pv end) as click_pv,
    sum(case when event_type='view' then uv end) as view_uv,
    sum(case when event_type='view' then pv end) as view_pv
from (
    select
        case when 1 in (\$dim) then partition_date
        else 'all' end as dt,
        case when 2 in (\$dim) then app_name
        else 'all' end as app_name,
        page_identifier,
        event_id,
        event_type,
        approx_distinct(union_id) as uv,
        count(1) as pv
    from
        mart_flow.detail_flow_mv_wide_report
    where
        partition_date>='\$\$begindate'
        and partition_date<'\$\$enddate'
        and partition_log_channel='movie'
        and partition_app in (
            'movie',
            'dianping_nova',
            'other_app',
            'dp_m',
            'group'
            )
        and page_identifier in ('\$page_identifier')
    group by
        1,2,3,4,5
    ) as fmw
    join (
        $md
        and key_name='app_name'
        ) as md
    on md.key=fmw.app_name
    join mart_movie.dim_myshow_mv mp
    on mp.event_id=fmw.event_id
    and mp.page_identifier=fmw.page_identifier
    left join mart_movie.dim_myshow_pv msp
    on mp.page_identifier=msp.page_identifier
where
    md.value2 in ('\$app_name')
group by 
    1,2,3,4,5,6
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
