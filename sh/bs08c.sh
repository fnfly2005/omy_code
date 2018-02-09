#!/bin/bash
#分平台流量销售
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
fpw=`fun detail_flow_pv_wide_report.sql`
md=`fun myshow_dictionary.sql`

file="bs08"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    s2.mt,
    s2.pt,
    order_num,
    totalprice,
    uv
from (
    select
        mt,
        value2 as pt,
        sum(order_num) order_num,
        sum(totalprice) totalprice
    from (
        select
            substr(dt,1,7) as mt,
            sellchannel,
            count(distinct order_id) as order_num,
            sum(totalprice) as totalprice
        from (
            $spo
            ) as spo
        group by
            1,2
        ) as s1
        left join (
        $md
        and key_name='sellchannel'
        ) as md
        on md.key=s1.sellchannel
    group by
        1,2
    ) as s2
    left join (
        select
            substr(dt,1,7) as mt,
            value2 as pt,
            avg(uv) as uv
        from (
            select
                partition_date as dt,
                app_name,
                approx_distinct(union_id) as uv
            from
                mart_flow.detail_flow_pv_wide_report
            where
                partition_date>='\$\$begindate'
                and partition_date<'\$\$enddate'
                and partition_log_channel='movie'
                and partition_app in (
                select key
                from upload_table.myshow_dictionary
                where key_name='partition_app'
                )
                and page_identifier in (
                select value
                from upload_table.myshow_pv
                where key='page_identifier'
                and page_tag1>=0
                )
            group by
                1,2
            ) fpw
            left join (
            $md
            and key_name='app_name'
            ) as md
            on md.key=fpw.app_name
        group by
            1,2
        ) as p1
    on s2.mt=p1.mt
    and s2.pt=p1.pt
$lim">${attach}

echo "succuess,detail see ${attach}"
