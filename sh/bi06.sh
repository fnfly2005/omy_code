#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 线上埋点查询-猫眼文化-电影演出
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

spc=`fun sdk_page_config_info.sql`
mp=`fun myshow_pv.sql`
fpw=`fun detail_flow_pv_wide_report.sql d`

file="bi06"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    spm.cid,
    spm.app_name,
    app_identifier,
    page_name,
    app_name as app_id2,
    page_identifier,
    uv
from (
    select distinct
        cid,
        app_name,
        app_identifier,
        page_name
    from (
        $spc
        ) spc
        left join (
        $mp
        ) mp
        on mp.value=spc.cid
    where
        mp.value is null
    ) spm
    left join (
    select
        app_name,
        page_identifier,
        count(distinct union_id) as uv
    from
        mart_flow.detail_flow_pv_wide_report
    where
        partition_date='\$\$today{-1d}'
        and partition_log_channel='movie'
        and partition_app in (
            'movie',
            'dianping_nova',
            'other_app',
            'dp_m',
            'group'
            )
        and (
            app_name='gewara'
            or page_identifier like '%演出%'
            )
    group by
        1,2
    ) fpw
    on fpw.page_identifier=spm.cid
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


