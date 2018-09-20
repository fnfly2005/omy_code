#!/bin/bash
#埋点逻辑数据验证工具
source ./fuc.sh
fpw=`fun detail_flow_pv_wide_report.sql u`
fmw=`fun detail_flow_mv_wide_report.sql u`

file="bi07"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    app_name,
    page_identifier,
	event_id,
    custom,
    utm_source,
    \$custom_id,
    page_city_id,
    geo_city_id,
	event_category,
	event_type,
	event_attribute,
	order_id
from (
    select
        app_name,
        page_identifier,
        event_id,
        custom,
        utm_source,
        \$custom_id,
        page_city_id,
        geo_city_id,
        event_category,
        event_type,
        event_attribute,
        order_id,
        row_number() over (partition by \$event_id order by 1) as rank
    from (
        select distinct
            app_name,
            page_identifier,
            event_id,
            custom,
            utm_source,
            \$custom_id,
            page_city_id,
            geo_city_id,
            event_category,
            event_type,
            event_attribute,
            order_id
        from (
            select
                app_name,
                page_identifier,
                page_identifier as event_id,
                'all' as event_category,
                'all' as event_type,
                custom as event_attribute,
                'all' as order_id,
                page_city_id,
                geo_city_id,
                custom,
                utm_source,
                \$custom_id,
                row_number() over (partition by page_identifier order by 1) as rak
            $fpw
                and 1 in (\$type)
                and substr(stat_time,12,2)>='\$ht'
                and (
                    page_identifier in (
                        select
                            identifier
                        from 
                            upload_table.myshow_identifier_ver
                        where
                            \$mod=1
                        )
                    or (page_identifier in ('\$identifier') and \$mod=0)
                    )
                and app_name in ('\$app_name')
            union all
            select
                app_name,
                page_identifier,
                event_id,
                event_category,
                event_type,
                event_attribute,
                order_id,
                page_city_id,
                geo_city_id,
                custom,
                utm_source,
                \$custom_id,
                row_number() over (partition by event_id order by 1) as rak
            $fmw
                and 2 in (\$type)
                and substr(stat_time,12,2)>='\$ht'
                and (
                    event_id in (
                        select
                            identifier
                        from 
                            upload_table.myshow_identifier_ver
                        where
                            \$mod=1
                        )
                    or (page_identifier in ('\$identifier') and \$mod=0)
                    or (event_id in ('\$identifier') and \$mod=2)
                    )
                and app_name in ('\$app_name')
            ) as fw
        where
            rak<=1000
        ) as rk
    ) as ran
where
    rank<=\$limit
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
