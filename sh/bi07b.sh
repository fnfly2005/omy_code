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

fpw=`fun detail_flow_all_report_hourly.sql u`
custom_id="locate_city_id" #自定义字段
typ="PV" #PV 页面埋点 MV 模块埋点
limit=50 #每个埋点查看量
identifier="pages/show/index/index','pages/show/detail/index" #指定埋点查询
mod=0 #0 指定埋点查询 1 批量导入查询
hour=17

file="bi07"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    page_identifier,
	event_id,
    custom,
    utm_source,
    $custom_id,
    page_city_id,
    geo_city_id,
	event_category,
	event_type,
	order_id
from (
    select
        page_identifier,
        event_id,
        custom,
        utm_source,
        $custom_id,
        page_city_id,
        geo_city_id,
        event_category,
        event_type,
        order_id,
        row_number() over (partition by event_id order by 1) as rank
    from (
        select distinct
            page_identifier,
            event_id,
            custom,
            utm_source,
            $custom_id,
            page_city_id,
            geo_city_id,
            event_category,
            event_type,
            order_id
        from (
            select
                page_identifier,
                event_id,
                event_category,
                event_type,
                order_id,
                page_city_id,
                geo_city_id,
                custom,
                utm_source,
                $custom_id,
                row_number() over (partition by case when 'PV' in ('$typ') 
                    then page_identifier else event_id end order by 1) as rak
            $fpw
                and partition_hour>=$hour
                and (
                    (partition_nm in ('$typ')
                    and (page_identifier in (
                            select
                                identifier
                            from 
                                upload_table.myshow_identifier_ver
                            where
                                $mod=1
                            )
                        or page_identifier in ('$identifier'))
                        )
                    or 
                    (partition_nm in ('$typ')
                    and (event_id in (
                        select
                            identifier
                        from 
                            upload_table.myshow_identifier_ver
                        where
                            $mod=1
                        )
                        or event_id in ('$identifier'))
                        )
                    )
            ) as fw
        where
            rak<=1000
        ) as rk
    ) as ran
where
    rank<=$limit
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
