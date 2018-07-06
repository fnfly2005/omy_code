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

dmp=`fun dim_myshow_pv.sql`
fpw=`fun detail_flow_pv_wide_report.sql t`
per=`fun dim_myshow_performance.sql`

file="etl01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    partition_date,
    biz_bg,
    page_identifier,
    page_name_my,
    page_cat,
    uv_src,
    fp1.performance_id,
    category_id,
    shop_id,
    city_id,
    province_id,
    app_name,
    union_id,
    uuid,
    session_id,
    user_id,
    imei,
    idfa,
    stat_time,
    refer_page_identifier,
    custom,
    os,
    page_city_id,
    page_city_name,
    ip_location_city_id,
    ip_location_city_name
from (
    select
        partition_date,
        biz_bg,
        dmp.page_identifier,
        page_name_my,
        page_cat,
        case when cid_type='h5' then custom['fromTag']
        when cid_type in ('mini_programs','pc') then utm_source
        end as uv_src,
        case when biz_bg=1 and page_cat in (2,3)
            then case when cid_type='h5' then custom['performance_id']
                when cid_type='mini_programs' then custom['id']
                when cid_type='native' then custom['drama_id'] end
        end as performance_id,
        app_name,
        union_id,
        uuid,
        session_id,
        user_id,
        imei,
        idfa,
        stat_time,
        refer_page_identifier,
        custom,
        os,
        page_city_id,
        page_city_name,
        ip_location_city_id,
        ip_location_city_name
    from (
        $dmp
        ) dmp
        join mart_flow.detail_flow_pv_wide_report fpw
        on dmp.page_identifier=fpw.page_identifier
        and partition_date='\$\$today{-1d}'
        and partition_log_channel='movie'
        and partition_app in ('movie', 'dianping_nova', 'other_app', 'dp_m', 'group')
    ) fp1 
    left join (
        $per
        ) per
    on fp1.performance_id=per.performance_id
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
